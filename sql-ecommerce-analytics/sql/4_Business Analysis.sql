-- Calculate total revenue
SELECT
    ROUND(SUM(order_total_usd), 2) AS total_revenue_usd
FROM orders
WHERE order_status <> 'Cancelled';


-- Calculate total orders
SELECT
    COUNT(*) AS total_orders
FROM orders
WHERE order_status <> 'Cancelled';


-- Calculate Average Order Value (AOV) - Two Optios
-- Option one
SELECT
    ROUND(SUM(order_total_usd) / COUNT(*), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled';

-- Option Two
SELECT
    ROUND(AVG(order_total_usd), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled';


-- Total unique customers
SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM orders
WHERE order_status <> 'Cancelled';


-- calculate the total quantity sold
SELECT
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled';


-- Calculate total profit
SELECT
    ROUND(SUM(oi.line_profit_usd), 2) AS total_profit_usd
FROM order_items oi
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled';


-- Profit Margin
SELECT
    ROUND(
        (
            SELECT SUM(line_profit_usd)
            FROM order_items oi
            INNER JOIN orders o
                ON oi.order_id = o.order_id
            WHERE o.order_status <> 'Cancelled'
        )
        /
        (
            SELECT SUM(order_total_usd)
            FROM orders
            WHERE order_status <> 'Cancelled'
        ) * 100,
        2
    ) AS profit_margin_percentage;
    
-- Total orders by every month
select count(order_id) as total_orders , order_month
from orders 
where order_status <> 'Cancelled'
group by order_month
order by total_orders Desc;


-- Total revenue by every month
select sum(order_total_usd) as revenue , order_month
from orders 
where order_status <> 'Cancelled'
group by order_month
order by revenue Desc;


-- revenue by single month
SELECT
    MONTHNAME(order_date) AS month_name,
    ROUND(SUM(order_total_usd), 2) AS monthly_revenue
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY MONTH(order_date);

-- calculate revenue by category
SELECT
    p.category,
    ROUND(SUM(oi.line_total_usd), 2) AS total_revenue_usd
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.category
ORDER BY total_revenue_usd DESC;


-- Quantity sold by category
SELECT
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.category
ORDER BY total_quantity_sold DESC;

-- profit by product categor
SELECT
    p.category,
    ROUND(SUM(oi.line_profit_usd), 2) AS total_profit_usd
FROM order_items oi
INNER JOIN products p
    ON oi.product_id = p.product_id
INNER JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.category
ORDER BY total_profit_usd DESC;


-- top 10 Highest spending customers
SELECT
    customer_id,
    customer_name,
    lifetime_spend_usd,
    lifetime_orders
FROM customers
ORDER BY lifetime_spend_usd DESC
LIMIT 10;


-- 2nd option
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(o.order_total_usd), 2) AS total_spent_usd,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY total_spent_usd DESC
LIMIT 10;


-- find how many customers order one time and more than one time
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
) AS customer_orders
GROUP BY customer_type;


-- Customer Spending Segments
SELECT
    CASE
        WHEN lifetime_spend_usd >= 5000 THEN 'High-Value'
        WHEN lifetime_spend_usd >= 1000 THEN 'Medium-Value'
        ELSE 'Low-Value'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(lifetime_spend_usd), 2) AS average_spending
FROM customers
GROUP BY customer_segment
ORDER BY average_spending DESC;


-- Revenue Contribution by Customer Segment
WITH customer_segments AS (
    SELECT
        customer_id,
        CASE
            WHEN lifetime_spend_usd >= 5000 THEN 'High-Value'
            WHEN lifetime_spend_usd >= 1000 THEN 'Medium-Value'
            ELSE 'Low-Value'
        END AS customer_segment
    FROM customers
),
segment_revenue AS (
    SELECT
        cs.customer_segment,
        COUNT(DISTINCT cs.customer_id) AS total_customers,
        SUM(o.order_total_usd) AS total_revenue_usd
    FROM customer_segments cs
    INNER JOIN orders o
        ON cs.customer_id = o.customer_id
    WHERE o.order_status <> 'Cancelled'
    GROUP BY cs.customer_segment
)
SELECT
    customer_segment,
    total_customers,
    ROUND(total_revenue_usd, 2) AS total_revenue_usd,
    ROUND(
        total_revenue_usd /
        SUM(total_revenue_usd) OVER () * 100,
        2
    ) AS revenue_percentage
FROM segment_revenue
ORDER BY total_revenue_usd DESC;


