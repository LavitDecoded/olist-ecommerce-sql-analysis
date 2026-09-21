/* ============================================================
   LEVEL 3 — AGGREGATION
   Concepts: COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
   ============================================================ */

USE olist_ecommerce;

-- 1. Total number of orders.
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- 2. Order count per order_status.
SELECT
    order_status,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 3. Total company-wide revenue.
SELECT SUM(payment_value) AS total_revenue
FROM order_payments;

-- 4. Average payment value per payment type.
SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_type;

-- 5. Product count per category, highest first.
SELECT
    product_category_name,
    COUNT(product_id) AS total_products
FROM products
GROUP BY product_category_name
ORDER BY total_products DESC;

-- 6. Min and max payment value.
SELECT
    MIN(payment_value) AS min_payment_value,
    MAX(payment_value) AS max_payment_value
FROM order_payments;

-- 7. Categories with more than 500 products listed.
SELECT
    product_category_name,
    COUNT(product_id) AS total_products
FROM products
GROUP BY product_category_name
HAVING COUNT(product_id) > 500;

-- 8. Total revenue per customer_state (join preview for Level 4).
SELECT
    c.customer_state,
    SUM(op.payment_value) AS total_revenue
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN order_payments AS op
    ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;
