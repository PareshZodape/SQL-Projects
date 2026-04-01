import streamlit as st
import sqlite3
import pandas as pd

# DB Connection
conn = sqlite3.connect("bookstore.db", check_same_thread=False)
cursor = conn.cursor()

# Create tables
cursor.execute("""
CREATE TABLE IF NOT EXISTS Books (
    Book_ID INTEGER PRIMARY KEY,
    Title TEXT,
    Author TEXT,
    Genre TEXT,
    Published_Year INTEGER,
    Price REAL,
    Stock INTEGER
)
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS Customers (
    Customer_ID INTEGER PRIMARY KEY,
    Name TEXT,
    Email TEXT,
    Phone TEXT,
    City TEXT,
    Country TEXT
)
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS Orders (
    Order_ID INTEGER PRIMARY KEY,
    Customer_ID INTEGER,
    Book_ID INTEGER,
    Order_Date TEXT,
    Quantity INTEGER,
    Total_Amount REAL
)
""")

conn.commit()

def run_query(query):
    return pd.read_sql_query(query, conn)


# Sidebar
st.sidebar.title("📚 Online Bookstore")
menu = st.sidebar.selectbox("Menu", ["View Data", "Basic Queries", "Advanced Queries", "Analytics"])

# ---------------- VIEW DATA ----------------
if menu == "View Data":
    st.title("📂 Database Tables")

    table = st.selectbox("Select Table", ["Books", "Customers", "Orders"])
    df = run_query(f"SELECT * FROM {table}")
    st.dataframe(df)

# ---------------- BASIC QUERIES ----------------
elif menu == "Basic Queries":
    st.title("🔍 Basic SQL Queries")

    query_option = st.selectbox("Select Query", [
        "Fiction Books",
        "Books after 1950",
        "Customers from Canada",
        "Orders in Nov 2023",
        "Total Stock by Genre",
        "Most Expensive Book",
        "Orders with Quantity > 1",
        "Orders > $20",
        "All Genres",
        "Lowest Stock Book",
        "Total Revenue"
    ])

    if query_option == "Fiction Books":
        df = run_query("SELECT * FROM Books WHERE Genre='Fiction'")

    elif query_option == "Books after 1950":
        df = run_query("SELECT * FROM Books WHERE Published_Year > 1950 ORDER BY Published_Year DESC")

    elif query_option == "Customers from Canada":
        df = run_query("SELECT * FROM Customers WHERE Country='Canada'")

    elif query_option == "Orders in Nov 2023":
        df = run_query("""
            SELECT * FROM Orders
            WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30'
        """)

    elif query_option == "Total Stock by Genre":
        df = run_query("""
            SELECT Genre, SUM(Stock) AS Total_Stock
            FROM Books GROUP BY Genre
        """)

    elif query_option == "Most Expensive Book":
        df = run_query("SELECT * FROM Books ORDER BY Price DESC LIMIT 1")

    elif query_option == "Orders with Quantity > 1":
        df = run_query("SELECT * FROM Orders WHERE Quantity > 1")

    elif query_option == "Orders > $20":
        df = run_query("SELECT * FROM Orders WHERE Total_Amount > 20")

    elif query_option == "All Genres":
        df = run_query("SELECT DISTINCT Genre FROM Books")

    elif query_option == "Lowest Stock Book":
        df = run_query("SELECT * FROM Books ORDER BY Stock LIMIT 1")

    elif query_option == "Total Revenue":
        df = run_query("SELECT SUM(Total_Amount) AS Revenue FROM Orders")

    st.dataframe(df)

