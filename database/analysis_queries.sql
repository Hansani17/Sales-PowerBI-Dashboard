-- =====================================================
-- Sales & Profitability Analytics Dashboard
-- SQL analysis queries (PostgreSQL)
--
-- Definitions used throughout:
--   Revenue = quantity * unit_price - discount_amount
--   Cost    = quantity * unit_cost
--   Profit  = Revenue - Cost
--   Margin  = Profit / Revenue
--
-- Run each query separately (select it, then press F5).
-- =====================================================


-- -----------------------------------------------------
-- Q1. Overall KPI summary
-- Business question: How is the business performing overall?
-- -----------------------------------------------------
SELECT
    COUNT(*)                                                        AS total_orders,
    SUM(quantity)                                                   AS units_sold,
    ROUND(SUM(quantity * unit_price - discount_amount), 2)          AS total_revenue,
    ROUND(SUM(quantity * unit_cost), 2)                             AS total_cost,
    ROUND(SUM(quantity * unit_price - discount_amount
              - quantity * unit_cost), 2)                           AS total_profit,
    ROUND(100.0 * SUM(quantity * unit_price - discount_amount - quantity * unit_cost)
          / SUM(quantity * unit_price - discount_amount), 2)        AS profit_margin_pct,
    ROUND(SUM(quantity * unit_price - discount_amount) / COUNT(*), 2) AS avg_order_value
FROM sales;


-- -----------------------------------------------------
-- Q2. Yearly revenue and profit with Year-over-Year growth
-- Business question: Are revenue and profit growing, and at the same rate?
-- -----------------------------------------------------
WITH yearly AS (
    SELECT
        EXTRACT(YEAR FROM sale_date)::INT                           AS yr,
        SUM(quantity * unit_price - discount_amount)                AS revenue,
        SUM(quantity * unit_price - discount_amount
            - quantity * unit_cost)                                 AS profit
    FROM sales
    GROUP BY 1
)
SELECT
    yr,
    ROUND(revenue, 2)                                               AS revenue,
    ROUND(profit, 2)                                                AS profit,
    ROUND(100.0 * profit / revenue, 2)                              AS margin_pct,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY yr))
          / LAG(revenue) OVER (ORDER BY yr), 2)                     AS revenue_yoy_pct,
    ROUND(100.0 * (profit - LAG(profit) OVER (ORDER BY yr))
          / LAG(profit) OVER (ORDER BY yr), 2)                      AS profit_yoy_pct
FROM yearly
ORDER BY yr;


-- -----------------------------------------------------
-- Q3. Monthly revenue and profit with Month-over-Month growth
-- Business question: How do sales change month to month?
-- -----------------------------------------------------
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', sale_date)::DATE                        AS month_start,
        SUM(quantity * unit_price - discount_amount)                AS revenue,
        SUM(quantity * unit_price - discount_amount
            - quantity * unit_cost)                                 AS profit
    FROM sales
    GROUP BY 1
)
SELECT
    month_start,
    ROUND(revenue, 2)                                               AS revenue,
    ROUND(profit, 2)                                                AS profit,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month_start))
          / LAG(revenue) OVER (ORDER BY month_start), 2)            AS revenue_mom_pct
FROM monthly
ORDER BY month_start;


-- -----------------------------------------------------
-- Q4. Seasonality: average revenue by calendar month
-- Business question: Which months are strongest and weakest?
-- -----------------------------------------------------
WITH monthly AS (
    SELECT
        EXTRACT(YEAR FROM sale_date)::INT                           AS yr,
        EXTRACT(MONTH FROM sale_date)::INT                          AS mth,
        SUM(quantity * unit_price - discount_amount)                AS revenue
    FROM sales
    GROUP BY 1, 2
)
SELECT
    mth                                                             AS month_number,
    TO_CHAR(TO_DATE(mth::TEXT, 'MM'), 'Mon')                        AS month_name,
    ROUND(AVG(revenue), 2)                                          AS avg_monthly_revenue,
    RANK() OVER (ORDER BY AVG(revenue) DESC)                        AS revenue_rank
FROM monthly
GROUP BY mth
ORDER BY mth;


-- -----------------------------------------------------
-- Q5. Quarterly revenue by year
-- Business question: How does performance vary by quarter?
-- -----------------------------------------------------
SELECT
    EXTRACT(YEAR FROM sale_date)::INT                               AS yr,
    'Q' || EXTRACT(QUARTER FROM sale_date)::INT                     AS quarter,
    ROUND(SUM(quantity * unit_price - discount_amount), 2)          AS revenue,
    ROUND(SUM(quantity * unit_price - discount_amount
              - quantity * unit_cost), 2)                           AS profit
FROM sales
GROUP BY 1, 2
ORDER BY 1, 2;


-- -----------------------------------------------------
-- Q6. Top 10 products by revenue
-- Business question: Which products generate the most revenue?
-- -----------------------------------------------------
SELECT
    p.product_name,
    c.category_name,
    SUM(s.quantity)                                                 AS units_sold,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount), 2)    AS revenue,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount
              - s.quantity * s.unit_cost), 2)                       AS profit
FROM sales s
JOIN products   p ON p.product_id  = s.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY p.product_name, c.category_name
ORDER BY revenue DESC
LIMIT 10;


