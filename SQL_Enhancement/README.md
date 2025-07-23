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


### Week 2.1: Contextual Item Repair (Expanded)

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


###💰 Week 2.8: Total Spent Cleaning & Calculation
The total_spent column initially contained 502 invalid or missing values ('ERROR', 'UNKNOWN', '', or NULL)

Used derived calculation logic based on valid quantity and price_per_unit fields

Ensured numeric safety by casting supporting fields to NUMERIC type after filtering out invalid strings

Confirmed that quantity * price_per_unit provides accurate estimates for missing total_spent values

After transformation, 462 rows were successfully repaired, leaving only 40 rows unrepaired due to invalid or missing values in dependent fields

🛠️ Final CASE Logic (Simplified View):
sql
Copy
Edit
CASE
  WHEN (total_spent IS NULL OR total_spent IN ('', 'UNKNOWN', 'ERROR'))
    AND quantity IS NOT NULL
    AND price_per_unit IS NOT NULL
  THEN (CAST(price_per_unit AS NUMERIC) * CAST(quantity AS NUMERIC))::NUMERIC

  WHEN total_spent NOT IN ('ERROR', 'UNKNOWN', '')
  THEN CAST(total_spent AS NUMERIC)

  ELSE NULL
END AS total_spent

###💰 Week 2.9: Price Per Unit Cleaning & Repair
The price_per_unit column originally had 482 invalid or missing entries ('ERROR', 'UNKNOWN', '', or NULL)

Initial logic erroneously cast decimal values to integers, leading to incorrect values (e.g., 1.5 → 2)

Further analysis revealed that valid entries were being overwritten even when no transformation was needed

Refined logic now:

Only targets truly invalid values

Preserves clean values without alteration

Ensures decimal precision (e.g., 1.5 for Tea, 2.0 for Coffee)

After applying the updated transformation, only 37 invalid entries remained, primarily due to rows where supporting fields like quantity or total_spent were still invalid

🛠️ Final Repair Logic (for price_per_unit):
sql
Copy
Edit
CASE 
  WHEN (price_per_unit IS NULL OR price_per_unit IN ('ERROR', 'UNKNOWN', ''))
       AND quantity IS NOT NULL AND total_spent IS NOT NULL
       AND NULLIF(quantity, '') ~ '^[0-9]+$'
       AND NULLIF(total_spent, '') ~ '^[0-9\.]+$'
  THEN ROUND(CAST(total_spent AS NUMERIC) / CAST(quantity AS NUMERIC), 2)

  WHEN price_per_unit NOT IN ('ERROR', 'UNKNOWN', '')
  THEN CAST(price_per_unit AS NUMERIC)

  ELSE NULL
END AS price_per_unit
📊 Post-Transformation Summary
Stage	Count
Invalid values before transformation	482
Remaining invalid values after transformation	37
Decimal precision restored (e.g., Tea = 1.5)	✅ Confirmed

###🏪 Week 2.10: Location Cleaning & Inference
The location column originally contained 3,143 invalid or missing entries ('ERROR', 'UNKNOWN', '', or NULL)

Initial inference logic used combinations of item and payment_method to map to either 'In-store' or 'Takeaway' based on dominant transaction patterns

After first pass repair, 1,705 rows were corrected using this logic

A second analysis of remaining null rows highlighted potential to infer location using a safe combination of item and price_per_unit

For example:

Tea with price 1.5 → Takeaway

Cake with price 3.0 → In-store

Cookie with price 1.0 → Takeaway

To avoid casting errors, price fields were validated using regex (~ '^\d+(\.\d+)?$') before conversion

Final logic preserves clean values and applies inference only where all supporting fields are present and clean

After applying both inference strategies, only 442 rows remain with unknown location, primarily due to insufficient supporting data

📊 Most Common Remaining Null Patterns (Sample):
Item	Payment Method	Price Per Unit	Count
(null)	Credit Card	4.0	34
(null)	(null)	3.0	32
(null)	Credit Card	3.0	19
Tea	(null)	1.5	6
Cookie	(null)	1.0	7
Coffee	(null)	2.0	10
(null)	(null)	(null)	…

🛠️ Final Repair Logic (Excerpt):
sql
Copy
Edit
CASE
  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Cake', 'Juice', 'Salad', 'Smoothie') 
       AND payment_method = 'Cash'
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Coffee', 'Cookie', 'Sandwich', 'Tea') 
       AND payment_method = 'Cash'
  THEN 'Takeaway'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Tea' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.5
  THEN 'Takeaway'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Cake' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 3.0
  THEN 'In-store'

  ...
  
  ELSE NULLIF(NULLIF(NULLIF(location, 'ERROR'), 'UNKNOWN'), '')
END AS location

### Week 2.11: Item Cleaning & Inference
The item column initially had 969 invalid or missing entries ('ERROR', 'UNKNOWN', '', or NULL)

Early attempts at fixing item using price_per_unit failed due to:

Implicit casting issues (e.g., comparing TEXT with NUMERIC)

Overwriting of valid values and incorrect assumptions

Analysis revealed dual-mapping cases (e.g., price_per_unit = 3.0 could be Cake or Juice) and safe cases (e.g., 1.0 is always Cookie)

A robust repair strategy was developed using safe patterns with explicit numeric casting and contextual inference:

Used payment_method and location alongside price_per_unit to disambiguate values

Ensured no assumptions were made about existing column data types — all comparisons safely casted

After applying the improved logic:

item column reduced from 969 bad values to just 195

Remaining nulls correspond to rows with insufficient supporting context

