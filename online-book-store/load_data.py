import pandas as pd
import sqlite3

conn = sqlite3.connect("bookstore.db")

books = pd.read_csv("Books.csv")
customers = pd.read_csv("Customers.csv")
orders = pd.read_csv("Orders.csv")

books.to_sql("Books", conn, if_exists="replace", index=False)
customers.to_sql("Customers", conn, if_exists="replace", index=False)
orders.to_sql("Orders", conn, if_exists="replace", index=False)

conn.commit()
conn.close()