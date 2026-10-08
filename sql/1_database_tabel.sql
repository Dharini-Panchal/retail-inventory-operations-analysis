#----------------------------------- Create and use Database ----------------------------------- 
USE retail_inventory_analysis;

#----------------------------- Create table and import values from CSV file ---------------------
CREATE TABLE retail_inventory (
    transaction_id VARCHAR(50),
    transaction_date DATE,
    store_id VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    opening_stock INT,
    stock_received INT,
    units_sold INT,
    closing_stock INT,
    unit_price DECIMAL(10,2),
    sales_amount DECIMAL(12,2)
);
SELECT * FROM retail_inventory;
SHOW TABLES;
DESCRIBE retail_inventory;