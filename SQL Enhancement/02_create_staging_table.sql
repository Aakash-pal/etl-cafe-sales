-- Create a staging table with contextual item repair logic

DROP TABLE IF EXISTS staging_cafe_sales;

CREATE TABLE staging_cafe_sales AS
SELECT
    transaction_id,

    -- Contextual cleanup of item column
    CASE
        WHEN (item IS NULL OR item IN ('UNKNOWN', 'ERROR', ''))
             AND price_per_unit = '3.0'
             AND location IN ('In-store', 'Takeaway')
             AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
        THEN 'Cake'
        ELSE NULLIF(NULLIF(NULLIF(item, 'ERROR'), 'UNKNOWN'), '')
    END AS item,

    quantity,
    price_per_unit,
    total_spent,
    payment_method,
    location,
    transaction_date
FROM raw_cafe_sales;
