-- Validate Table Row Counts
SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'returns', COUNT(*)
FROM returns;



-- Check for Duplicate Primary Keys
SELECT
    'customers' AS table_name,
    COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_ids
FROM customers

UNION ALL

SELECT
    'products',
    COUNT(*) - COUNT(DISTINCT product_id)
FROM products

UNION ALL

SELECT
    'orders',
    COUNT(*) - COUNT(DISTINCT order_id)
FROM orders

UNION ALL

SELECT
    'order_items',
    COUNT(*) - COUNT(DISTINCT order_item_id)
FROM order_items

UNION ALL

SELECT
    'returns',
    COUNT(*) - COUNT(DISTINCT return_id)
FROM returns;


-- Check Missing Values (NULLs)
SELECT
    COUNT(*) AS total_rows,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(country IS NULL) AS missing_country,
    SUM(signup_date IS NULL) AS missing_signup_date,
    SUM(first_order_date IS NULL) AS missing_first_order_date
FROM customers;



-- Validate the Products Table
SELECT
    COUNT(*) AS total_rows,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(product_name IS NULL) AS missing_product_name,
    SUM(category IS NULL) AS missing_category,
    SUM(launch_date IS NULL) AS missing_launch_date
FROM products;


-- Validate the Orders Table
SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(order_total_usd IS NULL) AS missing_order_total,
    SUM(currency_code IS NULL) AS missing_currency,
    SUM(order_status IS NULL) AS missing_order_status
FROM orders;


-- Validate the Order Items Table
SELECT
    COUNT(*) AS total_rows,
    SUM(order_item_id IS NULL) AS missing_order_item_id,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(quantity IS NULL) AS missing_quantity,
    SUM(line_total_usd IS NULL) AS missing_line_total
FROM order_items;


-- Validate the Returns Table
SELECT
    COUNT(*) AS total_rows,
    SUM(return_id IS NULL) AS missing_return_id,
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(product_id IS NULL) AS missing_product_id,
    SUM(customer_id IS NULL) AS missing_customer_id,
    SUM(return_date IS NULL) AS missing_return_date,
    SUM(quantity_returned IS NULL) AS missing_quantity,
    SUM(return_reason IS NULL) AS missing_return_reason,
    SUM(refund_amount_usd IS NULL) AS missing_refund
FROM returns;


-- Check Invalid Numeric Values
SELECT
    COUNT(*) AS total_rows,

    SUM(quantity = 0) AS zero_quantity,
    SUM(quantity < 0) AS negative_quantity,

    SUM(line_total_usd = 0) AS zero_line_total,
    SUM(line_total_usd < 0) AS negative_line_total

FROM order_items;


-- Validate Order Financial Amounts
SELECT
    COUNT(*) AS total_orders,

    SUM(gross_amount_local < 0) AS negative_gross,
    SUM(discount_local < 0) AS negative_discount,
    SUM(shipping_fee_local < 0) AS negative_shipping,
    SUM(tax_local < 0) AS negative_tax,
    SUM(order_total_local < 0) AS negative_order_total,
    SUM(order_total_usd < 0) AS negative_order_total_usd,

    SUM(fx_rate_to_usd <= 0) AS invalid_exchange_rate

FROM orders;


-- Validate Returns Financial Values
SELECT
    COUNT(*) AS total_returns,

    SUM(quantity_returned = 0) AS zero_quantity,
    SUM(quantity_returned < 0) AS negative_quantity,

    SUM(refund_amount_usd = 0) AS zero_refund,
    SUM(refund_amount_usd < 0) AS negative_refund,

    SUM(days_to_return < 0) AS negative_return_days

FROM returns;

-- Check Date Consistency
SELECT
    COUNT(*) AS total_customers,

    SUM(first_order_date < signup_date)
        AS first_order_before_signup,

    SUM(first_order_date IS NOT NULL
        AND first_order_date > CURDATE())
        AS future_first_order_dates

FROM customers;


-- Validate Order Dates
SELECT
    COUNT(*) AS total_orders,

    SUM(o.order_date < c.signup_date)
        AS orders_before_signup,

    SUM(o.order_date > CURDATE())
        AS future_order_dates

