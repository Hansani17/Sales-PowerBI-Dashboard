-- =====================================================
-- Load generated CSV data into PostgreSQL
-- Run this AFTER schema.sql, from psql, with output_csv/
-- in the same folder (or adjust the paths below).
-- =====================================================

\copy regions FROM 'output_csv/regions.csv' WITH (FORMAT csv, HEADER true);
\copy categories FROM 'output_csv/categories.csv' WITH (FORMAT csv, HEADER true);
\copy products FROM 'output_csv/products.csv' WITH (FORMAT csv, HEADER true);
\copy customers FROM 'output_csv/customers.csv' WITH (FORMAT csv, HEADER true);
\copy date_dim FROM 'output_csv/date_dim.csv' WITH (FORMAT csv, HEADER true);
\copy sales FROM 'output_csv/sales.csv' WITH (FORMAT csv, HEADER true);

-- Reset sequences so future inserts don't collide with loaded IDs
SELECT setval('regions_region_id_seq', (SELECT MAX(region_id) FROM regions));
SELECT setval('categories_category_id_seq', (SELECT MAX(category_id) FROM categories));
SELECT setval('products_product_id_seq', (SELECT MAX(product_id) FROM products));
SELECT setval('customers_customer_id_seq', (SELECT MAX(customer_id) FROM customers));
SELECT setval('sales_sale_id_seq', (SELECT MAX(sale_id) FROM sales));

-- Quick sanity check
SELECT COUNT(*) AS total_sales, MIN(sale_date), MAX(sale_date) FROM sales;