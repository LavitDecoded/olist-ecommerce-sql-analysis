/* ============================================================
   LEVEL 8 — CAPSTONE: FULL BUSINESS ANALYSIS
   Combines joins, CTEs, aggregation, and window functions
   to answer real business questions.
   ============================================================ */

USE olist_ecommerce;

-- ------------------------------------------------------------
-- 1. NEW vs REPEAT CUSTOMER REVENUE
-- Note: Olist assigns a new customer_id per order, so
-- customer_unique_id (not customer_id) is used to identify
-- a genuine repeat customer.
-- ------------------------------------------------------------
WITH customer_order_totals AS (
    SELECT
        customer_unique_id,
        COUNT(*) AS total_orders,
        CASE
            WHEN COUNT(*) = 1 THEN 'New'
            ELSE 'Repeat'
        END AS customer_type
    FROM customers
    GROUP BY customer_unique_id
)
SELECT
    cot.customer_type,
    SUM(op.payment_value) AS total_revenue
FROM orders AS o
JOIN order_payments AS op
    ON o.order_id = op.order_id
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN customer_order_totals AS cot
    ON c.customer_unique_id = cot.customer_unique_id
GROUP BY cot.customer_type;

-- ------------------------------------------------------------
-- 2. DELIVERY DELAY vs REVIEW SCORE
-- Excludes orders with no delivery date (never delivered/canceled).
-- ------------------------------------------------------------
WITH order_delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
            ELSE 'On Time'
        END AS delivery_category
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT
    ods.delivery_category,
    AVG(orv.review_score) AS avg_review_score
FROM order_delivery_status AS ods
JOIN order_reviews AS orv
    ON ods.order_id = orv.order_id
GROUP BY ods.delivery_category;

-- ------------------------------------------------------------
-- 3. SELLER PERFORMANCE LEADERBOARD
-- Combines revenue, average review score, and late-delivery rate
-- into a single ranked view, one row per seller.
-- ------------------------------------------------------------
WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(price) AS total_revenue
    FROM order_items
    GROUP BY seller_id
),
seller_reviews AS (
    SELECT
        oi.seller_id,
        AVG(orv.review_score) AS avg_review_score
    FROM order_items AS oi
    JOIN order_reviews AS orv
        ON oi.order_id = orv.order_id
    GROUP BY oi.seller_id
),
seller_delivery AS (
    SELECT
        oi.seller_id,
        AVG(CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1.0
                ELSE 0.0
            END) AS late_delivery_rate
    FROM orders AS o
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.seller_id
)
SELECT
    sr.seller_id,
    sr.total_revenue,
    srv.avg_review_score,
    sd.late_delivery_rate,
    RANK() OVER (ORDER BY sr.total_revenue DESC) AS revenue_rank
FROM seller_revenue AS sr
JOIN seller_reviews AS srv
    ON sr.seller_id = srv.seller_id
JOIN seller_delivery AS sd
    ON sr.seller_id = sd.seller_id
ORDER BY revenue_rank;

-- ------------------------------------------------------------
-- 4. MONTH-OVER-MONTH REVENUE GROWTH %
-- Extends the Level 7 LAG() query with a growth-percentage column.
-- ------------------------------------------------------------
WITH revenue_by_month AS (
    SELECT
        YEAR(o.order_purchase_timestamp)  AS order_year,
        MONTH(o.order_purchase_timestamp) AS order_month,
        SUM(op.payment_value) AS total_revenue
    FROM orders AS o
    JOIN order_payments AS op
        ON o.order_id = op.order_id
    GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
),
revenue_with_lag AS (
    SELECT
        order_year,
        order_month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY order_year, order_month) AS previous_month_revenue
    FROM revenue_by_month
)
SELECT
    order_year,
    order_month,
    total_revenue,
    previous_month_revenue,
    (total_revenue - previous_month_revenue) / previous_month_revenue * 100 AS growth_percentage
FROM revenue_with_lag
ORDER BY order_year, order_month;
