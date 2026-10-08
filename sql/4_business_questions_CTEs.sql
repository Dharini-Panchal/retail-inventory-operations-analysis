#----------------------------------- Advanced SQL -----------------------------------
#----------------------------------- CTE -----------------------------------
SELECT * FROM retail_inventory;

# Create a reusable temporary result that summarizes each product. (CTEs)
WITH product_performance AS (
	SELECT product_id, category, SUM(sales_amount) AS total_sales, SUM(closing_stock) AS total_closing_stock
	FROM retail_inventory
    GROUP BY product_id, category
)
SELECT * 
FROM product_performance
ORDER BY total_sales DESC;

# What are the strongest-selling products in each category?
WITH product_sales AS (
    SELECT product_id, category, SUM(sales_amount) AS total_sales
    FROM retail_inventory
    GROUP BY product_id, category
),
ranked_products AS (
    SELECT product_id, category, total_sales, 
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sales DESC) AS product_rank
    FROM product_sales
)
SELECT product_id, category, total_sales, product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category, product_rank;

# How does each store rank against the others in total sales? 
WITH store_sales AS (
    SELECT store_id, SUM(sales_amount) AS total_sales
    FROM retail_inventory
    GROUP BY store_id
)
SELECT store_id, total_sales, RANK() OVER ( ORDER BY total_sales DESC) AS sales_rank
FROM store_sales
ORDER BY sales_rank;

# Which categories hold the most inventory?
WITH category_inventory AS (
    SELECT category, SUM(closing_stock) AS total_closing_stock
    FROM retail_inventory
    GROUP BY category
)
SELECT category, total_closing_stock, 
	RANK() OVER (ORDER BY total_closing_stock DESC) AS inventory_rank
FROM category_inventory
ORDER BY inventory_rank;

# How do cumulative sales build over time? 
WITH daily_sales AS (
    SELECT transaction_date, SUM(sales_amount) AS daily_sales
    FROM retail_inventory
    GROUP BY transaction_date
)
SELECT transaction_date, daily_sales, 
	SUM(daily_sales) OVER (ORDER BY transaction_date) AS running_total_sales
FROM daily_sales
ORDER BY transaction_date;
