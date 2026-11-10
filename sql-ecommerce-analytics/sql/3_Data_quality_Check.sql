-- To check duplicates
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1;

SELECT
    return_id,
    COUNT(*) AS duplicate_count
FROM returns
GROUP BY return_id
HAVING COUNT(*) > 1;


-- To check Null values or missing values in cusomers
SELECT
    COUNT(*) AS total_rows,
    SUM(customer_name IS NULL) AS missing_names,
    SUM(country IS NULL) AS missing_countries,
    SUM(region IS NULL) AS missing_regions,
    SUM(currency_code IS NULL) AS missing_currency,
    SUM(signup_date IS NULL) AS missing_signup_dates,
    SUM(acquisition_channel IS NULL) AS missing_channels,
    SUM(preferred_device IS NULL) AS missing_devices,
    SUM(newsletter_opt_in IS NULL) AS missing_newsletter,
    SUM(first_order_date IS NULL) AS missing_first_order_dates,
    SUM(lifetime_orders IS NULL) AS missing_lifetime_orders,
    SUM(lifetime_spend_usd IS NULL) AS missing_lifetime_spend
FROM customers;


-- there are 34 null values . some might created account but not odered so  some might be null lets check
SELECT
    c.customer_id,
    c.customer_name,
    c.first_order_date,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE c.first_order_date IS NULL
GROUP BY
    c.customer_id,
    c.customer_name,
    c.first_order_date;
    
    
-- 6 members first order dates in missing . so we will use thier earliest ordre date using min() to fill it
SELECT
    c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS actual_first_order_date,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE c.first_order_date IS NULL
GROUP BY
    c.customer_id,
    c.customer_name;
  
  
-- update those 6 null values
UPDATE customers c
JOIN (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
) o
    ON c.customer_id = o.customer_id
SET c.first_order_date = o.first_order_date
WHERE c.first_order_date IS NULL;

-- to check that 6 rows updated?
SELECT COUNT(*) AS missing_first_order_dates
FROM customers
WHERE first_order_date IS NULL;


-- to check null values or missing values in products
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(product_name) AS missing_product_names,
    COUNT(*) - COUNT(category) AS missing_categories,
    COUNT(*) - COUNT(subcategory) AS missing_subcategories,
    COUNT(*) - COUNT(brand) AS missing_brands,
    COUNT(*) - COUNT(list_price_usd) AS missing_list_prices,
    COUNT(*) - COUNT(unit_cost_usd) AS missing_unit_costs,
    COUNT(*) - COUNT(weight_kg) AS missing_weights,
    COUNT(*) - COUNT(launch_date) AS missing_launch_dates,
    COUNT(*) - COUNT(is_active) AS missing_active_status
FROM products;


-- To check null or missing values in ordres
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(order_id) AS missing_order_ids,
    COUNT(*) - COUNT(customer_id) AS missing_customer_ids,
    COUNT(*) - COUNT(order_date) AS missing_order_dates,
    COUNT(*) - COUNT(order_status) AS missing_order_statuses,
    COUNT(*) - COUNT(gross_amount_local) AS missing_gross_amounts,
    COUNT(*) - COUNT(discount_local) AS missing_discounts,
    COUNT(*) - COUNT(shipping_fee_local) AS missing_shipping_fees,
    COUNT(*) - COUNT(tax_local) AS missing_taxes,
    COUNT(*) - COUNT(order_total_local) AS missing_order_totals,
    COUNT(*) - COUNT(order_total_usd) AS missing_order_totals_usd,
    COUNT(*) - COUNT(fx_rate_to_usd) AS missing_exchange_rates
FROM orders;


