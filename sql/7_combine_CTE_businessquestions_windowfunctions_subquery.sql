#----------------------------------- CTE - SubQuery - CASE -----------------------------------
# Which products have high sales but are running low on inventory? Create a business priority flag  
WITH product_inventory AS (
    SELECT product_id, category, SUM(sales_amount) AS total_sales, SUM(closing_stock) AS total_inventory
    FROM retail_inventory
    GROUP BY product_id, category
)
SELECT product_id, category, total_sales, total_inventory,
    CASE
        WHEN total_sales > (SELECT AVG(total_sales) FROM product_inventory) AND total_inventory < (SELECT AVG(total_inventory) FROM product_inventory)
        THEN 'High Priority'
        WHEN total_sales > (SELECT AVG(total_sales) FROM product_inventory)
        THEN 'Medium Priority'
        ELSE 'Low Priority'
    END AS priority_flag
FROM product_inventory
ORDER BY total_sales DESC;

#---------------------------- CTEs + subqueries + window functions + business logic ----------------------------
# Which products generated the highest total sales within each store? Window function + CTE
WITH store_product_sales AS (
	SELECT store_id, product_id, category, 
		SUM(sales_amount) AS total_sales
    FROM retail_inventory
    GROUP BY store_id, product_id, category
)
SELECT *, 
	RANK() OVER(PARTITION BY store_id ORDER BY total_sales DESC) AS sales_rank 
FROM store_product_sales;

# Which stores have sales above the average store sales? CTE + subquery
WITH store_sales AS(
	SELECT store_id, SUM(sales_amount) as total_sales
	FROM retail_inventory 
    GROUP BY store_id
)
SELECT * 
FROM store_sales
WHERE total_sales > (SELECT AVG(total_Sales) FROM store_sales);

# Which categories have inventory turnover risk? Calculations + CASE 
WITH category_inventory AS (
	SELECT category, SUM(sales_amount) as total_sales, SUM(closing_stock) AS total_inventory
	FROM retail_inventory
	GROUP BY category
)
SELECT category, total_sales, total_inventory,
	ROUND(total_sales / total_inventory) AS inventory_turnover,
	CASE 
		WHEN total_sales / total_inventory >= 5
		THEN 'High Turnover Risk'
		WHEN total_sales / total_inventory <= 2
		THEN 'Low Turnover Risk'
		ELSE 'Normal Turnover Risk'
    END AS turnover_risk
FROM category_inventory
ORDER BY inventory_turnover DESC;

# What percentage of each store's sales comes from each category? Window functions
WITH store_category_sales AS (
    SELECT store_id, category, SUM(sales_amount) AS category_sales
    FROM retail_inventory
    GROUP BY store_id, category
)
SELECT store_id, category, ROUND(category_sales/SUM(category_sales) OVER(PARTITION BY store_id) * 100,2) AS percentage_Sale
FROM store_category_sales;

# Which products are responsible for the largest share of their store's sales? Window functions + ranking
WITH store_large_sales AS (
	SELECT store_id, product_id, category, SUM(sales_amount) AS product_sales
	FROM retail_inventory
	GROUP BY store_id, product_id, category
),
product_share AS (
	SELECT store_id, product_id, category, product_sales, 
		ROUND(product_sales/SUM(product_sales) OVER (PARTITION BY store_id) * 100,2) AS sales_share_percentage 
	FROM store_large_sales
)
SELECT *, RANK() OVER(PARTITION BY store_id ORDER BY sales_share_percentage DESC) AS share_rank
FROM product_share
ORDER BY store_id, share_rank;

# Which stores have both high sales and low inventory? CTE + CASE
WITH store_summary AS (
    SELECT store_id, SUM(sales_amount) AS total_sales, SUM(closing_stock) AS total_inventory
    FROM retail_inventory
    GROUP BY store_id
)
SELECT store_id, total_sales, total_inventory,
    CASE
        WHEN total_sales > (SELECT AVG(total_sales) FROM store_summary)
             AND total_inventory < (SELECT AVG(total_inventory) FROM store_summary)
        THEN 'High Priority'
        ELSE 'Normal'
    END AS priority_flag
FROM store_summary
ORDER BY total_sales DESC;

# What is each store's best-selling category?  RANK() + PARTITION BY
WITH store_best_selling AS (
    SELECT store_id, category, SUM(sales_amount) AS total_sales
    FROM retail_inventory
    GROUP BY store_id, category
),
store_rank AS (
    SELECT store_id, category, total_sales, RANK() OVER(PARTITION BY store_id ORDER BY total_sales DESC) AS ranking
    FROM store_best_selling
)
SELECT *
FROM store_rank
WHERE ranking = 1;

# Which products have declining sales compared with the previous transaction date? LAG()
WITH product_daily_sales AS (
    SELECT product_id, transaction_date, SUM(sales_amount) AS daily_product_sales
    FROM retail_inventory
    GROUP BY product_id, transaction_date
),
previous_day_sale AS (
    SELECT product_id, transaction_date, daily_product_sales,
        LAG(daily_product_sales) OVER (PARTITION BY product_id ORDER BY transaction_date) AS prev_day_sale
    FROM product_daily_sales
),
sales_change AS (
    SELECT product_id, transaction_date, daily_product_sales, prev_day_sale,
        daily_product_sales - prev_day_sale AS sales_change
    FROM previous_day_sale
)
SELECT *
FROM sales_change
WHERE sales_change < 0
ORDER BY product_id, transaction_date;

# What is the 7-day sales trend for each store? AVG() + window functions
WITH daily_sales AS (
    SELECT store_id, transaction_date, SUM(sales_amount) AS daily_sales
    FROM retail_inventory
    GROUP BY store_id, transaction_date
)
SELECT *,ROUND(AVG(daily_sales) OVER (PARTITION BY store_id ORDER BY transaction_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),2) AS "7DayRunAvg"
FROM daily_sales
ORDER BY store_id, transaction_date;

# Which products should management prioritize for replenishment? CTE + multiple conditions
WITH product_summary AS (
    SELECT product_id, category, SUM(sales_amount) AS total_sales, 
		SUM(units_sold) AS total_units_sold, SUM(closing_stock) AS total_inventory
    FROM retail_inventory
    GROUP BY product_id, category
)
SELECT product_id, category, total_sales, total_units_sold, total_inventory,
    CASE
        WHEN total_sales > (SELECT AVG(total_sales) FROM product_summary)
             AND total_inventory < (SELECT AVG(total_inventory) FROM product_summary)
        THEN 'High Priority'
        WHEN total_units_sold > (SELECT AVG(total_units_sold) FROM product_summary)
             AND total_inventory < (SELECT AVG(total_inventory) FROM product_summary)
        THEN 'Medium Priority'
        ELSE 'Low Priority'
    END AS replenishment_priority
FROM product_summary
ORDER BY
    CASE
        WHEN total_sales > (SELECT AVG(total_sales) FROM product_summary)
             AND total_inventory < (SELECT AVG(total_inventory) FROM product_summary)
        THEN 1
        WHEN total_units_sold > (SELECT AVG(total_units_sold) FROM product_summary)
             AND total_inventory < (SELECT AVG(total_inventory) FROM product_summary)
        THEN 2
        ELSE 3
    END,
    total_sales DESC;
