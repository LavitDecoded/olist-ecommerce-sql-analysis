/* ============================================================
   LEVEL 4 — JOINS
   Concepts: INNER JOIN, LEFT JOIN, multi-table joins
   ============================================================ */

USE olist_ecommerce;

-- 1. order_id, customer_city, customer_state for every order.
SELECT o.order_id, c.customer_city, c.customer_state
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id;

-- 2. Products that were actually ordered.
SELECT oi.order_id, p.product_id, p.product_category_name
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id;

-- 3. Sellers who have never had an order (LEFT JOIN + IS NULL pattern).
SELECT s.*
FROM sellers AS s
LEFT JOIN order_items AS oi
    ON s.seller_id = oi.seller_id
WHERE oi.order_id IS NULL;

-- 4. order_id, customer_state, review_score for every order.
SELECT
    o.order_id,
    c.customer_state,
    orv.review_score
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
LEFT JOIN order_reviews AS orv
    ON o.order_id = orv.order_id;

-- 5. Top 10 products by total quantity sold.
SELECT TOP 10
    p.product_id,
    p.product_category_name,
    COUNT(oi.order_id) AS total_quantity
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_category_name
ORDER BY total_quantity DESC;

-- 6. Customers who have placed at least one canceled order.
SELECT
    c.customer_id,
    c.customer_city,
    COUNT(o.order_id) AS canceled_orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'canceled'
GROUP BY c.customer_id, c.customer_city;

-- 7. Average review score per seller (worst-rated first).
SELECT
    s.seller_id,
    ROUND(AVG(orv.review_score), 2) AS avg_review_score
FROM order_items AS oi
LEFT JOIN sellers AS s
    ON oi.seller_id = s.seller_id
LEFT JOIN order_reviews AS orv
    ON oi.order_id = orv.order_id
GROUP BY s.seller_id
ORDER BY avg_review_score ASC;