-- To check missing values in order items
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(order_item_id) AS missing_item_ids,
    COUNT(*) - COUNT(order_id) AS missing_order_ids,
    COUNT(*) - COUNT(product_id) AS missing_product_ids,
    COUNT(*) - COUNT(quantity) AS missing_quantities,
    COUNT(*) - COUNT(unit_price_local) AS missing_unit_prices,
    COUNT(*) - COUNT(line_discount_local) AS missing_discounts,
    COUNT(*) - COUNT(line_total_local) AS missing_line_totals,
    COUNT(*) - COUNT(line_total_usd) AS missing_line_totals_usd,
    COUNT(*) - COUNT(unit_cost_usd) AS missing_unit_costs,
    COUNT(*) - COUNT(line_profit_usd) AS missing_profits,
    COUNT(*) - COUNT(currency_code) AS missing_currency_codes
FROM order_items;


-- To check missing values in returns

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(return_id) AS missing_return_ids,
    COUNT(*) - COUNT(order_id) AS missing_order_ids,
    COUNT(*) - COUNT(order_item_id) AS missing_item_ids,
    COUNT(*) - COUNT(product_id) AS missing_product_ids,
    COUNT(*) - COUNT(customer_id) AS missing_customer_ids,
    COUNT(*) - COUNT(return_date) AS missing_return_dates,
    COUNT(*) - COUNT(quantity_returned) AS missing_quantities,
    COUNT(*) - COUNT(return_reason) AS missing_reasons,
    COUNT(*) - COUNT(item_condition) AS missing_conditions,
    COUNT(*) - COUNT(refund_amount_local) AS missing_refunds_local,
    COUNT(*) - COUNT(refund_amount_usd) AS missing_refunds_usd,
    COUNT(*) - COUNT(restocked) AS missing_restocked_status,
    COUNT(*) - COUNT(currency_code) AS missing_currency_codes
FROM returns;


-- To check empty strings or blank space in customers
SELECT
    COUNT(*) AS total_rows,
    SUM(TRIM(customer_id) = '') AS empty_customer_ids,
    SUM(TRIM(customer_name) = '') AS empty_customer_names,
    SUM(TRIM(country) = '') AS empty_countries,
    SUM(TRIM(region) = '') AS empty_regions,
    SUM(TRIM(currency_code) = '') AS empty_currency_codes,
    SUM(TRIM(acquisition_channel) = '') AS empty_acquisition_channels,
    SUM(TRIM(preferred_device) = '') AS empty_preferred_devices,
    SUM(TRIM(newsletter_opt_in) = '') AS empty_newsletter_statuses
FROM customers;


-- To check empty strings or blank space in products
SELECT
    COUNT(*) AS total_rows,
    SUM(TRIM(product_id) = '') AS empty_product_ids,
    SUM(TRIM(product_name) = '') AS empty_product_names,
    SUM(TRIM(category) = '') AS empty_categories,
    SUM(TRIM(subcategory) = '') AS empty_subcategories,
    SUM(TRIM(brand) = '') AS empty_brands,
    SUM(TRIM(is_active) = '') AS empty_active_statuses
FROM products;


-- To check empty strings or blank space in orders
SELECT
    COUNT(*) AS total_rows,
    SUM(TRIM(order_id) = '') AS empty_order_ids,
    SUM(TRIM(customer_id) = '') AS empty_customer_ids,
    SUM(TRIM(order_status) = '') AS empty_order_statuses,
    SUM(TRIM(currency_code) = '') AS empty_currency_codes
FROM orders;


-- To check empty strings or blank space in order items
SELECT
    COUNT(*) AS total_rows,
    SUM(TRIM(order_item_id) = '') AS empty_item_ids,
    SUM(TRIM(order_id) = '') AS empty_order_ids,
    SUM(TRIM(product_id) = '') AS empty_product_ids,
    SUM(TRIM(currency_code) = '') AS empty_currency_codes
FROM order_items;


