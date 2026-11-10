-- Overall Sales Performance
SELECT
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(order_total_usd), 2) AS total_revenue,
    ROUND(AVG(order_total_usd), 2) AS average_order_value,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS latest_order_date
FROM orders
WHERE order_status <> 'Cancelled';


-- Monthly Revenue Analysis
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_total_usd), 2) AS monthly_revenue,
    ROUND(AVG(order_total_usd), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;


-- Year-over-Year (YoY) Revenue Growth
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS order_month,
        SUM(order_total_usd) AS monthly_revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),

revenue_comparison AS (
    SELECT
        order_month,
        monthly_revenue,
        LAG(monthly_revenue, 12) OVER (
            ORDER BY order_month
        ) AS previous_year_revenue
    FROM monthly_sales
)

SELECT
    order_month,
    ROUND(monthly_revenue, 2) AS current_revenue,
    ROUND(previous_year_revenue, 2) AS previous_year_revenue,
    ROUND(
        (monthly_revenue - previous_year_revenue)
        * 100.0 / previous_year_revenue,
        2
    ) AS yoy_growth_percentage
FROM revenue_comparison
ORDER BY order_month;


-- Quarterly Revenue Analysis
SELECT
    YEAR(order_date) AS order_year,
    QUARTER(order_date) AS order_quarter,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_total_usd), 2) AS quarterly_revenue,
    ROUND(AVG(order_total_usd), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY
    YEAR(order_date),
    QUARTER(order_date)
ORDER BY
    order_year,
    order_quarter;
    
    
-- Quarterly Revenue Growth
WITH quarterly_sales AS (
    SELECT
        YEAR(order_date) AS order_year,
        QUARTER(order_date) AS order_quarter,
        SUM(order_total_usd) AS quarterly_revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY
        YEAR(order_date),
        QUARTER(order_date)
),

quarterly_comparison AS (
    SELECT
        order_year,
        order_quarter,
        quarterly_revenue,
        LAG(quarterly_revenue) OVER (
            ORDER BY order_year, order_quarter
        ) AS previous_quarter_revenue
    FROM quarterly_sales
)

SELECT
    order_year,
    order_quarter,
    ROUND(quarterly_revenue, 2) AS current_revenue,
    ROUND(previous_quarter_revenue, 2) AS previous_revenue,
    ROUND(
        (quarterly_revenue - previous_quarter_revenue)
        * 100.0 / previous_quarter_revenue,
        2
    ) AS quarter_over_quarter_growth
FROM quarterly_comparison
ORDER BY order_year, order_quarter;


-- Sales Performance by Country
SELECT
    c.country,
    COUNT(o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    ROUND(SUM(o.order_total_usd), 2) AS total_revenue,
    ROUND(AVG(o.order_total_usd), 2) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.country
ORDER BY total_revenue DESC;


-- Sales Performance by Product Category
SELECT
    p.category,
    COUNT(oi.order_item_id) AS total_items_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.quantity), 0) AS total_quantity_sold,
    ROUND(SUM(oi.line_total_usd), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Top 10 Best-Selling Products
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.line_total_usd), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_revenue DESC
LIMIT 10;


-- Top 10 Products by Quantity Sold
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS total_quantity_sold,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.line_total_usd), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY total_quantity_sold DESC
LIMIT 10;


