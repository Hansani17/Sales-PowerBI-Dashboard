-- =====================================================
-- Sales & Profitability Analytics Dashboard
-- Database schema (PostgreSQL 12+)
-- =====================================================

-- Re-runnable: drop in reverse dependency order
DROP TABLE IF EXISTS sales      CASCADE;
DROP TABLE IF EXISTS products   CASCADE;
DROP TABLE IF EXISTS customers  CASCADE;
DROP TABLE IF EXISTS regions    CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- ---------- Dimension tables ----------

CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id  INT NOT NULL REFERENCES categories(category_id),
    list_price   NUMERIC(12,2) NOT NULL CHECK (list_price >= 0),
    UNIQUE (product_name, category_id)
);

CREATE TABLE regions (
    region_id   SERIAL PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    email         VARCHAR(150),
    region_id     INT REFERENCES regions(region_id)
);

-- ---------- Fact table ----------

CREATE TABLE sales (
    sale_id        SERIAL PRIMARY KEY,
    sale_date      DATE NOT NULL,
    customer_id    INT NOT NULL REFERENCES customers(customer_id),
    product_id     INT NOT NULL REFERENCES products(product_id),
    region_id      INT NOT NULL REFERENCES regions(region_id),
    quantity       INT NOT NULL CHECK (quantity > 0),
    unit_price     NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost      NUMERIC(12,2) NOT NULL CHECK (unit_cost >= 0),

    -- Discount can be a percentage (e.g. 10 = 10%) or a fixed amount (e.g. 500.00)
    discount_type  VARCHAR(10) NOT NULL DEFAULT 'amount'
                   CHECK (discount_type IN ('percentage', 'amount')),
    discount_value NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (discount_value >= 0),

    -- Always the discount in currency, calculated automatically
    discount_amount NUMERIC(12,2) GENERATED ALWAYS AS (
        CASE
            WHEN discount_type = 'percentage'
                THEN ROUND(quantity * unit_price * discount_value / 100, 2)
            ELSE discount_value
        END
    ) STORED,

    -- Percentage can't exceed 100, amount can't exceed the line total
    CONSTRAINT chk_discount_valid CHECK (
        (discount_type = 'percentage' AND discount_value <= 100)
        OR (discount_type = 'amount' AND discount_value <= quantity * unit_price)
    )
);

-- ---------- Indexes on foreign keys and date ----------

CREATE INDEX idx_sales_date     ON sales(sale_date);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_sales_product  ON sales(product_id);
CREATE INDEX idx_sales_region   ON sales(region_id);
CREATE INDEX idx_products_cat   ON products(category_id);