-- Revenue by Acquisition Channel
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(SUM(o.order_total_usd), 2) AS total_revenue_usd,
    ROUND(AVG(o.order_total_usd), 2) AS average_order_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.acquisition_channel
ORDER BY total_revenue_usd DESC;


-- Customer Performance by Country
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_total_usd), 2) AS total_revenue_usd,
    ROUND(AVG(o.order_total_usd), 2) AS average_order_value
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.country
ORDER BY total_revenue_usd DESC;


-- Customer Analytics – Task 7: Customer Purchase Frequency
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        SUM(order_total_usd) AS total_spending
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer,
    MIN(total_orders) AS min_orders,
    MAX(total_orders) AS max_orders,
    ROUND(AVG(total_spending), 2) AS avg_customer_spending
FROM customer_orders;



--  Top Customers by Spending
SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_total_usd), 2) AS total_spending
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 10;


-- Customer Average Order Value (AOV)
SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_total_usd), 2) AS total_spending,
    ROUND(AVG(order_total_usd), 2) AS avg_order_value
FROM orders
WHERE order_status <> 'Cancelled'
GROUP BY customer_id
ORDER BY avg_order_value DESC
LIMIT 10;


-- Customer Segmentation by Purchase Frequency
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        SUM(order_total_usd) AS total_spending
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
),

customer_segments AS (
    SELECT
        customer_id,
        total_orders,
        total_spending,
        CASE
            WHEN total_orders = 1 THEN 'One-time Customer'
            WHEN total_orders BETWEEN 2 AND 5 THEN 'Regular Customer'
            ELSE 'Loyal Customer'
        END AS customer_segment
    FROM customer_orders
)

SELECT
    customer_segment,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(total_spending), 2) AS avg_customer_spending,
    ROUND(AVG(total_orders), 2) AS avg_orders
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;


-- Customer Revenue Contribution by Segment
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders,
        SUM(order_total_usd) AS total_spending
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
),

customer_segments AS (
    SELECT
        customer_id,
        total_orders,
        total_spending,
        CASE
            WHEN total_orders = 1 THEN 'One-time Customer'
            WHEN total_orders BETWEEN 2 AND 5 THEN 'Regular Customer'
            ELSE 'Loyal Customer'
        END AS customer_segment
    FROM customer_orders
)

SELECT
    customer_segment,
    COUNT(customer_id) AS total_customers,
    ROUND(SUM(total_spending), 2) AS total_revenue,
    ROUND(
        SUM(total_spending) * 100.0 /
        SUM(SUM(total_spending)) OVER(),
        2
    ) AS revenue_contribution_percentage
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;


-- Customer Retention Analysis
WITH customer_first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,
    COUNT(
        CASE
            WHEN first_purchase_date IS NOT NULL THEN 1
        END
    ) AS customers_with_first_purchase
FROM customer_first_purchase;



-- Repeat Customer Analysis
-- Business question: How many customers made more than one purchase?
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE
        WHEN total_orders = 1 THEN 1
        ELSE 0
    END) AS one_time_customers,
    SUM(CASE
        WHEN total_orders > 1 THEN 1
        ELSE 0
    END) AS repeat_customers,
    ROUND(
        SUM(CASE
            WHEN total_orders > 1 THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;


-- Monthly Customer Retention Analysis
WITH monthly_customers AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS purchase_month
    FROM orders
    WHERE order_status <> 'Cancelled'
),

customer_months AS (
    SELECT
        customer_id,
        purchase_month,
        LAG(purchase_month) OVER (
            PARTITION BY customer_id
            ORDER BY purchase_month
        ) AS previous_purchase_month
    FROM monthly_customers
)

SELECT
    purchase_month,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(
        CASE
            WHEN previous_purchase_month IS NOT NULL
            THEN customer_id
        END
    ) AS returning_customers
FROM customer_months
GROUP BY purchase_month
ORDER BY purchase_month;


-- Customer Cohort
WITH customer_first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
),

customer_cohorts AS (
    SELECT
        customer_id,
        DATE_FORMAT(first_purchase_date, '%Y-%m') AS cohort_month
    FROM customer_first_purchase
),

monthly_purchases AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS purchase_month
    FROM orders
    WHERE order_status <> 'Cancelled'
)

