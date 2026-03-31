-- Create Database
-- CREATE DATABASE OnlineBookstore;



-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID Integer PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID Integer PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID Integer PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

-- Show all the books
SELECT * FROM Books ;

-- Show all Customers 
SELECT * FROM Customers ;

-- Show all orders
SELECT * FROM Orders ; 

-- -- Import the csv data
-- copy Books(Book_ID, Title, Author, Genre, Published_Year, Price, Stock)
-- FROM 'D:/OnlineBooksStore/Books.csv'
-- WITH (FORMAT csv, HEADER);

-- -- Import the customer CSV data
-- copy Customers(Customer_ID, Name, Email, Phone, City, Country)
-- FROM 'D:/OnlineBooksStore/Customers.csv'
-- CSV HEADER ;

-- -- Import the Orders CSV data
-- copy Orders(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount)
-- FROM  'D:/OnlineBooksStore/Orders.csv'
-- CSV HEADER ;


-- Retrive all the books in "fiction Genre"
SELECT * FROM Books
WHERE Genre = 'Fiction' ;

-- Find the books published after year 1950
SELECT * FROM Books
Where Published_Year > 1950
Order BY Published_Year DESC;

-- List all the customers from canada
SELECT * FROM Customers
Where Country = 'Canada' ;


-- Show All the Orders place in november 2023
SELECT * FROM Orders
WHERE  Order_Date BETWEEN  '2023-11-01' AND '2023-11-30'
ORDER BY Order_Date ASC;

-- Retrive the total stocks available in books
SELECT Genre, SUM(stock) AS Total_Stocks
FROM Books
GROUP BY Genre
ORDER BY Genre;


-- Find the details of the most expensive books 
SELECT * from Books
ORDER BY Price DESC
LIMIT 1 ;


-- Show all the customers who ordered more than 1 quantity of book
SELECT * FROM Orders
Where quantity > 1
ORDER BY quantity DESC; 

-- Retrieve all orders where the total amount exceeds $20:
SELECT * FROM Orders
WHERE total_amount > 20;

-- List all genres available in the Books table:
SELECT DISTINCT Genre
FROM Books;

-- Find the book with the lowest stock:
SELECT * FROM Books
ORDER BY stock
LIMIT 1;

-- Calculate the total revenue generated from all orders:
SELECT SUM(total_amount) As Revenue
FROM Orders;


-- Advance Questions 

-- Retrieve the total number of books sold for each genre:
SELECT b.Genre, SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b ON b.book_id=o.book_id
GROUP BY b.Genre ;

-- Find the average price of books in the "Fantasy" genre
SELECT * FROM Books;

SELECT AVG(Price) AS Avg_Price
FROM Books
WHERE Genre = 'Fantasy';


-- List Customers who have placed at least 2 orders
SELECT customer_id, COUNT(order_id) AS Order_count
FROM Orders
GROUP BY customer_id
HAVING COUNT(order_id)>=2;

--  OR if we have to give name too

-- SELECT o.customer_id, c.Name, COUNT(o.order_id) AS Order_Count
-- FROM Orders o
-- JOIN customers c ON o.customer_id = c.customer_id
-- GROUP BY o.customer_id, c.Name
-- HAVING COUNT(o.order_id) >= 2;

-- Find the most frequently ordered book

SELECT Book_id, COUNT(Order_id) AS Order_Count
FROM Orders
GROUP BY Book_id
ORDER BY Order_Count DESC
LIMIT 1;
 
-- OR if we want to give the book name too
-- SELECT b.Title, o.Book_id, COUNT(Order_id) AS Order_Count
-- FROM Orders o
-- JOIN Books b ON b.Book_id = o.Book_id
-- GROUP BY o.Book_id, b.Title
-- ORDER BY COUNT(Order_id) DESC;

-- Show the top 3 most expensive books of 'Fantasy' Genre
SELECT * FROM Books
WHERE Genre = 'Fantasy' 
ORDER BY Price DESC
LIMIT 3 ;


-- Retrive the total quantity of books sold by each author
SELECT b.author , sum(o.Quantity) AS total_book_sold
FROM Orders o
JOIN Books b ON o.book_id = b.book_id
GROUP BY b.author ;


-- List the cities where customer who spent over $30 are located
 SELECT DISTINCT c.City, o.total_amount 
 FROM  orders o
 JOIN customers c ON o.customer_id = c.customer_id
 WHERE o.total_amount > 30;


-- Find the customers who spent the most on Orders 
SELECT c.customer_id, c.Name , SUM(o.total_amount) most_spent 
FROM Orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id , c.Name
ORDER BY most_spent DESC LIMIT 2;


-- Calculate the stock remaining after fulfilling all orders 
SELECT b.book_id, b.title, b.stock, COALESCE(SUM(o.Quantity), 0) AS Order_quantity, b.stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_Quantity
FROM Books b
LEFT JOIN Orders o ON b.book_id = o.book_id
GROUP BY b.book_id
ORDER BY b.book_id;
