
#----------------------------------- Data Cleaning and Exploration ----------------------------------- 
#Count the rows: Find out how many records are currently in retail_inventory.
SELECT COUNT(*) FROM retail_inventory;

# Check the columns: Find out what columns and data types exist in the table.
EXPLAIN retail_inventory;

# Find unique stores: Find all the different store names/IDs in the dataset.\
SELECT DISTINCT store_id FROM retail_inventory;

#Find unique products/categories: Find the different product categories in the dataset.
SELECT DISTINCT product_id, category FROM retail_inventory;

# Basic sales summary : Calculate: Total sales, Average sales, Minimum sales, Maximum sales
SELECT 
ROUND(SUM(sales_amount),2) AS Total_Sales, 
ROUND(AVG(sales_amount),2) AS Average_sales,
ROUND(MIN(sales_amount),2) AS Minimum_sales,
ROUND(MAX(sales_amount),2) AS Maximum_sales
FROM retail_inventory;

#Identify whitespace problems
SELECT store_id, COUNT(*) AS record_count
FROM retail_inventory
WHERE store_id <> TRIM(store_id)
GROUP BY store_id;

UPDATE retail_inventory
SET store_id = TRIM(store_id)
WHERE store_id <> TRIM(store_id);

#Identify whitespace problems
SELECT category, COUNT(*) AS record_count
FROM retail_inventory
WHERE category <> TRIM(category)
GROUP BY category;

UPDATE retail_inventory
SET category = TRIM(category)
WHERE category <> TRIM(category);

# Check for duplicate category names
SELECT category, COUNT(*) AS record_count
FROM retail_inventory
GROUP BY category
ORDER BY record_count DESC; 