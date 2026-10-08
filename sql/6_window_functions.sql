#----------------------------------- Window Function -----------------------------------
# What percentage of each category's total sales comes from each product? 
WITH product_sales AS (
    SELECT category, product_id, SUM(sales_amount) AS product_sales
    FROM retail_inventory
    GROUP BY category, product_id
)
SELECT category, product_id, product_sales, SUM(product_sales) OVER (PARTITION BY category) AS category_total_sales,
    ROUND(product_sales / SUM(product_sales) OVER (PARTITION BY category) * 100, 2) AS percentage_of_category_sales
FROM product_sales
ORDER BY category, percentage_of_category_sales DESC;

# What is the sales rank of each product within its category?
WITH product_sales AS (
    SELECT category, product_id, SUM(sales_amount) AS total_sales
    FROM retail_inventory
    GROUP BY category, product_id
)
SELECT category, product_id,total_sales, 
	RANK() OVER(PARTITION BY category ORDER BY total_sales DESC) AS product_rank 
FROM product_sales;

# Which are the top 2 products in each category by sales?
WITH product_sales AS (
    SELECT category, product_id, SUM(sales_amount) AS total_sales
    FROM retail_inventory
    GROUP BY category, product_id
), 
ranked_products AS (
    SELECT category, product_id, total_sales, 
		DENSE_RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS product_rank
    FROM product_sales
)
SELECT *
FROM ranked_products
WHERE product_rank <= 2
ORDER BY category, product_rank;

# What is the daily sales and previous day's sales?
SELECT * FROM retail_inventory;
WITH daily_sales AS(
	SELECT transaction_date, SUM(sales_amount) AS daily_sales
    FROM retail_inventory
    GROUP BY transaction_date
), previous_day AS(
	SELECT transaction_date, daily_sales, LAG(daily_sales) OVER (ORDER BY transaction_date) AS previous_day
	FROM daily_sales
) 
SELECT *
FROM previous_day
ORDER BY transaction_date;

# How much did sales change compared with the previous day?
SELECT * FROM retail_inventory;
WITH daily_sales AS(
	SELECT transaction_date, SUM(sales_amount) AS daily_sales
    FROM retail_inventory
    GROUP BY transaction_date
), previous_day AS(
	SELECT transaction_date, daily_sales, LAG(daily_sales) OVER (ORDER BY transaction_date) AS previous_day
	FROM daily_sales
) 
SELECT *, daily_sales - previous_day AS difference
FROM previous_day
ORDER BY transaction_date;

# What is the 7-day running average of sales?
WITH daily_sales AS (
    SELECT transaction_date, SUM(sales_amount) AS daily_sales
    FROM retail_inventory
    GROUP BY transaction_date
)
SELECT *,ROUND(AVG(daily_sales) OVER (ORDER BY transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS "7DayRunAvg"
FROM daily_sales;