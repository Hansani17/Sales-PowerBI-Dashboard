-- =====================================================
-- Sales & Profitability Analytics — SQL Analysis
-- Each query maps to a business question from the README
-- =====================================================

-- 1. Total Revenue, Profit, Margin (overall KPIs)
SELECT
    ROUND(SUM(quantity * unit_price - discount), 2) AS total_revenue,
    ROUND(SUM(quantity * unit_price - discount) - SUM(quantity * unit_cost), 2) AS total_profit,
    ROUND(
      (SUM(quantity * unit_price - discount) - SUM(quantity * unit_cost))
      / NULLIF(SUM(quantity * unit_price - discount), 0) * 100, 2
    ) AS profit_margin_pct,
    COUNT(DISTINCT sale_id) AS total_orders,
    SUM(quantity) AS total_units_sold
FROM sales;

-- 2. Monthly revenue & profit trend
SELECT
    d.year, d.month, d.month_name,
    ROUND(SUM(s.quantity * s.unit_price - s.discount), 2) AS revenue,
    ROUND(SUM(s.quantity * s.unit_price - s.discount) - SUM(s.quantity * s.unit_cost), 2) AS profit
FROM sales s
JOIN date_dim d ON s.sale_date = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- 3. Which month generated the highest revenue?
SELECT d.year, d.month_name, ROUND(SUM(s.quantity * s.unit_price - s.discount), 2) AS revenue
FROM sales s JOIN date_dim d ON s.sale_date = d.date_id
GROUP BY d.year, d.month_name
ORDER BY revenue DESC
LIMIT 1;

-- 4. Top 10 products by revenue
SELECT
    p.product_name,
    ROUND(SUM(s.quantity * s.unit_price - s.discount), 2) AS revenue,
    ROUND(SUM(s.quantity * s.unit_price - s.discount) - SUM(s.quantity * s.unit_cost), 2) AS profit
FROM sales s JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 5. Top 10 products by profit
SELECT
    p.product_name,
    ROUND(SUM(s.quantity * s.unit_price - s.discount) - SUM(s.quantity * s.unit_cost), 2) AS profit
FROM sales s JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY profit DESC
LIMIT 10;

-- 6. Products with high revenue but low profit margin (attention list)
SELECT
    p.product_name,
    ROUND(SUM(s.quantity * s.unit_price - s.discount), 2) AS revenue,
    ROUND(
      (SUM(s.quantity * s.unit_price - s.discount) - SUM(s.quantity * s.unit_cost))
      / NULLIF(SUM(s.quantity * s.unit_price - s.discount), 0) * 100, 2
    ) AS profit_margin_pct
FROM sales s JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
HAVING SUM(s.quantity * s.unit_price - s.discount) > (
    SELECT AVG(rev) FROM (
        SELECT SUM(quantity * unit_price - discount) AS rev
        FROM sales GROUP BY product_id
    ) t
)
ORDER BY profit_margin_pct ASC
LIMIT 10;

-- 7. Category performance
SELECT
    c.category_name,
    ROUND(SUM(s.quantity * s.unit_price - s.discount), 2) AS revenue,
    ROUND(SUM(s.quantity * s.unit_price - s.discount) - SUM(s.quantity * s.unit_cost), 2) AS profit,
    ROUND(
      (SUM(s.quantity * s.unit_price - s.discount) - SUM(s.quantity * s.unit_cost))
      / NULLIF(SUM(s.quantity * s.unit_price - s.discount), 0) * 100, 2
    ) AS profit_margin_pct
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;

-- 8. Regional performance
SELECT
    r.region_name,
    ROUND(SUM(s.quantity * s.unit_price - s.discount), 2) AS revenue,
    ROUND(SUM(s.quantity * s.unit_price - s.discount) - SUM(s.quantity * s.unit_cost), 2) AS profit,
    COUNT(DISTINCT s.sale_id) AS orders
FROM sales s JOIN regions r ON s.region_id = r.region_id
GROUP BY r.region_name
ORDER BY revenue DESC;

-- 9. Year-over-Year revenue growth
WITH yearly AS (
    SELECT d.year, SUM(s.quantity * s.unit_price - s.discount) AS revenue
    FROM sales s JOIN date_dim d ON s.sale_date = d.date_id
    GROUP BY d.year
)
SELECT
    year, revenue,
    LAG(revenue) OVER (ORDER BY year) AS prev_year_revenue,
    ROUND(
      (revenue - LAG(revenue) OVER (ORDER BY year))
      / NULLIF(LAG(revenue) OVER (ORDER BY year), 0) * 100, 2
    ) AS yoy_growth_pct
FROM yearly
ORDER BY year;

-- 10. Average order value
SELECT ROUND(SUM(quantity * unit_price - discount) / COUNT(DISTINCT sale_id), 2) AS avg_order_value
FROM sales;