-- Order Status Analysis
SELECT
    order_status,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_total_usd), 2) AS total_order_value,
    ROUND(AVG(order_total_usd), 2) AS average_order_value,
    ROUND(
        COUNT(order_id) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS order_percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Monthly Order Cancellation Analysis
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(
        CASE
            WHEN order_status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,
    ROUND(
        SUM(
            CASE
                WHEN order_status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(order_id),
        2
    ) AS cancellation_percentage
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month;


-- Return Rate Analysis by Product Category
WITH returns_by_item AS (
    SELECT
        order_item_id,
        SUM(quantity_returned) AS total_quantity_returned,
        COUNT(return_id) AS total_return_records
    FROM returns
    GROUP BY order_item_id
)

SELECT
    p.category,

    SUM(oi.quantity) AS total_quantity_sold,

    SUM(
        COALESCE(r.total_quantity_returned, 0)
    ) AS total_quantity_returned,

    SUM(
        COALESCE(r.total_return_records, 0)
    ) AS total_return_records,

    ROUND(
        SUM(COALESCE(r.total_quantity_returned, 0))
        * 100.0 / SUM(oi.quantity),
        2
    ) AS return_rate_percentage

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

JOIN orders o
    ON oi.order_id = o.order_id

LEFT JOIN returns_by_item r
    ON oi.order_item_id = r.order_item_id

WHERE o.order_status <> 'Cancelled'

GROUP BY p.category

ORDER BY return_rate_percentage DESC;


-- Return Reasons Analysis
SELECT
    return_reason,
    COUNT(return_id) AS total_return_records,
    SUM(quantity_returned) AS total_quantity_returned,
    ROUND(SUM(refund_amount_usd), 2) AS total_refund_usd,
    ROUND(
        COUNT(return_id) * 100.0 /
        (SELECT COUNT(*) FROM returns),
        2
    ) AS return_percentage

FROM returns

GROUP BY return_reason

ORDER BY total_return_records DESC;


-- Return Analysis by Country
WITH sales_by_country AS (
    SELECT
        c.country,
        SUM(oi.quantity) AS total_quantity_sold
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.country
),

returns_by_country AS (
    SELECT
        c.country,
        COUNT(r.return_id) AS total_return_records,
        SUM(r.quantity_returned) AS total_quantity_returned,
        ROUND(SUM(r.refund_amount_usd), 2) AS total_refund_usd
    FROM returns r
    JOIN orders o
        ON r.order_id = o.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY c.country
)

SELECT
    s.country,
    s.total_quantity_sold,
    COALESCE(r.total_quantity_returned, 0) AS total_quantity_returned,
    COALESCE(r.total_return_records, 0) AS total_return_records,
    COALESCE(r.total_refund_usd, 0) AS total_refund_usd,

    ROUND(
        COALESCE(r.total_quantity_returned, 0) * 100.0
        / s.total_quantity_sold,
        2
    ) AS return_rate_percentage

FROM sales_by_country s
LEFT JOIN returns_by_country r
    ON s.country = r.country

ORDER BY return_rate_percentage DESC;


-- Monthly Return Trend Analysis
SELECT
    DATE_FORMAT(return_date, '%Y-%m') AS return_month,

    COUNT(return_id) AS total_return_records,

    SUM(quantity_returned) AS total_quantity_returned,

    ROUND(SUM(refund_amount_usd), 2) AS total_refund_usd

FROM returns

GROUP BY DATE_FORMAT(return_date, '%Y-%m')

ORDER BY return_month;


-- Monthly Return Rate Analysis
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
        SUM(oi.quantity) AS total_quantity_sold

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),

monthly_returns AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,

        SUM(r.quantity_returned) AS total_quantity_returned,

        COUNT(DISTINCT r.return_id) AS total_return_records

    FROM returns r

    JOIN orders o
        ON r.order_id = o.order_id

    JOIN order_items oi
        ON r.order_item_id = oi.order_item_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)

SELECT
    s.sales_month,

    s.total_quantity_sold,

    COALESCE(r.total_quantity_returned, 0)
        AS total_quantity_returned,

    COALESCE(r.total_return_records, 0)
        AS total_return_records,

    ROUND(
        COALESCE(r.total_quantity_returned, 0)
        * 100.0 / s.total_quantity_sold,
        2
    ) AS return_rate_percentage

FROM monthly_sales s

LEFT JOIN monthly_returns r
    ON s.sales_month = r.sales_month

ORDER BY s.sales_month;


-- Average Days to Return Analysis
SELECT
    ROUND(AVG(days_to_return), 2) AS average_days_to_return,

    MIN(days_to_return) AS minimum_days_to_return,

    MAX(days_to_return) AS maximum_days_to_return,

    COUNT(return_id) AS total_return_records

FROM returns;


-- Average Days to Return by Return Reason
SELECT
    return_reason,

    COUNT(return_id) AS total_return_records,

    ROUND(AVG(days_to_return), 2) AS average_days_to_return,

    MIN(days_to_return) AS minimum_days,

    MAX(days_to_return) AS maximum_days

FROM returns

GROUP BY return_reason

ORDER BY average_days_to_return DESC;


-- Return Rate by Product Analysis
WITH product_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold

    FROM order_items oi

    INNER JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY oi.product_id
),

