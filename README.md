# 📊 Sales & Profitability Analytics Dashboard

An interactive Business Intelligence project built with **PostgreSQL, SQL, Power BI and DAX** to analyze sales performance, revenue, profitability, product performance and business trends.

> 🚧 **Status:** In development. See the [progress checklist](#-project-progress) below.

---

## 📌 Project Overview

Businesses generate large amounts of transactional sales data, but raw data alone does not help management make decisions. This project turns raw sales transactions into meaningful business insights through a complete analytics workflow:

```
Raw Sales Data → PostgreSQL → SQL Analysis → Power Query → Data Model → DAX → Power BI Dashboard → Business Insights
```

A relational PostgreSQL database stores the sales data. Power BI is then used to transform, model and visualize it in an interactive dashboard that lets users monitor KPIs, spot trends, compare products and categories, and evaluate profitability.

## 🎯 Business Problem

A hypothetical mid-sized retail company sells products across several categories and regions. It has a large volume of sales transactions but no centralized way to monitor sales and profitability.

Management needs answers to questions such as:

- How much revenue and profit is the business generating, and what is the profit margin?
- How are sales changing over time? Are revenue and profit growing together?
- Which products, categories and regions perform best or worst?
- Which months are strongest and weakest?
- Which products have high sales but low profitability?

## 🎯 Project Objectives

1. Store and manage sales data in a relational SQL database.
2. Analyze sales transactions using SQL.
3. Prepare and transform data for analytics.
4. Build a structured data model for BI reporting.
5. Create meaningful sales and profitability KPIs.
6. Analyze monthly and yearly trends.
7. Evaluate product and category performance.
8. Develop an interactive Power BI dashboard.
9. Identify business trends and performance patterns.
10. Provide actionable insights for management decisions.

## 🏢 Business Scenario

Each sales transaction records: sale date, customer, product, product category, quantity, unit price, discount, unit cost and region. The dataset represents realistic transactions over multiple years so that meaningful time-based and profitability analysis is possible.

## 📈 Key Performance Indicators

| KPI | Description |
|---|---|
| Total Revenue | Net revenue from sales (after discounts) |
| Total Profit | Revenue remaining after product costs |
| Profit Margin | Profit as a percentage of revenue |
| Total Orders | Number of sales transactions |
| Units Sold | Total quantity of products sold |
| Average Order Value | Average revenue per order |
| Revenue Growth % | Percentage change in revenue over time |
| Profit Growth % | Percentage change in profit over time |

## 🔍 Analysis Areas

- **Sales performance:** revenue, orders, units sold, average order value, monthly and yearly sales
- **Profitability:** profit and margin by product, category and region; revenue vs profit
- **Time-based:** monthly and quarterly trends, Year-over-Year and Month-over-Month growth
- **Products:** top 10 products, product margin, high-revenue/low-margin products
- **Categories:** revenue, profit, units, margin and sales contribution
- **Regions:** revenue, profit, orders and regional contribution

## 🛠 Technology Stack

| Area | Tools |
|---|---|
| Database | PostgreSQL, SQL, pgAdmin |
| Business Intelligence | Microsoft Power BI, Power Query, DAX |
| Development & Docs | Git, GitHub, Markdown, VS Code |

## 🗄 Data Model

A star schema with `sales` as the central fact table.

```
categories ── products ──┐
                         │
customers ────────────── sales ──── regions
                         │
                       date (created in Power BI)
```

| Table | Type | Purpose |
|---|---|---|
| `sales` | Fact | One row per sale transaction |
| `products` | Dimension | Product details and category link |
| `categories` | Dimension | Product categories |
| `customers` | Dimension | Customer details |
| `regions` | Dimension | Sales regions |
| `date` | Dimension | Calendar table, created with DAX in Power BI |

### Design decisions

- **Flexible discounts:** each sale stores a `discount_type` (`percentage` or `amount`) and a `discount_value`. A PostgreSQL generated column, `discount_amount`, always converts the discount into currency, so reporting uses a single consistent value.
- **Cost snapshot:** `unit_cost` is stored on each sale so historical profit stays accurate if costs change later.
- **Data integrity:** primary keys, foreign keys and `CHECK` constraints prevent invalid data (negative quantities, discounts over 100%, etc.).

## 📊 Dashboard Pages (planned)

1. **Executive Overview:** KPI cards, revenue and profit trends, revenue vs profit, revenue by category, sales by region, Year/Category/Region slicers.
2. **Product & Category Analysis:** top 10 products by revenue and profit, category performance, product performance table, category matrix, slicers.
3. **Sales Trends:** monthly revenue and profit trends, quarterly revenue, Year-over-Year growth, monthly performance matrix, date filters.

**Interactive features:** slicers, cross-filtering, drill-down, tooltips, page navigation, KPI cards.

## 🧮 Example DAX Measures

```dax
Total Revenue =
SUMX(
    Sales,
    Sales[quantity] * Sales[unit_price] - Sales[discount_amount]
)

Total Cost =
SUMX(
    Sales,
    Sales[quantity] * Sales[unit_cost]
)

Total Profit = [Total Revenue] - [Total Cost]

Profit Margin = DIVIDE([Total Profit], [Total Revenue], 0)

Total Orders = DISTINCTCOUNT(Sales[sale_id])
```

Additional measures planned: YoY Revenue/Profit Growth, YTD and MTD Revenue, Average Order Value, Category Contribution, Product Ranking.

## 📁 Project Structure

```
Sales-PowerBI-Dashboard/
├── README.md
├── database/
│   ├── schema.sql
│   ├── data.sql
│   └── analysis_queries.sql
├── powerbi/
│   └── Sales_Dashboard.pbix
├── documentation/
│   ├── data_model.png
│   ├── requirements.md
│   └── dashboard_screenshots/
└── insights/
    └── business_insights.md
```

## ✅ Project Progress

- [ ] **Phase 1:** Database development (schema, sample data, validation)
- [ ] **Phase 2:** SQL analysis
- [ ] **Phase 3:** Power BI connection, Power Query and data model
- [ ] **Phase 4:** DAX measures and dashboard pages
- [ ] **Phase 5:** Business insights and recommendations
- [ ] **Phase 6:** Portfolio polish (screenshots, documentation)

## 💡 Expected Business Insights

High- and low-performing products and categories, revenue and profit trends, seasonal patterns, regional differences, changes in profitability, and products with high revenue but low margins. The goal is not just to visualize data, but to turn findings into practical business recommendations.

## 👤 Author

**Ishanka Pallewela**
Business Intelligence / Data Analytics Portfolio Project
