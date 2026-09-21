/* ============================================================
   LEVEL 7 — WINDOW FUNCTIONS
   Concepts: ROW_NUMBER, RANK, PARTITION BY, running totals, LAG
   ============================================================ */

USE olist_ecommerce;

-- 1. Number items within each order by price (most expensive = row 1).
SELECT
    order_id,
    product_id,
    price,
    ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY price DESC) AS item_rank_in_order
FROM order_items;

-- 2. Seller leaderboard, ranked by total revenue (global rank).
SELECT
    seller_id,
    SUM(price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(price) DESC) AS revenue_rank
FROM order_items
GROUP BY seller_id;

-- 3. Rank sellers by revenue WITHIN their own state.
SELECT
    s.seller_id,
    s.seller_state,
    SUM(oi.price) AS total_revenue,
    RANK() OVER (PARTITION BY s.seller_state ORDER BY SUM(oi.price) DESC) AS rank_in_state
FROM sellers AS s
JOIN order_items AS oi
    ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_state;

-- 4. Running total of payment_value, ordered by order_id.
SELECT
    order_id,
    payment_value,
    SUM(payment_value) OVER (ORDER BY order_id) AS running_total
FROM order_payments;

-- 5. Monthly revenue with previous month's revenue alongside it (LAG).
WITH revenue_by_month AS (
    SELECT
        YEAR(o.order_purchase_timestamp)  AS order_year,
        MONTH(o.order_purchase_timestamp) AS order_month,
        SUM(op.payment_value) AS total_revenue
    FROM orders AS o
    JOIN order_payments AS op
        ON o.order_id = op.order_id
    GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
)
SELECT
    order_year,
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_year, order_month) AS previous_month_revenue
FROM revenue_by_month;

-- 6. Top 3 highest-priced products per category (window function filtered via CTE).
WITH ranked_products AS (
    SELECT
        p.product_category_name,
        p.product_id,
        oi.price,
        ROW_NUMBER() OVER (PARTITION BY p.product_category_name ORDER BY oi.price DESC) AS price_rank
    FROM products AS p
    JOIN order_items AS oi
        ON p.product_id = oi.product_id
)
SELECT product_category_name, product_id, price, price_rank
FROM ranked_products
WHERE price_rank <= 3;
