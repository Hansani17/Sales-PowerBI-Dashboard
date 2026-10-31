-- Row counts: expect 5, 5, 27, 150, ~7313
SELECT 'categories' AS tbl, COUNT(*) FROM categories
UNION ALL SELECT 'regions',   COUNT(*) FROM regions
UNION ALL SELECT 'products',  COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sales',     COUNT(*) FROM sales;

-- Date range and revenue growth by year
SELECT EXTRACT(YEAR FROM sale_date) AS yr,
       COUNT(*) AS orders,
       ROUND(SUM(quantity * unit_price - discount_amount), 2) AS revenue
FROM sales GROUP BY yr ORDER BY yr;

-- Discount types working? (amount should equal calculated value)
SELECT discount_type, COUNT(*), ROUND(AVG(discount_amount), 2) AS avg_discount
FROM sales GROUP BY discount_type;

-- Orphan check: should return 0
SELECT COUNT(*) FROM sales s
LEFT JOIN products p ON p.product_id = s.product_id
WHERE p.product_id IS NULL;