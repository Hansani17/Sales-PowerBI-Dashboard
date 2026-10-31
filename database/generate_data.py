"""
Generate realistic sample data for the Sales & Profitability Analytics project.

Usage (from the project root):
    python database/generate_data.py

Output:
    database/data.sql  (INSERT statements matching database/schema.sql)

Built-in patterns, so the dashboard has real insights to find:
  - Seasonality: Nov/Dec spike, Feb dip
  - Year-over-year growth (2023 -> 2025)
  - Electronics: high revenue but LOW margin
  - Furniture / Clothing: lower volume but HIGH margin
  - Mixed discounts: percentage, fixed amount, and none
"""
import calendar
import random
from datetime import date
from pathlib import Path

random.seed(42)  # reproducible output

# ------------------------------------------------------------------ config
BASE_ORDERS_PER_MONTH = 170
YEAR_GROWTH = {2023: 1.00, 2024: 1.12, 2025: 1.25}
MONTH_SEASONALITY = {
    1: 1.00, 2: 0.80, 3: 0.95, 4: 1.00, 5: 1.05, 6: 1.00,
    7: 0.95, 8: 1.00, 9: 1.05, 10: 1.15, 11: 1.40, 12: 1.60,
}
NUM_CUSTOMERS = 150

CATEGORIES = [
    "Electronics", "Furniture", "Clothing",
    "Home Appliances", "Sports & Outdoors",
]

# (region name, sales weight)
REGIONS = [
    ("Western", 0.35), ("Central", 0.20), ("Southern", 0.20),
    ("Eastern", 0.15), ("Northern", 0.10),
]

# (name, category_id, list_price, cost_ratio, popularity)
PRODUCTS = [
    # Electronics: popular, thin margins
    ("Smartphone", 1, 450, 0.82, 10),
    ("Laptop", 1, 900, 0.84, 6),
    ("Wireless Earbuds", 1, 80, 0.62, 9),
    ("Smartwatch", 1, 200, 0.70, 6),
    ("Tablet", 1, 350, 0.78, 5),
    ("Bluetooth Speaker", 1, 60, 0.60, 7),
    # Furniture: fewer sales, high margins
    ("Office Chair", 2, 150, 0.55, 5),
    ("Standing Desk", 2, 400, 0.58, 4),
    ("Bookshelf", 2, 120, 0.52, 4),
    ("Sofa", 2, 650, 0.60, 3),
    ("Dining Table", 2, 500, 0.57, 3),
    # Clothing: high volume, high margins
    ("T-Shirt", 3, 20, 0.45, 10),
    ("Jeans", 3, 50, 0.50, 8),
    ("Jacket", 3, 90, 0.52, 5),
    ("Sneakers", 3, 75, 0.58, 7),
    ("Dress", 3, 60, 0.48, 6),
    # Home appliances: medium
    ("Air Fryer", 4, 90, 0.68, 7),
    ("Blender", 4, 45, 0.65, 6),
    ("Vacuum Cleaner", 4, 180, 0.72, 4),
    ("Microwave Oven", 4, 130, 0.70, 4),
    ("Coffee Maker", 4, 70, 0.63, 6),
    ("Rice Cooker", 4, 55, 0.66, 6),
    # Sports & outdoors: mixed
    ("Yoga Mat", 5, 25, 0.50, 7),
    ("Dumbbell Set", 5, 80, 0.60, 5),
    ("Treadmill", 5, 700, 0.80, 2),
    ("Bicycle", 5, 320, 0.75, 3),
    ("Camping Tent", 5, 140, 0.62, 3),
]

FIRST_NAMES = [
    "Nimal", "Kamal", "Sunil", "Amal", "Ruwan", "Chamara", "Dilshan",
    "Kasun", "Isuru", "Tharindu", "Nadeesha", "Sanduni", "Dilini",
    "Hasini", "Malini", "Priya", "Anjali", "Thilini", "Sachini", "Ishara",
]
LAST_NAMES = [
    "Perera", "Silva", "Fernando", "Jayasinghe", "Bandara", "Wickramasinghe",
    "Gunawardena", "Rajapaksa", "Dissanayake", "Herath", "Samarasinghe",
    "Weerasinghe", "Kumara", "Senanayake", "Amarasinghe", "Ranasinghe",
    "Karunaratne", "Liyanage", "Abeysekera", "Pathirana",
]


# ----------------------------------------------------------------- helpers
def q(text):
    """Quote a string for SQL."""
    return "'" + str(text).replace("'", "''") + "'"


def write_inserts(f, table, columns, rows, batch=500):
    cols = ", ".join(columns)
    for i in range(0, len(rows), batch):
        chunk = rows[i:i + batch]
        values = ",\n".join("    (" + ", ".join(r) + ")" for r in chunk)
        f.write(f"INSERT INTO {table} ({cols}) VALUES\n{values};\n\n")


# ------------------------------------------------------------ build tables
region_names = [r[0] for r in REGIONS]
region_weights = [r[1] for r in REGIONS]