-- To check empty strings or blank space in returns
SELECT
    COUNT(*) AS total_rows,
    SUM(TRIM(return_id) = '') AS empty_return_ids,
    SUM(TRIM(order_id) = '') AS empty_order_ids,
    SUM(TRIM(order_item_id) = '') AS empty_item_ids,
    SUM(TRIM(product_id) = '') AS empty_product_ids,
    SUM(TRIM(customer_id) = '') AS empty_customer_ids,
    SUM(TRIM(return_reason) = '') AS empty_return_reasons,
    SUM(TRIM(item_condition) = '') AS empty_item_conditions,
    SUM(TRIM(restocked) = '') AS empty_restocked_statuses,
    SUM(TRIM(currency_code) = '') AS empty_currency_codes
FROM returns;


-- To check negative Numbers
SELECT
    COUNT(*) AS total_rows,
    SUM(quantity <= 0) AS invalid_quantities,
    SUM(unit_price_local < 0) AS negative_unit_prices,
    SUM(line_discount_local < 0) AS negative_discounts,
    SUM(line_total_local < 0) AS negative_line_totals,
    SUM(line_total_usd < 0) AS negative_line_totals_usd,
    SUM(unit_cost_usd < 0) AS negative_unit_costs,
    SUM(line_profit_usd < 0) AS negative_profits
FROM order_items;


-- investigate the 484 records
SELECT
    order_item_id,
    product_id,
    quantity,
    unit_cost_usd,
    line_total_usd,
    line_profit_usd
FROM order_items
WHERE line_profit_usd < 0
LIMIT 20;


-- I want to check whether all 484 negative-profit records have correctly calculated profits
SELECT
    order_item_id,
    quantity,
    unit_cost_usd,
    line_total_usd,
    line_profit_usd,
    ROUND(
        line_total_usd - (unit_cost_usd * quantity),
        2
    ) AS expected_profit
FROM order_items
WHERE line_profit_usd < 0
LIMIT 20;


-- We have verified the first 20 negative-profit records. We haven't yet verified all 484. Let's check all 484 at once.
SELECT
    COUNT(*) AS negative_profit_records,
    SUM(
        ROUND(
            line_profit_usd -
            (line_total_usd - (unit_cost_usd * quantity)),
            2
        ) <> 0
    ) AS incorrect_profit_calculations
FROM order_items
WHERE line_profit_usd < 0;


-- Find the two incorrect calculations  
SELECT
    order_item_id,
    quantity,
    unit_cost_usd,
    line_total_usd,
    line_profit_usd,
    ROUND(
        line_total_usd - (unit_cost_usd * quantity),
        2
    ) AS expected_profit,
    ROUND(
        line_profit_usd -
        (line_total_usd - (unit_cost_usd * quantity)),
        2
    ) AS difference
FROM order_items
WHERE line_profit_usd < 0
AND ROUND(
        line_profit_usd -
        (line_total_usd - (unit_cost_usd * quantity)),
        2
    ) <> 0;
    
   
   
-- inspect the two records with more precision
SELECT
    order_item_id,
    quantity,
    unit_cost_usd,
    line_total_usd,
    line_profit_usd,
    (line_total_usd - (unit_cost_usd * quantity))
        AS unrounded_expected_profit
FROM order_items
WHERE order_item_id IN ('ITM-004608', 'ITM-016650');


-- to checking the orders table for invalid numeric values
SELECT
    COUNT(*) AS total_rows,
    SUM(items_count <= 0) AS invalid_items_count,
    SUM(gross_amount_local < 0) AS negative_gross_amount,
    SUM(discount_local < 0) AS negative_discount,
    SUM(shipping_fee_local < 0) AS negative_shipping,
    SUM(tax_local < 0) AS negative_tax,
    SUM(order_total_local < 0) AS negative_order_total,
    SUM(order_total_usd < 0) AS negative_order_total_usd,
    SUM(fx_rate_to_usd <= 0) AS invalid_exchange_rates
FROM orders;


-- Check product numeric values
SELECT
    COUNT(*) AS total_products,
    SUM(list_price_usd < 0) AS negative_list_prices,
    SUM(unit_cost_usd < 0) AS negative_unit_costs,
    SUM(weight_kg < 0) AS negative_weights
