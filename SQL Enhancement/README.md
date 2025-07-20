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