customers = []  # (id, name, email, region_id)
for cid in range(1, NUM_CUSTOMERS + 1):
    first = random.choice(FIRST_NAMES)
    last = random.choice(LAST_NAMES)
    region_id = random.choices(range(1, len(REGIONS) + 1), weights=region_weights)[0]
    email = f"{first}.{last}{cid}@example.com".lower()
    customers.append((cid, f"{first} {last}", email, region_id))

product_weights = [p[4] for p in PRODUCTS]

sales = []
for year in range(min(YEAR_GROWTH), max(YEAR_GROWTH) + 1):
    for month in range(1, 13):
        n_orders = int(
            BASE_ORDERS_PER_MONTH
            * YEAR_GROWTH[year]
            * MONTH_SEASONALITY[month]
            * random.uniform(0.93, 1.07)
        )
        last_day = calendar.monthrange(year, month)[1]
        for _ in range(n_orders):
            sale_date = date(year, month, random.randint(1, last_day))
            customer = random.choice(customers)
            pid = random.choices(range(1, len(PRODUCTS) + 1), weights=product_weights)[0]
            _, _, list_price, cost_ratio, _ = PRODUCTS[pid - 1]

            # 90% of sales happen in the customer's own region
            if random.random() < 0.90:
                region_id = customer[3]
            else:
                region_id = random.choices(range(1, len(REGIONS) + 1), weights=region_weights)[0]

            quantity = random.choices([1, 2, 3, 4, 5], weights=[45, 25, 15, 10, 5])[0]
            unit_price = round(list_price * random.uniform(0.97, 1.03), 2)
            unit_cost = round(list_price * cost_ratio * random.uniform(0.98, 1.02), 2)
            line_total = quantity * unit_price

            roll = random.random()
            if roll < 0.70:
                discount_type, discount_value = "amount", 0.0
            elif roll < 0.85:
                discount_type = "percentage"
                discount_value = float(random.choice([5, 10, 15, 20]))
            else:
                discount_type = "amount"
                discount_value = round(line_total * random.choice([0.03, 0.05, 0.08]), 2)

            # Safety checks (mirror the CHECK constraints in schema.sql)
            assert unit_cost < unit_price
            if discount_type == "percentage":
                assert 0 <= discount_value <= 100
            else:
                assert 0 <= discount_value <= line_total

            sales.append((sale_date, customer[0], pid, region_id, quantity,
                          unit_price, unit_cost, discount_type, discount_value))

sales.sort(key=lambda s: s[0])

# ----------------------------------------------------------------- write SQL
out_path = Path(__file__).resolve().parent / "data.sql"
with open(out_path, "w", encoding="utf-8") as f:
    f.write("-- Sample data for Sales & Profitability Analytics Dashboard\n")
    f.write("-- Generated by database/generate_data.py (seed = 42)\n")
    f.write("-- Safe to re-run: clears existing data first.\n\n")
    f.write("TRUNCATE sales, products, customers, regions, categories RESTART IDENTITY CASCADE;\n\n")

    write_inserts(f, "categories", ["category_id", "category_name"],
                  [(str(i), q(n)) for i, n in enumerate(CATEGORIES, 1)])

    write_inserts(f, "regions", ["region_id", "region_name"],
                  [(str(i), q(n)) for i, n in enumerate(region_names, 1)])

    write_inserts(f, "products", ["product_id", "product_name", "category_id", "list_price"],
                  [(str(i), q(p[0]), str(p[1]), f"{p[2]:.2f}")
                   for i, p in enumerate(PRODUCTS, 1)])

    write_inserts(f, "customers", ["customer_id", "customer_name", "email", "region_id"],
                  [(str(c[0]), q(c[1]), q(c[2]), str(c[3])) for c in customers])

    write_inserts(
        f, "sales",
        ["sale_id", "sale_date", "customer_id", "product_id", "region_id",
         "quantity", "unit_price", "unit_cost", "discount_type", "discount_value"],
        [(str(i), q(s[0].isoformat()), str(s[1]), str(s[2]), str(s[3]), str(s[4]),
          f"{s[5]:.2f}", f"{s[6]:.2f}", q(s[7]), f"{s[8]:.2f}")
         for i, s in enumerate(sales, 1)],
    )

    # Move the SERIAL sequences past the explicit IDs we inserted
    for table, col in [("categories", "category_id"), ("regions", "region_id"),
                       ("products", "product_id"), ("customers", "customer_id"),
                       ("sales", "sale_id")]:
        f.write(f"SELECT setval(pg_get_serial_sequence('{table}', '{col}'), "
                f"(SELECT MAX({col}) FROM {table}));\n")

# ------------------------------------------------------------------ summary
print(f"Wrote {out_path}")
print(f"  categories: {len(CATEGORIES)}  regions: {len(REGIONS)}  "
      f"products: {len(PRODUCTS)}  customers: {len(customers)}  sales: {len(sales)}")