-- -----------------------------------------------------
-- Q7. Top 10 products by profit
-- Business question: Which products generate the most profit?
-- -----------------------------------------------------
SELECT
    p.product_name,
    c.category_name,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount
              - s.quantity * s.unit_cost), 2)                       AS profit,
    ROUND(100.0 * SUM(s.quantity * s.unit_price - s.discount_amount
                      - s.quantity * s.unit_cost)
          / SUM(s.quantity * s.unit_price - s.discount_amount), 2)  AS margin_pct
FROM sales s
JOIN products   p ON p.product_id  = s.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY p.product_name, c.category_name
ORDER BY profit DESC
LIMIT 10;


-- -----------------------------------------------------
-- Q8. High revenue but low margin products
-- Business question: Which products have high sales but low profitability?
-- Logic: revenue in the top half of all products, margin below the
--        company-wide average margin.
-- -----------------------------------------------------
WITH product_stats AS (
    SELECT
        p.product_name,
        c.category_name,
        SUM(s.quantity * s.unit_price - s.discount_amount)          AS revenue,
        SUM(s.quantity * s.unit_price - s.discount_amount
            - s.quantity * s.unit_cost)                             AS profit
    FROM sales s
    JOIN products   p ON p.product_id  = s.product_id
    JOIN categories c ON c.category_id = p.category_id
    GROUP BY p.product_name, c.category_name
),
overall AS (
    SELECT SUM(profit) / SUM(revenue) AS overall_margin FROM product_stats
)
SELECT
    ps.product_name,
    ps.category_name,
    ROUND(ps.revenue, 2)                                            AS revenue,
    ROUND(100.0 * ps.profit / ps.revenue, 2)                        AS margin_pct,
    ROUND(100.0 * o.overall_margin, 2)                              AS company_margin_pct,
    RANK() OVER (ORDER BY ps.revenue DESC)                          AS revenue_rank
FROM product_stats ps
CROSS JOIN overall o
WHERE ps.revenue >= (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue)
                     FROM product_stats)
  AND ps.profit / ps.revenue < o.overall_margin
ORDER BY ps.revenue DESC;


-- -----------------------------------------------------
-- Q9. Category performance and contribution to total revenue
-- Business question: Which categories perform best / underperform?
-- -----------------------------------------------------
SELECT
    c.category_name,
    SUM(s.quantity)                                                 AS units_sold,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount), 2)    AS revenue,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount
              - s.quantity * s.unit_cost), 2)                       AS profit,
    ROUND(100.0 * SUM(s.quantity * s.unit_price - s.discount_amount
                      - s.quantity * s.unit_cost)
          / SUM(s.quantity * s.unit_price - s.discount_amount), 2)  AS margin_pct,
    ROUND(100.0 * SUM(s.quantity * s.unit_price - s.discount_amount)
          / SUM(SUM(s.quantity * s.unit_price - s.discount_amount)) OVER (), 2)
                                                                    AS revenue_share_pct
FROM sales s
JOIN products   p ON p.product_id  = s.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;


-- -----------------------------------------------------
-- Q10. Regional performance
-- Business question: Which regions contribute the most revenue and profit?
-- -----------------------------------------------------
SELECT
    r.region_name,
    COUNT(*)                                                        AS orders,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount), 2)    AS revenue,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount
              - s.quantity * s.unit_cost), 2)                       AS profit,
    ROUND(100.0 * SUM(s.quantity * s.unit_price - s.discount_amount
                      - s.quantity * s.unit_cost)
          / SUM(s.quantity * s.unit_price - s.discount_amount), 2)  AS margin_pct,
    ROUND(100.0 * SUM(s.quantity * s.unit_price - s.discount_amount)
          / SUM(SUM(s.quantity * s.unit_price - s.discount_amount)) OVER (), 2)
                                                                    AS revenue_share_pct
FROM sales s
JOIN regions r ON r.region_id = s.region_id
GROUP BY r.region_name
ORDER BY revenue DESC;


-- -----------------------------------------------------
-- Q11. Discount impact
-- Business question: How do discounts affect revenue and margin?
-- -----------------------------------------------------
SELECT
    CASE
        WHEN discount_amount = 0 THEN 'No discount'
        WHEN discount_type = 'percentage' THEN 'Percentage discount'
        ELSE 'Fixed amount discount'
    END                                                             AS discount_group,
    COUNT(*)                                                        AS orders,
    ROUND(SUM(discount_amount), 2)                                  AS total_discount_given,
    ROUND(SUM(quantity * unit_price - discount_amount), 2)          AS revenue,
    ROUND(100.0 * SUM(quantity * unit_price - discount_amount - quantity * unit_cost)
          / SUM(quantity * unit_price - discount_amount), 2)        AS margin_pct
FROM sales
GROUP BY 1
ORDER BY orders DESC;


-- -----------------------------------------------------
-- Q12. Top 10 customers by revenue
-- Business question: Who are the most valuable customers?
-- -----------------------------------------------------
SELECT
    cu.customer_name,
    r.region_name,
    COUNT(*)                                                        AS orders,
    ROUND(SUM(s.quantity * s.unit_price - s.discount_amount), 2)    AS revenue
FROM sales s
JOIN customers cu ON cu.customer_id = s.customer_id
JOIN regions   r  ON r.region_id    = cu.region_id
GROUP BY cu.customer_name, r.region_name, cu.customer_id
ORDER BY revenue DESC
LIMIT 10;