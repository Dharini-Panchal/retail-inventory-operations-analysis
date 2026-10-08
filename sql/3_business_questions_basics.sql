#----------------------------------- Business Question --------------------------------
SELECT * FROM retail_inventory;

#1.Which stores generate the most sales? (Top 10)
SELECT store_id, SUM(sales_amount) AS sales_amount
FROM retail_inventory
GROUP BY store_id 
ORDER BY sales_amount DESC
LIMIT 10;

# 2.Which stores have the highest average sales? (Top 10)
SELECT store_id, ROUND(AVG(sales_amount),2) AS average_sales
FROM retail_inventory
GROUP BY store_id
ORDER BY average_sales DESC
LIMIT 10;

# 3.Which product categories have the largest number of inventory records?
SELECT category, COUNT(*) AS record_count
FROM retail_inventory
GROUP BY category;

# 4.Which categories have the most inventory available?
SELECT category, SUM(closing_stock) AS total_closing_stock
FROM retail_inventory
GROUP BY category
ORDER BY total_closing_stock DESC;

# 5.Which products may need to be restocked? (products whose inventory is below 20)
SELECT *
FROM retail_inventory
WHERE closing_stock < 20;

# 6.Which 10 products currently have the highest inventory?
SELECT product_id, category, closing_stock
FROM retail_inventory
ORDER BY closing_stock DESC
LIMIT 10;

# 7. Which 10 products have the lowest inventory?
SELECT product_id, category, closing_stock
FROM retail_inventory
ORDER BY closing_stock ASC
LIMIT 10;

# 8. Which product categories have the highest average inventory per record?
SELECT category, ROUND(AVG(closing_stock),2) AS highest_average_inventory
FROM retail_inventory 
GROUP BY category
ORDER BY highest_average_inventory DESC
LIMIT 5;

# 9. Which categories may have generally low inventory levels?
SELECT category, ROUND(AVG(closing_stock),2) AS avg_closing_stock
FROM retail_inventory
GROUP BY category
HAVING avg_closing_stock < 97
ORDER BY avg_closing_stock ASC;

# 10. Which stores currently hold the most inventory?
SELECT store_id, SUM(closing_stock) AS total_closing_stock
FROM retail_inventory
GROUP BY store_id
ORDER BY total_closing_stock DESC;

# 11.Which product categories generate the most sales?
SELECT category, SUM(sales_amount) AS sales
FROM retail_inventory
GROUP BY category
ORDER BY sales DESC
LIMIT 3;

# 12. Which categories have the highest average sales per record?
SELECT category, ROUND(AVG(sales_amount),2) AS sales
FROM retail_inventory
GROUP BY category
ORDER BY sales DESC
LIMIT 3;

# 13. Which products are completely out of stock?
SELECT product_id, category, closing_stock
FROM retail_inventory
WHERE closing_stock = 0;

# 14. Which categories have the most products currently out of stock?
SELECT category, COUNT(*) AS out_of_stock_products
FROM retail_inventory
WHERE closing_stock = 0
GROUP BY category
ORDER BY out_of_stock_products DESC;

# 15. Which stores generate the most sales?
SELECT store_id, SUM(sales_amount) AS sales
FROM retail_inventory
GROUP BY store_id
ORDER BY sales DESC
LIMIT 5;

# 16. Which 10 products generated the highest sales?
SELECT product_id, category, SUM(sales_amount) AS Sales
FROM retail_inventory
GROUP BY product_id, category
ORDER BY Sales DESC
LIMIT 10;

# 17. Which products are selling well but may have insufficient inventory? 
SELECT product_id, category, sales_amount, closing_stock
FROM retail_inventory
WHERE sales_amount > (
    SELECT AVG(sales_amount)
    FROM retail_inventory
)
AND closing_stock < (
    SELECT AVG(closing_stock)
    FROM retail_inventory
)
ORDER BY sales_amount DESC;

# 18. Which categories appear to sell quickly relative to the inventory they have?
SELECT category, SUM(units_sold)/SUM(closing_stock) AS inventory_turnover_indicator
FROM retail_inventory
GROUP BY category;

SELECT category, ROUND(SUM(units_sold) / NULLIF(SUM(closing_stock), 0), 2) AS inventory_turnover_indicator
FROM retail_inventory
GROUP BY category
ORDER BY inventory_turnover_indicator DESC;

SELECT category, total_sales, total_closing_stock
FROM (
    SELECT 
        category, SUM(sales_amount) AS total_sales, SUM(closing_stock) AS total_closing_stock
    FROM retail_inventory
    GROUP BY category
) AS category_summary
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM (
        SELECT SUM(sales_amount) AS total_sales
        FROM retail_inventory
        GROUP BY category
    ) AS sales_summary
)
AND total_closing_stock < (
    SELECT AVG(total_closing_stock)
    FROM (
        SELECT SUM(closing_stock) AS total_closing_stock
        FROM retail_inventory
        GROUP BY category
    ) AS inventory_summary
)
ORDER BY total_sales DESC;

# 19. Which categories might need closer inventory monitoring?
SELECT category, 
SUM(sales_amount) AS total_sales, AVG(sales_amount) AS avg_total_sales,
SUM(closing_stock) AS total_closing_stock, AVG(closing_stock) AS avg_total_closing_stock
FROM retail_inventory
GROUP BY category
HAVING total_sales > avg_total_sales AND total_closing_stock < avg_total_closing_stock;

# 20. Create a business priority list
SELECT product_id, category, sales, inventory,
    CASE
        WHEN sales > avg_sales AND inventory < avg_inventory THEN 'High Priority'
        WHEN sales > avg_sales OR inventory < avg_inventory THEN 'Medium Priority'
        ELSE 'Low Priority'
    END AS inventory_priority
FROM (
    SELECT product_id, category, ROUND(SUM(sales_amount),0) AS sales, SUM(closing_stock) AS inventory,
        (
            SELECT AVG(product_sales)
            FROM (
                SELECT SUM(sales_amount) AS product_sales
                FROM retail_inventory
                GROUP BY product_id
            ) AS sales_avg
        ) AS avg_sales,
        (
            SELECT AVG(product_inventory)
            FROM (
                SELECT SUM(closing_stock) AS product_inventory
                FROM retail_inventory
                GROUP BY product_id
            ) AS inventory_avg
        ) AS avg_inventory
    FROM retail_inventory
    GROUP BY product_id, category
) AS product_summary
ORDER BY
    CASE inventory_priority
        WHEN 'High Priority' THEN 1
        WHEN 'Medium Priority' THEN 2
        WHEN 'Low Priority' THEN 3
    END,
    sales DESC;