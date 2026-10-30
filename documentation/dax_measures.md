# DAX Measures Library

Paste these into a dedicated "Measures" table in Power BI (Modeling → New Measure).
Assumes your fact table is called `Sales` and your date table `Date` is marked as
the official Date Table (Modeling → Mark as Date Table), joined on `sale_date` → `date_id`.

## Core measures

```
Total Revenue =
SUMX(Sales, Sales[quantity] * Sales[unit_price] - Sales[discount])

Total Cost =
SUMX(Sales, Sales[quantity] * Sales[unit_cost])

Total Profit =
[Total Revenue] - [Total Cost]

Profit Margin =
DIVIDE([Total Profit], [Total Revenue], 0)

Total Orders =
DISTINCTCOUNT(Sales[sale_id])

Total Units Sold =
SUM(Sales[quantity])

Average Order Value =
DIVIDE([Total Revenue], [Total Orders], 0)
```

## Time intelligence

```
Revenue LY =
CALCULATE([Total Revenue], SAMEPERIODLASTYEAR('Date'[date_id]))

Revenue YoY % =
DIVIDE([Total Revenue] - [Revenue LY], [Revenue LY], 0)

Profit LY =
CALCULATE([Total Profit], SAMEPERIODLASTYEAR('Date'[date_id]))

Profit YoY % =
DIVIDE([Total Profit] - [Profit LY], [Profit LY], 0)

Revenue MTD =
TOTALMTD([Total Revenue], 'Date'[date_id])

Revenue YTD =
TOTALYTD([Total Revenue], 'Date'[date_id])

Revenue PM (Prior Month) =
CALCULATE([Total Revenue], DATEADD('Date'[date_id], -1, MONTH))

Revenue MoM % =
DIVIDE([Total Revenue] - [Revenue PM], [Revenue PM], 0)
```

## Ranking / contribution

```
Product Revenue Rank =
RANKX(ALL(Products[product_name]), [Total Revenue], , DESC)

Category Contribution % =
DIVIDE([Total Revenue], CALCULATE([Total Revenue], ALL(Categories)), 0)

Region Contribution % =
DIVIDE([Total Revenue], CALCULATE([Total Revenue], ALL(Regions)), 0)
```

## Notes
- Keep `unit_cost`, `unit_price`, `discount`, `quantity` at the row level in the
  Sales table; don't pre-aggregate revenue/profit in Power Query — let DAX do it,
  so filters/slicers stay dynamic.
- Build a proper Date table (or use the `date_dim` table generated for you) and
  relate it to `Sales[sale_date]` — this is required for every time-intelligence
  measure above to work.