product_returns AS (
    SELECT
        r.product_id,
        SUM(r.quantity_returned) AS units_returned,
        COUNT(DISTINCT r.return_id) AS return_records

    FROM returns r

    INNER JOIN orders o
        ON r.order_id = o.order_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY r.product_id
)

SELECT
    p.product_id,
    p.product_name,
    p.category,

    ps.units_sold,

    COALESCE(pr.units_returned, 0) AS units_returned,

    COALESCE(pr.return_records, 0) AS return_records,

    ROUND(
        COALESCE(pr.units_returned, 0) * 100.0
        / ps.units_sold,
        2
    ) AS return_rate_percentage

FROM product_sales ps

INNER JOIN products p
    ON ps.product_id = p.product_id

LEFT JOIN product_returns pr
    ON ps.product_id = pr.product_id

WHERE ps.units_sold >= 30

ORDER BY return_rate_percentage DESC

LIMIT 10;



-- Products with the Highest Return Costs
SELECT
    p.product_id,
    p.product_name,
    p.category,

    COUNT(r.return_id) AS total_return_records,

    SUM(r.quantity_returned) AS total_units_returned,

    ROUND(SUM(r.refund_amount_usd), 2) AS total_refund_usd,

    ROUND(AVG(r.refund_amount_usd), 2) AS average_refund_usd

FROM returns r

INNER JOIN products p
    ON r.product_id = p.product_id

INNER JOIN orders o
    ON r.order_id = o.order_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    p.product_id,
    p.product_name,
    p.category

ORDER BY total_refund_usd DESC

LIMIT 10;


-- Customer Return Behaviour
SELECT
    c.customer_id,
    c.country,

    COUNT(r.return_id) AS total_return_records,

    SUM(r.quantity_returned) AS total_units_returned,

    ROUND(SUM(r.refund_amount_usd), 2) AS total_refund_usd,

    ROUND(AVG(r.refund_amount_usd), 2) AS average_refund_usd

FROM returns r

INNER JOIN customers c
    ON r.customer_id = c.customer_id

INNER JOIN orders o
    ON r.order_id = o.order_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.customer_id,
    c.country

ORDER BY
    total_return_records DESC,
    total_refund_usd DESC

LIMIT 10;


-- Overall Sales and Returns Performance
WITH sales_summary AS (
    SELECT
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS total_customers,
        SUM(o.order_total_usd) AS total_revenue,
        AVG(o.order_total_usd) AS average_order_value

    FROM orders o

    WHERE o.order_status <> 'Cancelled'
),

units_summary AS (
    SELECT
        SUM(oi.quantity) AS total_units_sold

    FROM order_items oi

    INNER JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status <> 'Cancelled'
),

returns_summary AS (
    SELECT
        COUNT(r.return_id) AS total_return_records,
        SUM(r.quantity_returned) AS total_units_returned,
        SUM(r.refund_amount_usd) AS total_refund_usd

    FROM returns r

    INNER JOIN orders o
        ON r.order_id = o.order_id

    WHERE o.order_status <> 'Cancelled'
)

SELECT
    s.total_orders,
    s.total_customers,

    ROUND(s.total_revenue, 2) AS total_revenue_usd,

    ROUND(s.average_order_value, 2) AS average_order_value_usd,

    u.total_units_sold,

    r.total_return_records,
    r.total_units_returned,

    ROUND(r.total_refund_usd, 2) AS total_refund_usd,

    ROUND(
        r.total_units_returned * 100.0
        / u.total_units_sold,
        2
    ) AS overall_return_rate_percentage

FROM sales_summary s

CROSS JOIN units_summary u

CROSS JOIN returns_summary r;