SELECT
    c.cohort_month,
    m.purchase_month,
    TIMESTAMPDIFF(
        MONTH,
        STR_TO_DATE(CONCAT(c.cohort_month, '-01'), '%Y-%m-%d'),
        STR_TO_DATE(CONCAT(m.purchase_month, '-01'), '%Y-%m-%d')
    ) AS month_number,
    COUNT(DISTINCT c.customer_id) AS active_customers
FROM customer_cohorts c
JOIN monthly_purchases m
    ON c.customer_id = m.customer_id
GROUP BY
    c.cohort_month,
    m.purchase_month,
    month_number
ORDER BY
    c.cohort_month,
    month_number;
    
    
    
-- Calculate Customer Retention %
WITH customer_first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
),

customer_cohorts AS (
    SELECT
        customer_id,
        DATE_FORMAT(first_purchase_date, '%Y-%m') AS cohort_month
    FROM customer_first_purchase
),

monthly_purchases AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS purchase_month
    FROM orders
    WHERE order_status <> 'Cancelled'
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
),

cohort_activity AS (
    SELECT
        c.cohort_month,
        m.purchase_month,
        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(CONCAT(c.cohort_month, '-01'), '%Y-%m-%d'),
            STR_TO_DATE(CONCAT(m.purchase_month, '-01'), '%Y-%m-%d')
        ) AS month_number,
        COUNT(DISTINCT m.customer_id) AS active_customers
    FROM customer_cohorts c
    JOIN monthly_purchases m
        ON c.customer_id = m.customer_id
    GROUP BY
        c.cohort_month,
        m.purchase_month
)

SELECT
    a.cohort_month,
    a.month_number,
    s.cohort_size,
    a.active_customers,
    ROUND(
        a.active_customers * 100.0 / s.cohort_size,
        2
    ) AS retention_percentage
FROM cohort_activity a
JOIN cohort_sizes s
    ON a.cohort_month = s.cohort_month
ORDER BY
    a.cohort_month,
    a.month_number;
    
    
-- Create the Cohort Retention Matrix
WITH customer_first_purchase AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_purchase_date
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
),

customer_cohorts AS (
    SELECT
        customer_id,
        DATE_FORMAT(first_purchase_date, '%Y-%m') AS cohort_month
    FROM customer_first_purchase
),

monthly_purchases AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') AS purchase_month
    FROM orders
    WHERE order_status <> 'Cancelled'
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
),

cohort_activity AS (
    SELECT
        c.cohort_month,

        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(CONCAT(c.cohort_month, '-01'), '%Y-%m-%d'),
            STR_TO_DATE(CONCAT(m.purchase_month, '-01'), '%Y-%m-%d')
        ) AS month_number,

        COUNT(DISTINCT m.customer_id) AS active_customers

    FROM customer_cohorts c
    JOIN monthly_purchases m
        ON c.customer_id = m.customer_id

    GROUP BY
        c.cohort_month,
        m.purchase_month
),

retention_data AS (
    SELECT
        a.cohort_month,
        a.month_number,
        ROUND(
            a.active_customers * 100.0 / s.cohort_size,
            2
        ) AS retention_percentage

    FROM cohort_activity a
    JOIN cohort_sizes s
        ON a.cohort_month = s.cohort_month
)

SELECT
    cohort_month,

    MAX(CASE WHEN month_number = 0 THEN retention_percentage END) AS Month_0,
    MAX(CASE WHEN month_number = 1 THEN retention_percentage END) AS Month_1,
    MAX(CASE WHEN month_number = 2 THEN retention_percentage END) AS Month_2,
    MAX(CASE WHEN month_number = 3 THEN retention_percentage END) AS Month_3,
    MAX(CASE WHEN month_number = 4 THEN retention_percentage END) AS Month_4,
    MAX(CASE WHEN month_number = 5 THEN retention_percentage END) AS Month_5,
    MAX(CASE WHEN month_number = 6 THEN retention_percentage END) AS Month_6,
    MAX(CASE WHEN month_number = 7 THEN retention_percentage END) AS Month_7,
    MAX(CASE WHEN month_number = 8 THEN retention_percentage END) AS Month_8,
    MAX(CASE WHEN month_number = 9 THEN retention_percentage END) AS Month_9,
    MAX(CASE WHEN month_number = 10 THEN retention_percentage END) AS Month_10,
    MAX(CASE WHEN month_number = 11 THEN retention_percentage END) AS Month_11,
    MAX(CASE WHEN month_number = 12 THEN retention_percentage END) AS Month_12

FROM retention_data
GROUP BY cohort_month
ORDER BY cohort_month;