/* ============================================================
   LEVEL 5 — SUBQUERIES
   Concepts: scalar subqueries, correlated subqueries,
             subquery in WHERE, subquery in FROM (derived table)
   ============================================================ */

USE olist_ecommerce;

-- 1. Payments greater than the average payment value across all payments.
SELECT
    o.order_id,
    c.customer_id,
    op.payment_type,
    op.payment_value
FROM orders AS o
JOIN order_payments AS op
    ON o.order_id = op.order_id
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE op.payment_value > (
    SELECT AVG(payment_value) FROM order_payments
);

-- 2. The single most expensive item ever sold.
SELECT
    p.product_id,
    p.product_category_name,
    oi.price
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
WHERE oi.price = (
    SELECT MAX(price) FROM order_items
);

-- 3. Sellers who have never appeared in order_items (NOT IN version).
SELECT *
FROM sellers
WHERE seller_id NOT IN (
    SELECT seller_id FROM order_items
);

-- 4. Orders with more than 3 items (correlated subquery).
SELECT order_id, order_status
FROM orders AS o
WHERE (
    SELECT COUNT(*)
    FROM order_items AS oi
    WHERE oi.order_id = o.order_id
) > 3;

-- 5. The customer_state with the highest total revenue (derived table / subquery in FROM).
SELECT TOP 1
    state_revenue.customer_state,
    state_revenue.total_revenue
FROM (
    SELECT
        c.customer_state,
        SUM(op.payment_value) AS total_revenue
    FROM orders AS o
    JOIN order_payments AS op
        ON o.order_id = op.order_id
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
) AS state_revenue
ORDER BY state_revenue.total_revenue DESC;

-- 6. Products that have never been ordered (NOT IN version).
SELECT
    product_id,
    product_category_name
FROM products
WHERE product_id NOT IN (
    SELECT product_id FROM order_items
);