-- Revenue Reconciliation
WITH order_revenue AS (
    SELECT
        COUNT(order_id) AS total_orders,
        SUM(order_total_usd) AS total_order_revenue

    FROM orders

    WHERE order_status <> 'Cancelled'
),

item_revenue AS (
    SELECT
        COUNT(DISTINCT oi.order_id) AS orders_with_items,
        SUM(oi.line_total_usd) AS total_item_revenue

    FROM order_items oi

    INNER JOIN orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status <> 'Cancelled'
)

SELECT
    o.total_orders,
    i.orders_with_items,

    ROUND(o.total_order_revenue, 2) AS total_order_revenue,

    ROUND(i.total_item_revenue, 2) AS total_item_revenue,

    ROUND(
        o.total_order_revenue - i.total_item_revenue,
        2
    ) AS revenue_difference,

    ROUND(
        (o.total_order_revenue - i.total_item_revenue)
        / o.total_orders,
        2
    ) AS average_difference_per_order

FROM order_revenue o

CROSS JOIN item_revenue i;


-- Investigate Revenue Differences by Order
WITH item_totals AS (
    SELECT
        order_id,
        SUM(line_total_usd) AS item_revenue

    FROM order_items

    GROUP BY order_id
)

SELECT
    o.order_id,

    ROUND(o.order_total_usd, 2) AS order_revenue,

    ROUND(COALESCE(i.item_revenue, 0), 2) AS item_revenue,

    ROUND(
        o.order_total_usd - COALESCE(i.item_revenue, 0),
        2
    ) AS revenue_difference

FROM orders o

LEFT JOIN item_totals i
    ON o.order_id = i.order_id

WHERE o.order_status <> 'Cancelled'

ORDER BY revenue_difference DESC

LIMIT 10;


-- Reconcile Order-Level Revenue Components
SELECT
    COUNT(*) AS total_orders,

    ROUND(SUM(gross_amount_local), 2)
        AS total_gross_local,

    ROUND(SUM(discount_local), 2)
        AS total_discount_local,

    ROUND(SUM(shipping_fee_local), 2)
        AS total_shipping_local,

    ROUND(SUM(tax_local), 2)
        AS total_tax_local,

    ROUND(SUM(order_total_local), 2)
        AS recorded_order_total_local,

    ROUND(
        SUM(
            gross_amount_local
            - discount_local
            + shipping_fee_local
            + tax_local
        ), 2
    ) AS calculated_order_total_local,

    ROUND(
        SUM(
            order_total_local
            - (
                gross_amount_local
                - discount_local
                + shipping_fee_local
                + tax_local
            )
        ), 2
    ) AS reconciliation_difference

FROM orders

WHERE order_status <> 'Cancelled';


-- Verify USD Currency Conversion
SELECT
    COUNT(*) AS total_orders,

    ROUND(SUM(order_total_local), 2)
        AS total_local_revenue,

    ROUND(SUM(order_total_usd), 2)
        AS recorded_usd_revenue,

    ROUND(
        SUM(order_total_local * fx_rate_to_usd), 2
    ) AS calculated_usd_revenue,

    ROUND(
        SUM(
            order_total_usd -
            (order_total_local * fx_rate_to_usd)
        ), 2
    ) AS conversion_difference

FROM orders

WHERE order_status <> 'Cancelled';


-- Inspect Currency Exchange Rates
SELECT
    currency_code,
    COUNT(*) AS total_orders,

    ROUND(MIN(fx_rate_to_usd), 6) AS minimum_rate,

    ROUND(MAX(fx_rate_to_usd), 6) AS maximum_rate,

    ROUND(AVG(fx_rate_to_usd), 6) AS average_rate,

    ROUND(MIN(order_total_local), 2) AS minimum_local_amount,

    ROUND(MAX(order_total_local), 2) AS maximum_local_amount,

    ROUND(AVG(order_total_usd), 2) AS average_usd_amount

FROM orders

WHERE order_status <> 'Cancelled'

GROUP BY currency_code

ORDER BY currency_code;


