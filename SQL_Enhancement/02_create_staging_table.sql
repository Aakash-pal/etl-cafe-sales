DROP TABLE IF EXISTS staging_cafe_sales;

CREATE TABLE staging_cafe_sales AS
WITH raw_cleaned AS (
    SELECT
        transaction_id,
        transaction_date,
        location,
        payment_method,
        item,
        quantity,
        price_per_unit,
        total_spent,

        -- Clean quantity
        CASE
            WHEN quantity IN ('ERROR', 'UNKNOWN', '')
                 AND price_per_unit NOT IN ('ERROR', 'UNKNOWN', '')
                 AND total_spent NOT IN ('ERROR', 'UNKNOWN', '')
                 AND price_per_unit::NUMERIC != 0
            THEN (CAST(total_spent AS NUMERIC) / CAST(price_per_unit AS NUMERIC))::INT
            ELSE CAST(NULLIF(NULLIF(NULLIF(quantity, 'ERROR'), 'UNKNOWN'), '') AS INTEGER)
        END AS cleaned_quantity,

        -- Clean price_per_unit
        CASE
            WHEN (price_per_unit IS NULL OR price_per_unit IN ('ERROR', 'UNKNOWN', ''))
                 AND quantity ~ '^[0-9]+$'
                 AND total_spent ~ '^[0-9\.]+$'
            THEN ROUND(CAST(total_spent AS NUMERIC) / CAST(quantity AS NUMERIC), 2)
            WHEN price_per_unit NOT IN ('ERROR', 'UNKNOWN', '')
            THEN CAST(price_per_unit AS NUMERIC)
            ELSE NULL
        END AS cleaned_price,

        -- Clean total_spent
        CASE
            WHEN (total_spent IS NULL OR total_spent IN ('', 'UNKNOWN', 'ERROR'))
                 AND quantity ~ '^\d+(\.\d+)?$'
                 AND price_per_unit ~ '^\d+(\.\d+)?$'
            THEN ROUND(CAST(quantity AS NUMERIC) * CAST(price_per_unit AS NUMERIC), 2)
            WHEN total_spent ~ '^\d+(\.\d+)?$'
            THEN CAST(total_spent AS NUMERIC)
            ELSE NULL
        END AS cleaned_spent
    FROM raw_cafe_sales
),

item_repaired AS (
    SELECT *,
        CASE
            WHEN (item IS NULL OR item IN ('', 'UNKNOWN', 'ERROR')) THEN
                CASE
                    WHEN cleaned_price = 3.0 AND location = 'In-store' THEN 'Cake'
                    WHEN cleaned_price = 3.0 AND location = 'Takeaway' THEN 'Juice'
                    WHEN cleaned_price = 5.0 AND location = 'In-store' THEN 'Salad'
                    WHEN cleaned_price = 5.0 AND location = 'Takeaway' THEN 'Sandwich'
                    WHEN cleaned_price = 1.0 THEN 'Cookie'
                    WHEN cleaned_price = 1.5 THEN 'Tea'
                    WHEN cleaned_price = 2.0 THEN 'Coffee'
                    WHEN cleaned_price = 4.0 THEN 'Smoothie'
                    ELSE
                        CASE
                            WHEN cleaned_price = 3.0 THEN 'Juice'
                            WHEN cleaned_price = 5.0 THEN 'Sandwich'
                            ELSE NULL
                        END
                END
            ELSE NULLIF(NULLIF(NULLIF(item, 'ERROR'), 'UNKNOWN'), '')
        END AS repaired_item
    FROM raw_cleaned
),

location_resolved AS (
    SELECT *,
        CASE
            WHEN location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR') THEN
                CASE
                    WHEN repaired_item IN ('Cake', 'Juice', 'Salad', 'Smoothie') THEN 'In-store'
                    WHEN repaired_item IN ('Tea', 'Cookie', 'Coffee', 'Sandwich') THEN 'Takeaway'
                    WHEN cleaned_price IN (1.0, 1.5, 2.0) THEN 'Takeaway'
                    WHEN cleaned_price IN (3.0, 4.0, 5.0) THEN 'In-store'
                    ELSE NULL
                END
            ELSE NULLIF(NULLIF(NULLIF(location, 'ERROR'), 'UNKNOWN'), '')
        END AS resolved_location
    FROM item_repaired
),

payment_method_resolved AS (
    SELECT *,
        CASE
            WHEN (payment_method IS NULL OR payment_method IN ('', 'UNKNOWN', 'ERROR')) THEN
                CASE
                    WHEN repaired_item = 'Tea' THEN 
                        CASE 
                            WHEN resolved_location = 'In-store' THEN 'Digital Wallet'
                            ELSE 'Cash'
                        END
                    WHEN repaired_item = 'Coffee' THEN 'Digital Wallet'
                    WHEN repaired_item = 'Cake' THEN 'Cash'
                    WHEN repaired_item = 'Cookie' THEN 'Cash'
                    WHEN repaired_item IN ('Juice', 'Smoothie') THEN 'Credit Card'
                    WHEN repaired_item IN ('Salad', 'Sandwich') THEN 
                        CASE 
                            WHEN resolved_location = 'Takeaway' THEN 'Cash'
                            ELSE 'Credit Card'
                        END
                    WHEN cleaned_price <= 2.0 THEN 'Cash'
                    WHEN cleaned_price BETWEEN 2.01 AND 4.0 THEN 'Digital Wallet'
                    WHEN cleaned_price > 4.0 THEN 'Credit Card'
                    ELSE NULL
                END
            ELSE NULLIF(NULLIF(NULLIF(payment_method, 'UNKNOWN'), 'ERROR'), '')
        END AS resolved_payment
    FROM location_resolved
)

SELECT
    transaction_id,
    repaired_item AS item,
    cleaned_quantity AS quantity,
    cleaned_price AS price_per_unit,
    cleaned_spent AS total_spent,
    resolved_payment AS payment_method,
    resolved_location AS location,
    CASE
        WHEN transaction_date IS NULL OR transaction_date IN ('ERROR', 'UNKNOWN', '')
        THEN TO_DATE('1900-01-01', 'YYYY-MM-DD')
        ELSE TO_DATE(transaction_date, 'YYYY-MM-DD')
    END AS transaction_date
FROM payment_method_resolved;
