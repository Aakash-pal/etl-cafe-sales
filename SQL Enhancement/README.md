# 📊 SQL-Only ETL: Cafe Sales Data Cleanup

This project demonstrates a **pure SQL ETL pipeline** for cleaning and transforming raw café transaction data. It uses PostgreSQL and DBeaver, showcasing advanced SQL skills including conditional logic, staging layers, type casting, and validation.

---

## 📁 Dataset

- **Source:** `dirty_cafe_sales.csv`
- **Rows:** 10,000
- **Issues:** Contains `"ERROR"`, `"UNKNOWN"`, `NULL`, and untyped values across several fields.

---

## 🧱 SQL Pipeline Structure

| Stage | Table/View | Purpose |
|-------|------------|---------|
| Raw Load | `raw_cafe_sales` | Imported directly from CSV (all columns as `TEXT`) |
| Repair Layer | `staging_cafe_sales` | Applies conditional `CASE` logic to repair fields like `item` |
| Cleaned View | `cleaned_cafe_sales` *(coming next)* | Final type-cast and validated output |

---

## ✅ What’s Completed

### Week 1: Raw Load

- Created `raw_cafe_sales` table
- Imported all 10,000 rows using DBeaver
- Verified structure and data shape

```sql
SELECT COUNT(*) FROM raw_cafe_sales;
SELECT * FROM raw_cafe_sales LIMIT 5;

### Week 2: Intelligent Repair Layer
- Created staging_cafe_sales using CREATE TABLE AS SELECT

- Repaired invalid item values using contextual CASE logic

- Verified that rows matching "Cake" logic were properly filled

- 869 rows remain with unresolved item values for future review


### ✅ Week 2: Contextual Item Repair (Expanded)

- Expanded the `CASE` logic in `staging_cafe_sales` to cover additional `item` categories:
  - `Cake`, `Coffee`, `Cookie`, `Juice`, `Salad`, `Sandwich`, `Smoothie`, `Tea`
- Logic uses combinations of:
  - `price_per_unit`, `payment_method`, and `location`
- Cleaned rows based on price-based inference
- Remaining rows with ambiguous or invalid `item` values: **724**
- These will be investigated later for deeper repair or filtering

#### Sample CASE logic:
```sql
CASE
  WHEN (item IS NULL OR item IN ('UNKNOWN', 'ERROR', ''))
       AND price_per_unit = '2.0'
       AND payment_method IN (...) 
       AND location IN (...) 
  THEN 'Coffee'
  ...