# ---------------- ADVANCED QUERIES ----------------
elif menu == "Advanced Queries":
    st.title("📊 Advanced SQL Queries")

    adv_query = st.selectbox("Select Query", [
        "Books Sold per Genre",
        "Average Price (Fantasy)",
        "Customers with 2+ Orders",
        "Most Ordered Book",
        "Top 3 Expensive Fantasy Books",
        "Books Sold by Author",
        "Customers Spending > $30",
        "Top Customers by Spending",
        "Remaining Stock After Orders"
    ])

    if adv_query == "Books Sold per Genre":
        df = run_query("""
            SELECT b.Genre, SUM(o.Quantity) AS Total_Books_Sold
            FROM Orders o
            JOIN Books b ON b.Book_ID = o.Book_ID
            GROUP BY b.Genre
        """)

    elif adv_query == "Average Price (Fantasy)":
        df = run_query("SELECT AVG(Price) AS Avg_Price FROM Books WHERE Genre='Fantasy'")

    elif adv_query == "Customers with 2+ Orders":
        df = run_query("""
            SELECT Customer_ID, COUNT(Order_ID) AS Order_Count
            FROM Orders
            GROUP BY Customer_ID
            HAVING COUNT(Order_ID) >= 2
        """)

    elif adv_query == "Most Ordered Book":
        df = run_query("""
            SELECT Book_ID, COUNT(Order_ID) AS Order_Count
            FROM Orders
            GROUP BY Book_ID
            ORDER BY Order_Count DESC LIMIT 1
        """)

    elif adv_query == "Top 3 Expensive Fantasy Books":
        df = run_query("""
            SELECT * FROM Books
            WHERE Genre='Fantasy'
            ORDER BY Price DESC LIMIT 3
        """)

    elif adv_query == "Books Sold by Author":
        df = run_query("""
            SELECT b.Author, SUM(o.Quantity) AS Total_Sold
            FROM Orders o
            JOIN Books b ON o.Book_ID = b.Book_ID
            GROUP BY b.Author
        """)

    elif adv_query == "Customers Spending > $30":
        df = run_query("""
            SELECT DISTINCT c.City, o.Total_Amount
            FROM Orders o
            JOIN Customers c ON o.Customer_ID = c.Customer_ID
            WHERE o.Total_Amount > 30
        """)

    elif adv_query == "Top Customers by Spending":
        df = run_query("""
            SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount) AS Total_Spent
            FROM Orders o
            JOIN Customers c ON o.Customer_ID = c.Customer_ID
            GROUP BY c.Customer_ID, c.Name
            ORDER BY Total_Spent DESC LIMIT 2
        """)

    elif adv_query == "Remaining Stock After Orders":
        df = run_query("""
            SELECT b.Book_ID, b.Title, b.Stock,
                   COALESCE(SUM(o.Quantity), 0) AS Ordered,
                   b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining
            FROM Books b
            LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
            GROUP BY b.Book_ID
        """)

    st.dataframe(df)
    
elif menu == "Analytics":
    st.title("📊 Business Analytics Dashboard")

    # -------- KPIs --------
    st.subheader("📌 Key Metrics")

    col1, col2, col3 = st.columns(3)

    total_revenue = run_query("SELECT SUM(Total_Amount) AS Revenue FROM Orders").iloc[0,0]
    total_orders = run_query("SELECT COUNT(*) FROM Orders").iloc[0,0]
    total_customers = run_query("SELECT COUNT(*) FROM Customers").iloc[0,0]

    col1.metric("💰 Total Revenue", f"${total_revenue}")
    col2.metric("🛒 Total Orders", total_orders)
    col3.metric("👥 Customers", total_customers)

    st.divider()

    # -------- Books per Genre --------
    st.subheader("📚 Books by Genre")
    genre_df = run_query("""
        SELECT Genre, COUNT(*) AS Count
        FROM Books
        GROUP BY Genre
    """)
    st.bar_chart(genre_df.set_index("Genre"))

    # -------- Revenue by Month --------
    st.subheader("📅 Revenue Over Time")
    revenue_time = run_query("""
        SELECT substr(Order_Date,1,7) AS Month, SUM(Total_Amount) AS Revenue
        FROM Orders
        GROUP BY Month
        ORDER BY Month
    """)
    st.line_chart(revenue_time.set_index("Month"))

    # -------- Top Authors --------
    st.subheader("✍️ Top Authors by Sales")
    author_df = run_query("""
        SELECT b.Author, SUM(o.Quantity) AS Total_Sold
        FROM Orders o
        JOIN Books b ON o.Book_ID = b.Book_ID
        GROUP BY b.Author
        ORDER BY Total_Sold DESC
        LIMIT 5
    """)
    st.bar_chart(author_df.set_index("Author"))

    # -------- Top Customers --------
    st.subheader("🏆 Top Customers")
    customer_df = run_query("""
        SELECT c.Name, SUM(o.Total_Amount) AS Total_Spent
        FROM Orders o
        JOIN Customers c ON o.Customer_ID = c.Customer_ID
        GROUP BY c.Name
        ORDER BY Total_Spent DESC
        LIMIT 5
    """)
    st.bar_chart(customer_df.set_index("Name"))

    # -------- Stock Remaining --------
    st.subheader("📦 Stock Remaining")
    stock_df = run_query("""
        SELECT b.Title,
               b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining
        FROM Books b
        LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
        GROUP BY b.Title
        ORDER BY Remaining ASC
        LIMIT 10
    """)
    st.bar_chart(stock_df.set_index("Title"))    
    