🛠️ Final Case repair Logic (Excerpt):
CASE
  -- Dual: Cake vs Juice
  WHEN item IS NULL AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 3.0 THEN
    CASE
      WHEN payment_method IN ('Cash', 'Credit Card', 'Digital Wallet') AND location = 'In-store' THEN 'Cake'
      WHEN payment_method IN ('Cash', 'Credit Card', 'Digital Wallet') AND location = 'Takeaway' THEN 'Juice'
      ELSE NULL
    END

  -- Dual: Salad vs Sandwich
  WHEN item IS NULL AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 5.0 THEN
    CASE
      WHEN location = 'In-store' THEN 'Salad'
      WHEN location = 'Takeaway' THEN 'Sandwich'
      ELSE NULL
    END

  -- Safe mappings
  WHEN item IS NULL AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.0 THEN 'Cookie'
  WHEN item IS NULL AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.5 THEN 'Tea'
  WHEN item IS NULL AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 2.0 THEN 'Coffee'
  WHEN item IS NULL AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 4.0 THEN 'Smoothie'

  -- Preserve valid values
  ELSE NULLIF(NULLIF(NULLIF(item, 'ERROR'), 'UNKNOWN'), '')
END AS item

### Week 2.12 ☕ Cafe Sales Data Repair Using SQL CTEs


## ❌ Original Query Challenges

The initial approach used a single `CREATE TABLE AS SELECT` statement filled with layered `CASE` expressions to infer values. However, this caused unexpected behavior:

- 🔄 **Dependent Columns Were Evaluated in Isolation**  
  For example, `payment_method` logic relied on knowing `item` and `location`, but those values were also being inferred simultaneously within the same query. SQL doesn’t guarantee evaluation order across columns, causing `payment_method` to remain unresolved in many rows.

- ⚠️ **Incomplete Support Data**  
  Some rows lacked values in key columns required to infer others. E.g., records with null `item`, `location`, or `price_per_unit` couldn’t be logically repaired.

- 🧩 **Hard to Debug and Maintain**  
  The all-in-one query was difficult to read and nearly impossible to isolate where logic failed across different columns.

---

## ✅ Solution: Modular Cleanup via CTEs

The query was refactored using CTEs to introduce clarity and ordered logical processing. Each CTE performs a targeted transformation:

### CTE Breakdown:

| CTE Name | Responsibility |
|---------|----------------|
| `raw_cleaned` | Cleans `quantity`, `price_per_unit`, and `total_spent` |
| `item_repaired` | Infers missing or invalid `item` values contextually |
| `location_resolved` | Determines missing `location` using item and payment method |
| `payment_method_resolved` | Infers `payment_method` based on repaired fields |
| Final `SELECT` | Assembles cleaned data into `staging_cafe_sales` table |

This sequencing ensures each field uses the most up-to-date values inferred earlier in the flow. It also improves readability, maintainability, and offers clear debug checkpoints.

---

## 📦 Output Table: `staging_cafe_sales`

Contains:
- Fully repaired `item`, `quantity`, `price_per_unit`, `total_spent`, `payment_method`, and `location`
- Validated `transaction_date` using a default fallback date (`1900-01-01`) when missing
- Logical inference based on contextual patterns between fields

---

## 📚 Learnings

- 🔍 Column dependency matters — resolve key fields in logical order.
- ⚙️ Use CTEs to layer complexity while keeping logic modular.
- 🧪 Break big transformations into focused steps for clarity and testing.
- 🧼 Ensure regex and numeric parsing safely handle edge cases.


### Week 2.13 🧹 Further Data Cleaning & Repair


## 🚩 Initial Challenges

Raw data issues identified:
- Invalid entries like `'ERROR'`, `'UNKNOWN'`, and empty strings across multiple columns.
- Missing values in key fields (`item`, `quantity`, `price_per_unit`, `total_spent`, `location`, `payment_method`).
- Fields with incorrect formats, making calculation or inference tricky.

### Null Counts Before Cleaning

| Field            | Null Rows |
|------------------|-----------|
| `item`           | 152       |
| `quantity`       | 38        |
| `price_per_unit` | 38        |
| `total_spent`    | 40        |
| `location`       | 160       |
| `payment_method` | 54        |

---

## 🔧 Data Cleaning Logic (CTEs Overview)

### 1. `raw_cleaned`
- Parsed and repaired `quantity`, `price_per_unit`, and `total_spent` using arithmetic fallback rules.
- Casted numeric values safely after stripping invalid entries.

### 2. `item_repaired`
- Mapped common pricing and location combinations to infer missing `item` entries.
- Added fallback logic for borderline cases based on patterns.

### 3. `location_resolved`
- Used known item-location relationships and cleaned price tiers to infer location.
- Added fallback logic where both item and location were missing.

### 4. `payment_method_resolved`
- Introduced multi-level fallback: item-location rules, price-based inference, and transaction-type assumptions.

---

## 📊 Final Results After Cleaning

| Field            | Null Rows |
|------------------|-----------|
| `item`           | 6         |
| `quantity`       | 38        |
| `price_per_unit` | 38        |
| `total_spent`    | 40        |
| `location`       | 3         |
| `payment_method` | 3         |

This represents a **massive reduction** in null counts—especially for fields that were previously over 100 nulls. Most remaining nulls represent truly unrecoverable or ambiguous rows, which were intentionally left untouched to avoid risky assumptions.

---

## 🙌 Inspiration

Inspired by real-world messy datasets and the joys of solving puzzles with SQL. This solution provides a scalable template for contextual data repair tasks where values can be imputed logically from surrounding patterns.

---

## 📣 Feedback & Collaboration

Feel free to fork the repo, suggest improvements, add new rules, or use this as a base for your own data cleaning adventures. Contributions and ideas welcome!