-- Verify the Correct USD Conversion
SELECT
    COUNT(*) AS total_orders,

    ROUND(SUM(order_total_local), 2)
        AS total_local_revenue,

    ROUND(SUM(order_total_usd), 2)
        AS recorded_usd_revenue,

    ROUND(
        SUM(order_total_local / fx_rate_to_usd), 2
    ) AS calculated_usd_revenue,

    ROUND(
        SUM(
            order_total_usd -
            (order_total_local / fx_rate_to_usd)
        ), 2
    ) AS conversion_difference

FROM orders

WHERE order_status <> 'Cancelled';

-- Investigate Item-Level Revenue
SELECT
    o.currency_code,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(oi.line_total_usd), 2) AS item_revenue_usd,

    ROUND(SUM(oi.quantity), 0) AS total_units_sold,

    ROUND(
        SUM(oi.line_total_usd) / SUM(oi.quantity), 2
    ) AS average_revenue_per_unit

FROM order_items oi

INNER JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status <> 'Cancelled'

GROUP BY o.currency_code

ORDER BY o.currency_code;


-- Compare Order Components Against Item Revenue
WITH item_revenue AS (
    SELECT
        o.currency_code,
        SUM(oi.line_total_usd) AS item_revenue_usd
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY o.currency_code
)

SELECT
    o.currency_code,

    ROUND(SUM(o.gross_amount_local / o.fx_rate_to_usd), 2)
        AS gross_amount_usd,

    ROUND(SUM(o.discount_local / o.fx_rate_to_usd), 2)
        AS discount_usd,

    ROUND(SUM(o.shipping_fee_local / o.fx_rate_to_usd), 2)
        AS shipping_usd,

    ROUND(SUM(o.tax_local / o.fx_rate_to_usd), 2)
        AS tax_usd,

    ROUND(i.item_revenue_usd, 2)
        AS item_revenue_usd

FROM orders o

INNER JOIN item_revenue i
    ON o.currency_code = i.currency_code

WHERE o.order_status <> 'Cancelled'

GROUP BY
    o.currency_code,
    i.item_revenue_usd

ORDER BY o.currency_code;


-- Compare Item Revenue Against Gross Amount After Discounts
WITH item_revenue AS (
    SELECT
        o.currency_code,
        SUM(oi.line_total_usd) AS item_revenue_usd
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY o.currency_code
)

SELECT
    o.currency_code,

    ROUND(
        SUM(
            (o.gross_amount_local - o.discount_local)
            / o.fx_rate_to_usd
        ), 2
    ) AS gross_after_discount_usd,

    ROUND(i.item_revenue_usd, 2) AS item_revenue_usd,

    ROUND(
        SUM(
            (o.gross_amount_local - o.discount_local)
            / o.fx_rate_to_usd
        ) - i.item_revenue_usd, 2
    ) AS difference_usd

FROM orders o

INNER JOIN item_revenue i
    ON o.currency_code = i.currency_code

WHERE o.order_status <> 'Cancelled'

GROUP BY
    o.currency_code,
    i.item_revenue_usd

ORDER BY difference_usd DESC;


-- Final Revenue Bridge
SELECT
    ROUND(
        SUM(gross_amount_local / fx_rate_to_usd), 2
    ) AS gross_revenue_usd,

    ROUND(
        SUM(discount_local / fx_rate_to_usd), 2
    ) AS discount_usd,

    ROUND(
        SUM(shipping_fee_local / fx_rate_to_usd), 2
    ) AS shipping_usd,

    ROUND(
        SUM(tax_local / fx_rate_to_usd), 2
    ) AS tax_usd,

    ROUND(
        SUM(order_total_usd), 2
    ) AS order_revenue_usd,

    ROUND(
        SUM(
            (gross_amount_local - discount_local)
            / fx_rate_to_usd
        ), 2
    ) AS expected_item_revenue_usd,

    ROUND(
        SUM(order_total_usd)
        - SUM(
            (gross_amount_local - discount_local)
            / fx_rate_to_usd
        ), 2
    ) AS order_vs_item_difference

FROM orders

WHERE order_status <> 'Cancelled';