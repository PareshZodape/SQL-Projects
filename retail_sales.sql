CREATE DATABASE Retail_Sales_Analysis ;

USE   Retail_Sales_Analysis;

-- Create table
CREATE TABLE retail_sales (
	transactions_id	INT PRIMARY KEY,
	sale_date	DATE,
	sale_time	TIME,
	customer_id	INT,
	gender	VARCHAR(20),
	age	INT,
	category VARCHAR(50),	
	quantiy	INT,
	price_per_unit	INT,
	cogs	FLOAT,
	total_sale FLOAT
);


-- DATA EXPLORATION 

-- A) check how many transaction we have 
 SELECT COUNT(*) as total_sales FROM retail_sales ;
 
-- B) check how many customer we have
select count(DISTINCT customer_id) as number_of_customers from retail_sales ;

-- C) Show all the distinct customers we have 
select DISTINCT(customer_id) from retail_sales
ORDER BY customer_id DESC ;

-- D) Check how many categories we have  and show them
select count(distinct category) as number_of_category from retail_sales ;
select distinct(category) as Category from retail_sales ;


-- E) check the number of records
SELECT COUNT(*)
FROM retail_sales ;

-- Lets Solve Business Problems 

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
		select * from retail_sales
		where sale_date = '2022-11-05' ;


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

select * from retail_sales 
where 
category = 'Clothing'
AND quantiy >= 4
AND month(sale_date) = 11
AND year(sale_date) = 2022 ;



-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category, sum(total_sale) AS Total_Sale from retail_sales 
group by category
order by Total_sale DESC;


-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select category , ROUND(avg(age)) AS avg_age from retail_sales 
where category = 'Beauty' ;


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

select * from retail_sales 
where total_sale > 1000 ;


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

select category, gender, count(transactions_id)
from retail_sales 
group by category , gender
order by category, gender ;


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

select 
	year(sale_date) as Year,
    month(sale_date) AS Month,
    round(avg(total_sale),2)
    from retail_sales
    group by year(sale_date), month(sale_date)
    order by Year, Month ;


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

select customer_id , sum(total_sale) AS total_sales
from retail_sales 
group by customer_id
order by  total_sales DESC 
LIMIT 5 ;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

select category ,
count(distinct(customer_id)) AS unique_customers
from retail_sales 
group by category ;



-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

with daily_orders
AS (
SELECT * , 
case
	when EXTRACT(hour from sale_time) < 12 then 'Morning'
	when EXTRACT(hour from sale_time) Between 12 AND 17 then 'Tuesday'
	else 'Evening'
END shift
from retail_sales 
) 
select shift, count(*) as total_order
from daily_orders
group by shift ;


