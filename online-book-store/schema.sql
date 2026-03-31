-- Tables

DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID INTEGER PRIMARY KEY,
    Title TEXT,
    Author TEXT,
    Genre TEXT,
    Published_Year INTEGER,
    Price REAL,
    Stock INTEGER
);

DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers (
    Customer_ID INTEGER PRIMARY KEY,
    Name TEXT,
    Email TEXT,
    Phone TEXT,
    City TEXT,
    Country TEXT
);

DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
    Order_ID INTEGER PRIMARY KEY,
    Customer_ID INTEGER,
    Book_ID INTEGER,
    Order_Date TEXT,
    Quantity INTEGER,
    Total_Amount REAL
);