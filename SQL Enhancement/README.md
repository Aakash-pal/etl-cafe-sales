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


### ✅ Week 2.1: Contextual Item Repair (Expanded)

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
### 🧪 Week 2.2: Quantity Column Repair (Contextual)

- Identified 479 rows with invalid `quantity` values: `'ERROR'`, `'UNKNOWN'`, or blank.
- Further narrowed to 441 rows where:
  - `price_per_unit` and `total_spent` are valid (numeric)
  - Formula: `quantity = total_spent / price_per_unit` holds true

#### SQL Analysis:
```sql
SELECT *
FROM staging_cafe_sales
WHERE quantity IN ('UNKNOWN', '', 'ERROR')
  AND price_per_unit NOT IN ('UNKNOWN', '', 'ERROR')
  AND total_spent NOT IN ('UNKNOWN', '', 'ERROR');
  
### 🧪 Week 2.3: Quantity Column Repair (Calculated Logic)

- Identified 479 rows where `quantity` was invalid: `'ERROR'`, `'UNKNOWN'`, or blank.
- Further narrowed to 441 rows where:
  - `price_per_unit` and `total_spent` were valid
  - `quantity` could be derived using:
    ```sql
    quantity = total_spent / price_per_unit
    ```

- Updated the staging layer to include a new `CASE` expression for `quantity`:
    - Replaced dirty values with the calculated result (rounded to integer)
    - Preserved clean values by casting directly
    - Remaining dirty rows (`38`) left as `NULL` for now (due to insufficient info)

#### ✅ Validated with:
```sql
SELECT COUNT(*) FROM staging_cafe_sales WHERE quantity IS NULL;  -- Result: 38
SELECT COUNT(*) FROM staging_cafe_sales WHERE quantity IS NOT NULL;  -- Successfully repaired remainder

### 💵 Week 2.4: Price Per Unit Repair (Calculated Logic)

- Identified rows where `price_per_unit` was missing or invalid (`NULL`, `'ERROR'`, `'UNKNOWN'`)there were 533 rows
- For rows with valid `quantity` and `total_spent`, calculated missing values using: after which the count is 479 rows
  
  ```sql
  price_per_unit = total_spent / quantity

### 🧭 Week 2.5: Location Column Repair (Rule-Based Inference)

- Identified that `location` had numerous invalid entries such as `'ERROR'`, `'UNKNOWN'`, `''`, and `NULL`
- Developed rule-based logic using combinations of `item` and `payment_method` to infer the most likely `location`
- Used frequency analysis via grouped queries to determine dominant patterns
- Created a unified `CASE` statement to fill in missing values based on business logic

#### ✅ Key Rules Applied:

| Payment Method  | Items                           | Inferred Location |
|-----------------|----------------------------------|-------------------|
| Cash            | Cake, Juice, Salad, Smoothie     | In-store          |
| Cash            | Coffee, Cookie, Sandwich, Tea    | Takeaway          |
| Credit Card     | Cookie, Juice, Salad, Sandwich   | In-store          |
| Credit Card     | Coffee, Cake, Smoothie, Tea      | Takeaway          |
| Digital Wallet  | Cake, Juice, Sandwich            | In-store          |
| Digital Wallet  | Coffee, Cookie, Salad, Tea, Smoothie | Takeaway     |

#### 🧠 CASE Snippet:
```sql
CASE
  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Cake', 'Juice', 'Salad', 'Smoothie') 
       AND payment_method = 'Cash'
  THEN 'In-store'
  ...
  ELSE NULLIF(NULLIF(NULLIF(location, 'ERROR'), 'UNKNOWN'), '')
END AS location

📊 Impact of Transformation:
🔍 Initial dirty location rows: 3,961

✅ Remaining dirty rows after transformation: 1,555

Repaired over 60% of invalid locations using pattern-based rules

### 📅 Week 2.6: Transaction Date Cleaning & Repair

- The `transaction_date` column contained 460 invalid or missing entries (`'ERROR'`, `'UNKNOWN'`, `''`, or `NULL`)
- Analyzed value distribution by item and date, but found no consistent patterns for data-driven inference
- To preserve data integrity and auditability, applied industry-standard placeholder repair strategy
- A format audit showed that **100% of valid entries (9,540 rows)** used the `YYYY-MM-DD` format, with no alternate or mixed styles


#### 🛠️ Final Repair Logic:
```sql
CASE
  WHEN transaction_date IS NULL OR transaction_date IN ('ERROR', 'UNKNOWN', '')
  THEN TO_DATE('1900-01-01', 'YYYY-MM-DD')  -- Placeholder for unknown dates

  ELSE TO_DATE(transaction_date, 'YYYY-MM-DD')  -- Clean values
END AS transaction_date

### 💳 Week 2.7: Payment Method Cleaning & Inference

- The `payment_method` column contained 3,178 invalid or missing values (`'ERROR'`, `'UNKNOWN'`, `''`, or `NULL`)
- Used rule-based inference logic with `item` and `location` fields to repair values
- Grouped rows by common transaction patterns to identify dominant combinations
- Applied explicit mapping rules for both `In-store` and `Takeaway` contexts after Transformation there were 1478 rows with bad data.

#### 🛠️ Final CASE Logic (Partial View):
```sql
CASE 
  WHEN payment_method IN ('', 'UNKNOWN', 'ERROR') AND item IN (...) AND location = 'In-store'
  THEN 'Cash'
  ...
  ELSE NULLIF(NULLIF(NULLIF(payment_method, 'UNKNOWN'), 'ERROR'), '')
END AS payment_method



