/* ============================================================
   LEVEL 6 — CTEs (WITH clauses)
   Concepts: single CTEs, chained CTEs, replacing subqueries
              with named, readable steps
   ============================================================ */

USE olist_ecommerce;

-- 1. Customer_state with the highest total revenue, via CTE.
WITH CTE_TotalRevenue AS (
    SELECT
        c.customer_state,
        SUM(op.payment_value) AS total_revenue
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    JOIN order_payments AS op
        ON o.order_id = op.order_id
    GROUP BY c.customer_state
)
SELECT TOP 1
    customer_state,
    total_revenue
FROM CTE_TotalRevenue
ORDER BY total_revenue DESC;

-- 2. Products that have never been ordered, via CTE + LEFT JOIN / IS NULL.
WITH CTE_AllProducts AS (
    SELECT product_id, product_category_name
    FROM products
)
SELECT
    cte.product_id,
    cte.product_category_name
FROM CTE_AllProducts AS cte
LEFT JOIN order_items AS oi
    ON cte.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- 3. Customers with more than 5 orders.
WITH customer_order_counts AS (
    SELECT
        c.customer_id,
        COUNT(o.order_id) AS order_count
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT customer_id, order_count
FROM customer_order_counts
WHERE order_count > 5;

-- 4. Chained CTEs: average order value per state.
WITH order_totals AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_order_value
    FROM order_payments
    GROUP BY order_id
),
state_avg AS (
    SELECT
        c.customer_state,
        AVG(ot.total_order_value) AS avg_order_value
    FROM order_totals AS ot
    JOIN orders AS o
        ON ot.order_id = o.order_id
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
)
SELECT customer_state, avg_order_value
FROM state_avg
ORDER BY avg_order_value DESC;

-- 5. Sellers whose total revenue is above the overall average seller revenue.
WITH seller_revenue AS (
    SELECT
        s.seller_id,
        SUM(oi.price) AS total_revenue
    FROM order_items AS oi
    JOIN sellers AS s
        ON oi.seller_id = s.seller_id
    GROUP BY s.seller_id
)
SELECT seller_id, total_revenue
FROM seller_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM seller_revenue
);
