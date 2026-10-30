# Fast-Track Plan — Sales & Profitability Dashboard

The original README lays out 6 phases. Here's the same project compressed into
a path you can realistically finish in a few focused sessions, using the files
already generated for you.

## What's already done for you
- `database/schema.sql` — full PostgreSQL schema (6 tables, indexed, FK'd)
- `database/generate_data.py` — generates ~7,500 realistic sales transactions
  across 3 years, 5 categories, 27 products, 5 regions, 120 customers, with
  seasonality (Nov/Dec spike, Feb dip) and year-over-year growth baked in
- `database/output_csv/` — the generated CSVs, ready to load
- `database/load_data.sql` — loads the CSVs into Postgres in one shot
- `database/analysis_queries.sql` — 10 SQL queries answering the exact
  business questions from your README (top products, YoY growth, margin
  outliers, regional performance, etc.)
- `documentation/dax_measures.md` — copy-paste DAX measure library

## Step 1 — Database (15–30 min)
1. Install PostgreSQL locally (or use a free instance on Neon/Supabase if you
   don't want to install anything — both work fine with Power BI).
2. `psql -f database/schema.sql`
3. `cd database && psql -f load_data.sql` (run from the `database/` folder so
   the relative CSV paths resolve)
4. Sanity check: `SELECT COUNT(*) FROM sales;` should return ~7,500.

**Shortcut:** if you want to skip Postgres entirely and go straight to Power BI,
you can load the CSVs in `database/output_csv/` directly via Power BI's
"Get Data → Text/CSV" and "Get Data → Combine" instead. You'll lose the "SQL
Analysis" phase for your portfolio story, so only do this if you're truly
optimizing for speed over completeness.

## Step 2 — Run the SQL analysis (15 min)
Run `analysis_queries.sql` in your SQL client. Screenshot 3–4 of the more
interesting results (e.g. YoY growth, top profit products) for your
`insights/business_insights.md` — this becomes evidence of the "SQL Analysis"
phase in your portfolio without extra work later.

## Step 3 — Power BI: connect and model (30–45 min)
1. Get Data → PostgreSQL database → point at your tables.
2. In Power Query, keep transformations minimal — the data is already clean.
3. Build the star schema: `Sales` (fact) in the center, `Products`,
   `Customers`, `Categories`, `Regions`, `Date` around it. Relationships should
   already resolve automatically from the FKs, but verify:
   - Sales[product_id] → Products[product_id]
   - Sales[customer_id] → Customers[customer_id]
   - Sales[region_id] → Regions[region_id]
   - Sales[sale_date] → Date[date_id]
   - Products[category_id] → Categories[category_id]
4. Mark `Date` as the official date table (Modeling → Mark as Date Table).

## Step 4 — DAX measures (15 min)
Create a blank "Measures" table and paste in everything from
`documentation/dax_measures.md`. Don't hand-build these one at a time — copy
the whole block in, then adjust table/column names only if yours differ.

## Step 5 — Build the 3 dashboard pages (2–3 hrs, the bulk of the work)
Skip trying to make every visual perfect on the first pass — get all three
pages populated with the right visuals first, polish styling last.

1. **Executive Overview** — KPI cards (Revenue, Profit, Margin, Orders) at the
   top, Revenue Trend line chart, Revenue vs Profit combo chart, Revenue by
   Category bar, Sales by Region map or bar. Add Year/Category/Region slicers.
2. **Product & Category Analysis** — Top 10 Products by Revenue and by Profit
   (two bar charts), Category performance matrix, a product table with
   conditional formatting on margin.
3. **Sales Trends** — Monthly Revenue/Profit line chart, Quarterly bar chart,
   YoY growth KPI card, a month-by-year matrix (heatmap-style with
   conditional formatting reads well here).

## Step 6 — Insights + polish (1 hr)
Write `insights/business_insights.md` using the answers from your SQL queries
and dashboard: 5–8 bullet findings (best/worst products, margin outliers,
regional gaps, seasonal pattern, YoY trend). This is what you'll actually talk
about in interviews — don't skip it even under time pressure.

## Step 7 — GitHub (30 min)
Push `README.md`, `database/`, `documentation/` (including a data model
screenshot and 3–4 dashboard screenshots), and `insights/business_insights.md`.
The `.pbix` file can go in `powerbi/`.

---
**Total realistic time if focused: roughly 5–7 hours split across 2–3
sessions**, with Step 5 (dashboard building) being where most of the time
goes. Steps 1–4 are now largely mechanical since the schema, data, and DAX are
already written for you.