FROM products;


-- Check return numeric value

SELECT
    COUNT(*) AS total_returns,
    SUM(days_to_return < 0) AS negative_return_days,
    SUM(quantity_returned <= 0) AS invalid_return_quantities,
    SUM(refund_amount_local < 0) AS negative_refunds_local,
    SUM(refund_amount_usd < 0) AS negative_refunds_usd
FROM returns;


-- Validate order item totals

SELECT
    COUNT(*) AS total_records,
    SUM(
        ROUND(
            line_total_local -
            (quantity * unit_price_local - line_discount_local),
            2
        ) <> 0
    ) AS incorrect_line_totals
FROM order_items;


-- Validate order-level gross amounts
-- What we're checking Whether the gross amount stored in orders matches the gross amount reconstructed from order_items.
SELECT
    COUNT(*) AS total_orders,
    SUM(
        ROUND(
            o.gross_amount_local - COALESCE(i.calculated_gross, 0),
            2
        ) <> 0
    ) AS mismatched_orders
FROM orders o
LEFT JOIN (
    SELECT
        order_id,
        SUM(line_total_local + line_discount_local) AS calculated_gross
    FROM order_items
    GROUP BY order_id
) i
    ON o.order_id = i.order_id;
    
    
-- Validate order discounts
SELECT
    COUNT(*) AS total_orders,
    SUM(
        ROUND(
            o.discount_local - COALESCE(i.calculated_discount, 0),
            2
        ) <> 0
    ) AS mismatched_orders
FROM orders o
LEFT JOIN (
    SELECT
        order_id,
        SUM(line_discount_local) AS calculated_discount
    FROM order_items
    GROUP BY order_id
) i
    ON o.order_id = i.order_id;
    
    

-- Validate item quantities
SELECT
    COUNT(*) AS total_orders,
    SUM(
        o.items_count <> COALESCE(i.calculated_quantity, 0)
    ) AS mismatched_orders
FROM orders o
LEFT JOIN (
    SELECT
        order_id,
        SUM(quantity) AS calculated_quantity
    FROM order_items
    GROUP BY order_id
) i
    ON o.order_id = i.order_id;
    
    
-- Validate the final order total
SELECT
    COUNT(*) AS total_orders,
    SUM(
        ROUND(
            order_total_local -
            (gross_amount_local - discount_local
             + shipping_fee_local + tax_local),
            2
        ) <> 0
    ) AS mismatched_orders
FROM orders;


-- Validate USD currency conversion
SELECT
    COUNT(*) AS total_orders,
    SUM(
        ROUND(
            order_total_usd -
            (order_total_local / fx_rate_to_usd),
            2
        ) <> 0
    ) AS mismatched_orders
FROM orders;


-- Inspect the 44 mismatched orders
SELECT
    order_id,
    currency_code,
    order_total_local,
    fx_rate_to_usd,
    order_total_usd,
    ROUND(order_total_local / fx_rate_to_usd, 2)
        AS expected_usd,
    ROUND(
        order_total_usd -
        (order_total_local / fx_rate_to_usd),
        4
    ) AS difference
FROM orders
WHERE ROUND(
    order_total_usd -
    (order_total_local / fx_rate_to_usd),
    2
) <> 0
LIMIT 20;


-- Let's check all 44 records using a one-cent tolerance
SELECT
    COUNT(*) AS total_mismatches,
    SUM(
        ABS(
            order_total_usd -
            (order_total_local / fx_rate_to_usd)
        ) > 0.01
    ) AS differences_over_one_cent
FROM orders;


-- Validate returns against order status
SELECT
    COUNT(*) AS total_returns,
    SUM(o.order_status <> 'Delivered') AS invalid_returns
FROM returns r
JOIN orders o
    ON r.order_id = o.order_id;
    
    