FROM orders o
INNER JOIN customers c
    ON o.customer_id = c.customer_id;
    
    
-- Validate Return Dates
SELECT
    COUNT(*) AS total_returns,

    SUM(r.return_date < o.order_date)
        AS returns_before_order,

    SUM(r.return_date > CURDATE())
        AS future_return_dates

FROM returns r
INNER JOIN orders o
    ON r.order_id = o.order_id;
    

-- Validate Return Duration
SELECT
    COUNT(*) AS total_returns,

    SUM(
        days_to_return <> DATEDIFF(return_date, order_date)
    ) AS duration_mismatches,

    MIN(DATEDIFF(return_date, order_date))
        AS minimum_actual_days,

    MAX(DATEDIFF(return_date, order_date))
        AS maximum_actual_days

FROM returns r
INNER JOIN orders o
    ON r.order_id = o.order_id;
    
    
    
-- Validate Order Item Counts
SELECT
    COUNT(*) AS total_orders,

    SUM(
        o.items_count <> COALESCE(oi.actual_item_count, 0)
    ) AS item_count_mismatches

FROM orders o
LEFT JOIN (
    SELECT
        order_id,
        COUNT(*) AS actual_item_count
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id;
    
    
-- Check What items_count Represents
SELECT
    COUNT(*) AS total_orders,

    SUM(o.items_count = COALESCE(oi.item_lines, 0))
        AS matches_item_lines,

    SUM(o.items_count = COALESCE(oi.total_quantity, 0))
        AS matches_total_quantity,

    SUM(o.items_count <> COALESCE(oi.item_lines, 0))
        AS mismatches_item_lines,

    SUM(o.items_count <> COALESCE(oi.total_quantity, 0))
        AS mismatches_total_quantity

FROM orders o
LEFT JOIN (
    SELECT
        order_id,
        COUNT(*) AS item_lines,
        SUM(quantity) AS total_quantity
    FROM order_items
    GROUP BY order_id
) oi
    ON o.order_id = oi.order_id;
    
    
-- Validate First Order Date Against Actual Orders
WITH actual_first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS actual_first_order_date
    FROM orders
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS customers_with_orders,

    SUM(
        c.first_order_date <> a.actual_first_order_date
    ) AS first_order_date_mismatches

FROM customers c
INNER JOIN actual_first_orders a
    ON c.customer_id = a.customer_id;
    
    
-- Validate Order Status Values
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Validate Product Categories
SELECT
    category,
    COUNT(*) AS total_products
FROM products
GROUP BY category
ORDER BY total_products DESC;


-- Validate Payment Methods
SELECT
    payment_method,
    COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;


-- Validate Sales Channels
SELECT
    sales_channel,
    COUNT(*) AS total_orders
FROM orders
GROUP BY sales_channel
ORDER BY total_orders DESC;


-- Validate Device Types
SELECT
    device_type,
    COUNT(*) AS total_orders
FROM orders
GROUP BY device_type
ORDER BY total_orders DESC;


-- Validate Return Reasons
SELECT
    return_reason,
    COUNT(*) AS total_returns
FROM returns
GROUP BY return_reason
ORDER BY total_returns DESC;


-- Validate Item Conditions
SELECT
    item_condition,
    COUNT(*) AS total_returns
FROM returns
GROUP BY item_condition
ORDER BY total_returns DESC;


-- Validate Restocked Values
SELECT
    restocked,
    COUNT(*) AS total_returns
FROM returns
GROUP BY restocked
ORDER BY total_returns DESC;


-- Validate Currency Codes
SELECT
    currency_code,
    COUNT(*) AS total_returns
FROM returns
GROUP BY currency_code
ORDER BY total_returns DESC;


-- Final Foreign Key Validation
SELECT
    'Orders → Customers' AS relationship_name,
    COUNT(*) AS unmatched_records
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'Order Items → Orders',
    COUNT(*)
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'Order Items → Products',
    COUNT(*)
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'Returns → Orders',
    COUNT(*)
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'Returns → Products',
    COUNT(*)
FROM returns r
LEFT JOIN products p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'Returns → Customers',
    COUNT(*)
FROM returns r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;