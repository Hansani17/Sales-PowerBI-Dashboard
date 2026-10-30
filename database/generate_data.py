"""
Generates realistic synthetic sales data for the
Sales & Profitability Analytics Dashboard project.

Outputs CSV files ready to load into PostgreSQL (via \copy or COPY),
or straight into Power BI / Excel if you want to skip the database step
entirely and prototype faster.

Run:  python generate_data.py
Output folder: ./output_csv/
"""

import csv
import random
from datetime import date, timedelta

random.seed(42)
OUT_DIR = "output_csv"
import os
os.makedirs(OUT_DIR, exist_ok=True)

# ---------------------------------------------------------
# 1. Reference data
# ---------------------------------------------------------
regions = ["North", "South", "East", "West", "Central"]

categories = ["Electronics", "Home & Kitchen", "Apparel", "Sports & Outdoors", "Beauty & Personal Care"]

products_by_category = {
    "Electronics": [("Wireless Earbuds", 25), ("Bluetooth Speaker", 30), ("Smartwatch", 60),
                     ("Laptop Stand", 15), ("USB-C Hub", 18), ("Gaming Mouse", 20)],
    "Home & Kitchen": [("Air Fryer", 45), ("Blender", 25), ("Coffee Maker", 35),
                        ("Cookware Set", 55), ("Vacuum Cleaner", 70)],
    "Apparel": [("Running Shoes", 28), ("Denim Jacket", 22), ("Hoodie", 15),
                ("Backpack", 20), ("Sunglasses", 10)],
    "Sports & Outdoors": [("Yoga Mat", 8), ("Dumbbell Set", 40), ("Camping Tent", 65),
                           ("Cycling Helmet", 18), ("Water Bottle", 5)],
    "Beauty & Personal Care": [("Hair Dryer", 20), ("Electric Shaver", 25), ("Skincare Set", 30),
                                ("Perfume", 35), ("Makeup Kit", 28)],
}

customer_first = ["James", "Maria", "Liam", "Ayesha", "Noah", "Olivia", "Kasun", "Nimali",
                   "Ethan", "Sophia", "Ravi", "Chen", "Amara", "Lucas", "Isabella"]
customer_last = ["Perera", "Fernando", "Silva", "Smith", "Johnson", "Kumar", "Lee",
                  "Garcia", "Wickramasinghe", "Brown", "Rodriguez", "Costa"]

# ---------------------------------------------------------
# 2. Build dimension tables
# ---------------------------------------------------------
region_rows = [(i + 1, r) for i, r in enumerate(regions)]

category_rows = [(i + 1, c) for i, c in enumerate(categories)]
category_id_map = {c: i + 1 for i, c in enumerate(categories)}

product_rows = []
product_id = 1
product_id_map = {}  # name -> (id, cost, category_id)
for cat, plist in products_by_category.items():
    for name, cost in plist:
        product_rows.append((product_id, name, category_id_map[cat], cost))
        product_id_map[name] = (product_id, cost, category_id_map[cat])
        product_id += 1

customer_rows = []
for cid in range(1, 121):  # 120 customers
    name = f"{random.choice(customer_first)} {random.choice(customer_last)}"
    region_id = random.randint(1, len(regions))
    customer_rows.append((cid, name, region_id))

# Date dimension: 3 full years
start_date = date(2023, 1, 1)
end_date = date(2025, 12, 31)
date_rows = []
d = start_date
weekday_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
month_names = ["January", "February", "March", "April", "May", "June", "July",
               "August", "September", "October", "November", "December"]
while d <= end_date:
    date_rows.append((
        d.isoformat(), d.year, (d.month - 1) // 3 + 1, d.month,
        month_names[d.month - 1], d.day, weekday_names[d.weekday()]
    ))
    d += timedelta(days=1)

# ---------------------------------------------------------
# 3. Generate sales transactions (with seasonality + growth trend)
# ---------------------------------------------------------
sales_rows = []
sale_id = 1
all_dates = [r[0] for r in date_rows]
product_list = list(product_id_map.items())  # (name, (id, cost, category_id))

for idx, d_str in enumerate(all_dates):
    d_year = date.fromisoformat(d_str).year
    d_month = date.fromisoformat(d_str).month

    # Base number of transactions per day, with slight upward trend over years
    year_factor = 1.0 + (d_year - 2023) * 0.15
    # Seasonality: higher sales in Nov/Dec, lower in Feb
    season_factor = 1.4 if d_month in (11, 12) else (0.75 if d_month == 2 else 1.0)
    base_txns = max(1, int(random.gauss(6, 2) * year_factor * season_factor))

    for _ in range(base_txns):
        pname, (pid, cost, cat_id) = random.choice(product_list)
        customer_id = random.randint(1, len(customer_rows))
        region_id = random.randint(1, len(regions))
        quantity = random.randint(1, 5)
        markup = random.uniform(1.3, 2.2)
        unit_price = round(cost * markup, 2)
        discount = round(unit_price * quantity * random.choice([0, 0, 0, 0.05, 0.1, 0.15]), 2)

        sales_rows.append((
            sale_id, d_str, customer_id, pid, region_id,
            quantity, unit_price, discount, cost
        ))
        sale_id += 1

# ---------------------------------------------------------
# 4. Write CSV files
# ---------------------------------------------------------
def write_csv(filename, header, rows):
    with open(os.path.join(OUT_DIR, filename), "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

write_csv("regions.csv", ["region_id", "region_name"], region_rows)
write_csv("categories.csv", ["category_id", "category_name"], category_rows)
write_csv("products.csv", ["product_id", "product_name", "category_id", "unit_cost"], product_rows)
write_csv("customers.csv", ["customer_id", "customer_name", "region_id"], customer_rows)
write_csv("date_dim.csv", ["date_id", "year", "quarter", "month", "month_name", "day", "weekday_name"], date_rows)
write_csv("sales.csv", ["sale_id", "sale_date", "customer_id", "product_id", "region_id",
                         "quantity", "unit_price", "discount", "unit_cost"], sales_rows)

print(f"Done. Generated {len(sales_rows)} sales transactions across {len(date_rows)} days.")
print(f"CSV files written to ./{OUT_DIR}/")