-- Validate returned quantities
SELECT
    COUNT(*) AS total_returns,
    SUM(
        r.quantity_returned > oi.quantity
    ) AS invalid_return_quantities
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id;
    
    
-- Validate refund amounts
SELECT
    COUNT(*) AS total_returns,
    SUM(
        r.refund_amount_usd > oi.line_total_usd
    ) AS excessive_refunds
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id;
    
    
-- Validate customer signup dates
SELECT
    COUNT(*) AS total_orders,
    SUM(
        o.order_date < c.signup_date
    ) AS orders_before_signup
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;
    
    
-- Validate customers' first order dates
SELECT
    COUNT(*) AS customers_with_orders,
    SUM(
        c.first_order_date <> o.first_order_date
    ) AS mismatched_first_order_dates
FROM customers c
JOIN (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
) o
    ON c.customer_id = o.customer_id;
    
    
-- Inspect the mismatches
SELECT
    c.customer_id,
    c.customer_name,
    c.first_order_date AS recorded_first_order,
    o.actual_first_order
FROM customers c
JOIN (
    SELECT
        customer_id,
        MIN(order_date) AS actual_first_order
    FROM orders
    GROUP BY customer_id
) o
    ON c.customer_id = o.customer_id
WHERE c.first_order_date <> o.actual_first_order
ORDER BY c.customer_id
LIMIT 20;


-- Correct the first-order dates
UPDATE customers c
JOIN (
    SELECT
        customer_id,
        MIN(order_date) AS actual_first_order
    FROM orders
    GROUP BY customer_id
) o
    ON c.customer_id = o.customer_id
SET c.first_order_date = o.actual_first_order
WHERE c.first_order_date <> o.actual_first_order;


-- Verify
SELECT COUNT(*) AS mismatched_dates
FROM customers c
JOIN (
    SELECT customer_id, MIN(order_date) AS actual_first_order
    FROM orders
    GROUP BY customer_id
) o ON c.customer_id = o.customer_id
WHERE c.first_order_date <> o.actual_first_order;

-- Validate customer lifetime_orders
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Compate LifeTime Orders
SELECT
    COUNT(*) AS total_customers,
    SUM(c.lifetime_orders <> COALESCE(o.actual_orders, 0))
        AS mismatched_customers
FROM customers c
LEFT JOIN (
    SELECT
        customer_id,
        COUNT(*) AS actual_orders
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
) o
    ON c.customer_id = o.customer_id;
    
    
-- Validate lifetime_spend_usd
SELECT
    COUNT(*) AS total_customers,
    SUM(
        ABS(
            c.lifetime_spend_usd - COALESCE(o.actual_spend, 0)
        ) > 0.01
    ) AS mismatched_customers
FROM customers c
LEFT JOIN (
    SELECT
        customer_id,
        SUM(order_total_usd) AS actual_spend
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
) o
    ON c.customer_id = o.customer_id;
    
    
-- Validate returns relationships
SELECT
    COUNT(*) AS total_returns,
    SUM(
        r.order_id <> oi.order_id
        OR r.product_id <> oi.product_id
    ) AS mismatched_returns
FROM returns r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id;
    
    
-- Validate the customer associated with each return
SELECT
    COUNT(*) AS total_returns,
    SUM(r.customer_id <> o.customer_id) AS mismatched_customers
FROM returns r
JOIN orders o
    ON r.order_id = o.order_id;
    
    
-- Validate return dates
SELECT
    COUNT(*) AS total_returns,
    SUM(r.return_date < o.order_date) AS returns_before_order
FROM returns r
JOIN orders o
    ON r.order_id = o.order_id;
    
    
-- Validate days_to_return
SELECT
    COUNT(*) AS total_returns,
    SUM(
        r.days_to_return <> DATEDIFF(r.return_date, o.order_date)
    ) AS mismatched_return_days
FROM returns r
JOIN orders o
    ON r.order_id = o.order_id;
    
    
-- Product launch dates
SELECT
    COUNT(*) AS total_order_items,
    SUM(o.order_date < p.launch_date) AS orders_before_product_launch
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id;
