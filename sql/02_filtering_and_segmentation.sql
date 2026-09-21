/* ============================================================
   LEVEL 2 — FILTERING & CONDITIONS
   Concepts: AND/OR, BETWEEN, IN, LIKE, IS NULL, CASE WHEN
   ============================================================ */

USE olist_ecommerce;

-- 1. Orders that are either 'delivered' or 'shipped'.
SELECT *
FROM orders
WHERE order_status = 'delivered' OR order_status = 'shipped';

-- 2. Orders that were never approved (order_approved_at IS NULL).
SELECT *
FROM orders
WHERE order_approved_at IS NULL;

-- 3. Customers located in SP, RJ, or MG.
SELECT customer_id, customer_city, customer_state
FROM customers
WHERE customer_state IN ('SP', 'RJ', 'MG');

-- 4. Products in furniture-related categories (prefix 'moveis').
SELECT *
FROM products
WHERE product_category_name LIKE 'moveis%';

-- 5. Payments between 100 and 500 (inclusive).
SELECT *
FROM order_payments
WHERE payment_value BETWEEN 100 AND 500;

-- 6. Add a readable delivery status label via CASE WHEN.
SELECT
    order_id,
    order_status,
    CASE
        WHEN order_status = 'delivered' THEN 'Completed'
        WHEN order_status = 'canceled'  THEN 'Cancelled Order'
        ELSE 'In Progress'
    END AS delivery_status_label
FROM orders;

-- 7. Sellers in SP state but NOT in 'sao paulo' city.
SELECT *
FROM sellers
WHERE seller_city <> 'sao paulo' AND seller_state = 'SP';
