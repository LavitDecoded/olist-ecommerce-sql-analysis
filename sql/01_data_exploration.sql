/* ============================================================
   LEVEL 1 — BASIC RETRIEVAL
   Concepts: SELECT, WHERE, ORDER BY, TOP, DISTINCT
   ============================================================ */

USE olist_ecommerce;

-- 1. Retrieve all columns from the customers table, first 10 rows.
SELECT TOP 10 *
FROM customers;

-- 2. Get a list of all unique customer states.
SELECT DISTINCT customer_state
FROM customers;

-- 3. Retrieve order_id, customer_id, order_status — most recent orders first.
SELECT order_id, customer_id, order_status
FROM orders
ORDER BY order_purchase_timestamp DESC;

-- 4. Find all products in the 'beleza_saude' (health & beauty) category.
SELECT product_id, product_category_name
FROM products
WHERE product_category_name = 'beleza_saude';

-- 5. Top 5 highest payment_value entries.
SELECT TOP 5 order_id, payment_value
FROM order_payments
ORDER BY payment_value DESC;

-- 6. All distinct payment types used.
SELECT DISTINCT payment_type
FROM order_payments;

-- 7. Sellers located in 'sao paulo'.
SELECT seller_id, seller_city
FROM sellers
WHERE seller_city = 'sao paulo';
