-- Create a Database

CREATE DATABASE ecommerce_analytics;

USE ecommerce_analytics;


-- created tables and inserted columns using (Table Data Import Wizard)

SHOW TABLES;

DESCRIBE customers;

SELECT *
FROM customers
LIMIT 10;
 
 -- To check wheather all rows inserted
SELECT COUNT(*) AS total_rows
FROM customers;


-- Altered the first column name
ALTER TABLE customers
RENAME COLUMN `ï»¿customer_id` TO customer_id;

DESCRIBE customers;

-- to check duplicate if there duplicate customer ID

SELECT
    customer_id,
    COUNT(*) AS id_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- to check missing customer ID

SELECT COUNT(*) AS missing_customer_ids
FROM customers
WHERE customer_id IS NULL
   OR TRIM(customer_id) = '';
   
-- Changed data type from Text to Varchar because Text cant contain Primary key because of not fixed length
ALTER TABLE customers
MODIFY COLUMN customer_id VARCHAR(50) NOT NULL;

-- Added the primary key
ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

-- Added products table using Table Data Import wizard
SELECT COUNT(*) AS total_rows
FROM products;

DESCRIBE products;

-- Altered the first column name
ALTER TABLE products
RENAME COLUMN `ï»¿product_id` TO product_id;


-- To check repeated values
SELECT
    product_id,
    COUNT(*) AS id_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- to check missing values
SELECT COUNT(*) AS missing_product_ids
FROM products
WHERE product_id IS NULL
   OR TRIM(product_id) = '';



SELECT product_id
FROM products
LIMIT 10;


-- Altered data type from text to varchar
ALTER TABLE products
MODIFY COLUMN product_id VARCHAR(50) NOT NULL;


-- Added primary key
ALTER TABLE products
ADD PRIMARY KEY (product_id);


-- Try to create and insert orders table using Table Data inport wizard But it failed to import

-- there is 1250+ warning but it shows only 1000 warnings so updated number of warnings
SET max_error_count = 5000;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id            VARCHAR(20),
    customer_id         VARCHAR(20),
    order_date          DATE,
    order_month         VARCHAR(10),
    sales_channel       VARCHAR(30),
    device_type         VARCHAR(30),
    payment_method      VARCHAR(30),
    shipping_country    VARCHAR(50),
    shipping_region     VARCHAR(50),
    currency_code       VARCHAR(5),
    fx_rate_to_usd      DECIMAL(12,6),
    items_count         INT,
    gross_amount_local  DECIMAL(14,2),
    discount_local      DECIMAL(14,2),
    shipping_fee_local  DECIMAL(14,2),
    tax_local           DECIMAL(14,2),
    order_total_local   DECIMAL(14,2),
    order_total_usd     DECIMAL(14,2),
    order_status        VARCHAR(30),
    delivery_days       INT NULL
);


-- So inserted Using Local Variable

SHOW VARIABLES LIKE 'local_infile';

SELECT VERSION();

SET GLOBAL local_infile = 1;


TRUNCATE TABLE orders;


-- changed the datatype of date from text to date
LOAD DATA LOCAL INFILE 'H:/Ecommerce-Analytics-2024-2026/Data/Raw/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(order_id, customer_id, @order_date, order_month, sales_channel,
 device_type, payment_method, shipping_country, shipping_region,
 currency_code, fx_rate_to_usd, items_count, gross_amount_local,
 discount_local, shipping_fee_local, tax_local, order_total_local,
 order_total_usd, order_status, @delivery_days)
SET order_date    = STR_TO_DATE(@order_date, '%d-%m-%Y'),
    delivery_days = NULLIF(@delivery_days, '');
    
show tables;


-- To check number of rows , if date column is null or zero . Max , Min Date 
SELECT COUNT(*) AS total_rows,
       SUM(order_date IS NULL)      AS null_dates,
       SUM(YEAR(order_date) = 0)    AS zero_dates,
       MIN(order_date) AS first_date,
       MAX(order_date) AS last_date
FROM orders;

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;

-- same for order Items Table
truncate order_items;

LOAD DATA LOCAL INFILE 'H:/Ecommerce-Analytics-2024-2026/Data/Raw/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(@item_id, order_id, product_id, quantity, unit_price_local,
 line_discount_local, line_total_local, line_total_usd,
 unit_cost_usd, line_profit_usd, currency_code)
SET `ï»¿order_item_id` = @item_id;

ALTER TABLE order_items
RENAME COLUMN `ï»¿order_item_id` TO order_item_id;


-- check null and black space
SELECT
    COUNT(*) AS total_rows,
    COUNT(`order_item_id`) AS non_null_ids,
    COUNT(DISTINCT `order_item_id`) AS unique_ids
FROM order_items;


-- Changed  data types
ALTER TABLE order_items
MODIFY COLUMN `order_item_id` VARCHAR(50) NOT NULL;


-- Added Primary Key
ALTER TABLE orders
ADD PRIMARY KEY (order_id);



LOAD DATA LOCAL INFILE 'H:/Ecommerce-Analytics-2024-2026/Data/Raw/Returns.csv'
INTO TABLE returns
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    return_id,
    order_id,
    order_item_id,
    product_id,
    customer_id,
    return_date,
    return_month,
    days_to_return,
    quantity_returned,
    return_reason,
    item_condition,
    refund_amount_local,
    refund_amount_usd,
    restocked,
    currency_code
);

