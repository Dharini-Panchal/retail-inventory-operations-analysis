#----------------------------------- SubQuery -----------------------------------
# Which products have sales above the average product sales?
SELECT product_id, SUM(sales_amount) AS total_sales
FROM retail_inventory
GROUP BY product_id
HAVING total_sales > 
(
	SELECT AVG(total_sales)
	FROM (
		SELECT product_id, SUM(sales_amount) AS total_sales
		FROM retail_inventory
		GROUP BY product_id
	) AS product_sales
);

# Which products have zero inventory but generated sales?
SELECT product_id, category, closing_stock, sales_amount
FROM retail_inventory 
WHERE closing_stock = 0 
AND sales_amount > 0;

# Which categories have above-average sales but below-average inventory?   
SELECT 
	category, 
	SUM(sales_amount) AS total_sales, 
	SUM(closing_stock) AS inventory
FROM retail_inventory
GROUP BY category
HAVING total_sales > (
	SELECT AVG(sales_amount) 
    FROM retail_inventory
) AND inventory < (
	SELECT AVG(closing_stock) 
    FROM retail_inventory
);