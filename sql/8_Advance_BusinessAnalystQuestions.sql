#----------------------------------- Advance : Business Analyst Questions ----------------------------------- 
# Inventory Management - Which products are overstocked?
WITH overstock AS (
	SELECT product_id, category, SUM(closing_stock) AS inventory, SUM(units_sold) AS total_units_sold
	FROM retail_inventory
    GROUP BY product_id, category
)
SELECT product_id, category, inventory, total_units_sold, 
	ROUND(inventory / NULLIF(total_units_sold,0), 2) AS inventory_to_sales_ratio
FROM overstock
ORDER BY inventory_to_sales_ratio DESC;

# Stockout Analysis - Which products frequently reach zero inventory?
SELECT product_id, category, COUNT(*) as stockout_count
FROM retail_inventory
WHERE closing_stock = 0
GROUP BY product_id, category
ORDER BY stockout_count DESC;

# Pricing - Which categories have the highest average selling price?
SELECT category, ROUND(AVG(unit_price),2) AS average_unit_price
FROM retail_inventory
GROUP BY category
ORDER BY average_unit_price DESC;

# Store Performance - Which stores are underperforming compared with the company average?
WITH store_performance AS (
	SELECT store_id, SUM(sales_amount) AS total_sales 
	FROM retail_inventory
	GROUP BY store_id
)
 SELECT store_id, total_sales, 
	ROUND((SELECT AVG(total_sales) FROM store_performance),2) AS company_average_sales
 FROM store_performance
 WHERE total_sales < (
	SELECT AVG(total_sales)
	FROM store_performance
)
ORDER BY total_sales;

# Time Analysis - Which days/months generate the most revenue?
SELECT MONTH(transaction_date) AS month_number, 
	MONTHNAME(transaction_date) as month_name, 
	SUM(sales_amount) AS total_sales
FROM retail_inventory
GROUP BY MONTH(transaction_date), MONTHNAME(transaction_date)
ORDER BY total_sales DESC;

# Inventory Efficiency - Which products generate high revenue despite low unit sales?
WITH product_performance AS (
    SELECT product_id, category, SUM(sales_amount) AS total_sales, SUM(units_sold) AS total_units_sold
    FROM retail_inventory
    GROUP BY product_id, category
)
SELECT product_id, category, total_sales, total_units_sold
FROM product_performance
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM product_performance
)
AND total_units_sold < (
    SELECT AVG(total_units_sold)
    FROM product_performance
)
ORDER BY total_sales DESC;

# Demand Analysis - Which products generate high unit sales but low revenue?
WITH product_performance AS (
	SELECT product_id, category, SUM(units_sold) AS total_units_sold, SUM(sales_amount) AS total_sales
	FROM retail_inventory
	GROUP BY product_id, category
)
SELECT product_id, category, total_units_sold, total_sales
FROM product_performance
WHERE total_units_sold > (
    SELECT AVG(total_units_sold)
    FROM product_performance
)
AND total_sales < (
    SELECT AVG(total_sales)
    FROM product_performance
)
ORDER BY total_units_sold DESC;

# Anomaly Detection - Which transactions look unusual compared with their category?
WITH transactions AS (
	SELECT transaction_id, category, SUM(sales_amount) as total_sales 
	FROM retail_inventory 
	GROUP BY transaction_id, category
), 
category_average AS (
	SELECT transaction_id, category, total_sales, 
    ROUND(AVG(total_sales) OVER (PARTITION BY category),2) AS category_avg_sales
    FROM transactions
)
SELECT transaction_id, category, total_sales, category_avg_sales
FROM category_average
WHERE total_sales > category_avg_sales
ORDER BY total_sales DESC;

# ABC Analysis - Which products generate approximately 80% of revenue?
WITH product_sale AS (
	SELECT product_id, category, SUM(sales_amount) as total_sale
    FROM retail_inventory
    GROUP BY product_id, category
), 
pareto_analysis AS (
	SELECT product_id, category, total_sale,
		SUM(total_sale) OVER(ORDER BY total_sale DESC) AS running_sales, 
		SUM(total_sale) OVER () AS company_total_sales
    FROM product_sale
)
SELECT product_id, category, total_sale, running_sales,
	ROUND(running_sales / company_total_sales * 100,2) AS cumulative_sales_percentage
FROM pareto_analysis
ORDER BY total_sale DESC;