DESCRIBE returns;


ALTER TABLE returns
RENAME COLUMN `ï»¿return_id` TO return_id;


-- to check null and blank values
SELECT
    COUNT(*) AS total_rows,
    COUNT(return_id) AS non_null_ids,
    COUNT(DISTINCT return_id) AS unique_ids
FROM returns;


ALTER TABLE returns
MODIFY COLUMN return_id VARCHAR(50) NOT NULL;

ALTER TABLE returns
ADD PRIMARY KEY (return_id);



SELECT
    signup_date,
    first_order_date
FROM customers
LIMIT 10;


-- to change text to date datatype
UPDATE returns
SET return_date = STR_TO_DATE(return_date, '%d-%m-%Y');

SELECT
    return_date,
    return_month
FROM returns
LIMIT 10;


-- to change text to date datatype
UPDATE customers
SET signup_date = STR_TO_DATE(signup_date, '%d-%m-%Y');

UPDATE customers
SET first_order_date = STR_TO_DATE(first_order_date, '%d-%m-%Y')
WHERE first_order_date IS NOT NULL
  AND first_order_date <> '';
  
SELECT
    signup_date,
    first_order_date
FROM customers
LIMIT 10;


ALTER TABLE customers
MODIFY COLUMN signup_date DATE;

ALTER TABLE customers
MODIFY COLUMN first_order_date DATE;



SELECT COUNT(*) AS empty_dates
FROM customers
WHERE first_order_date = '';


-- Changed blank values to null values
UPDATE customers
SET first_order_date = NULL
WHERE first_order_date = '';

ALTER TABLE customers
MODIFY COLUMN first_order_date DATE;

SELECT
    return_date,
    return_month
FROM returns
LIMIT 10;

SELECT COUNT(*) AS empty_dates
FROM returns
WHERE return_date = '';


-- to change text to date datatype
ALTER TABLE returns
MODIFY COLUMN return_date DATE;

DESCRIBE returns;

DESCRIBE products;
DESCRIBE order_items;


SELECT
    launch_date,
    COUNT(*) AS total
FROM products
GROUP BY launch_date
ORDER BY launch_date asc
LIMIT 15;


-- to change text to date datatype
UPDATE products
SET launch_date = STR_TO_DATE(launch_date, '%d-%m-%Y')
WHERE launch_date IS NOT NULL
  AND launch_date <> '';
  
  
SELECT COUNT(*) AS empty_dates
FROM products
WHERE launch_date = '';


-- to change text to date datatype
ALTER TABLE products
MODIFY COLUMN launch_date DATE;


DESCRIBE products;


-- to change text to varchar datatype because of going to use foreign key . they should have data types
ALTER TABLE order_items
MODIFY COLUMN order_id VARCHAR(20);


-- to change text to varchar datatype because of going to use foreign key . they should have data types
ALTER TABLE order_items
MODIFY COLUMN product_id VARCHAR(50);


-- To check unmatched order_id in orders thats not in customers
SELECT COUNT(*) AS unmatched_orders
FROM order_items oi
left JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- To check unmatched producct_id in orders thats not in products
SELECT COUNT(*) AS unmatched_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

DESCRIBE returns;


ALTER TABLE returns
MODIFY COLUMN order_id VARCHAR(20);

ALTER TABLE returns
MODIFY COLUMN order_item_id VARCHAR(50);

ALTER TABLE returns
MODIFY COLUMN product_id VARCHAR(50);

DESCRIBE customers;

ALTER TABLE returns
MODIFY COLUMN customer_id VARCHAR(50);


-- To check unmatched customer_id in cusomers thats not in returns
SELECT COUNT(*) AS unmatched_customers
FROM returns r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- To check unmatched order_id in orders thats not in returns
SELECT COUNT(*) AS unmatched_orders
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- To check unmatched order_item_id in orders thats not in order items
SELECT COUNT(*) AS unmatched_order_items
FROM returns r
LEFT JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;


-- To check unmatched product_id in products thats not in returns
SELECT COUNT(*) AS unmatched_products
FROM returns r
LEFT JOIN products p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL;


DESCRIBE returns;


-- Added Foriegn Key

ALTER TABLE returns
ADD CONSTRAINT fk_returns_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id),
ADD CONSTRAINT fk_returns_order_items
FOREIGN KEY (order_item_id)
REFERENCES order_items(order_item_id),
ADD CONSTRAINT fk_returns_products
FOREIGN KEY (product_id)
REFERENCES products(product_id),
ADD CONSTRAINT fk_returns_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);


-- Added foriegn Key
ALTER TABLE order_items

ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id)
REFERENCES orders(order_id),

ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id)
REFERENCES products(product_id);

DESCRIBE orders;

SHOW CREATE TABLE order_items;

ALTER TABLE orders
MODIFY COLUMN customer_id VARCHAR(50);

SELECT COUNT(*) AS unmatched_customers
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL
  AND c.customer_id IS NULL;
  
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);



-- To check if all forign Key Allocated
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'ecommerce_analytics'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;