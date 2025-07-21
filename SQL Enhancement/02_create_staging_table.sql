-- Create a staging table with contextual item repair logic

DROP TABLE IF EXISTS staging_cafe_sales;

CREATE TABLE staging_cafe_sales as

SELECT
    transaction_id,
    -- Contextual cleanup of item column
CASE
  -- Handle special cases first (patches)
  WHEN (item IS NULL OR item IN ('', 'UNKNOWN', 'ERROR'))
       AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 2.0
       AND payment_method = 'Credit Card' AND location = 'Takeaway'
  THEN 'Coffee'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 3.0
       AND payment_method = 'Credit Card' AND location = 'In-store'
  THEN 'Cake'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 3.0
       AND payment_method = 'Credit Card' AND location = 'Takeaway'
  THEN 'Juice'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.5
       AND payment_method = 'Credit Card' AND location = 'In-store'
  THEN 'Tea'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.5
       AND payment_method = 'Digital Wallet' AND location = 'Takeaway'
  THEN 'Tea'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.5
       AND payment_method = 'Cash' AND location = 'Takeaway'
  THEN 'Tea'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 3.0
       AND payment_method = 'Cash' AND location = 'In-store'
  THEN 'Cake'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 4.0
       AND payment_method = 'Credit Card' AND location = 'Takeaway'
  THEN 'Smoothie'

  WHEN price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 4.0
       AND payment_method = 'Cash' AND location = 'In-store'
  THEN 'Smoothie'

  -- Duality logic: Juice vs Cake
  WHEN (item IS NULL OR item IN ('', 'UNKNOWN', 'ERROR'))
       AND price_per_unit ~ '^\d+(\.\d+)?$' THEN
    CASE
      WHEN CAST(price_per_unit AS NUMERIC) = 3.0 AND location = 'Takeaway' THEN 'Juice'
      WHEN CAST(price_per_unit AS NUMERIC) = 3.0 AND location = 'In-store' THEN 'Cake'
      WHEN CAST(price_per_unit AS NUMERIC) = 5.0 AND location = 'Takeaway' THEN 'Sandwich'
      WHEN CAST(price_per_unit AS NUMERIC) = 5.0 AND location = 'In-store' THEN 'Salad'
      WHEN CAST(price_per_unit AS NUMERIC) = 1.0 THEN 'Cookie'
      WHEN CAST(price_per_unit AS NUMERIC) = 1.5 THEN 'Tea'
      WHEN CAST(price_per_unit AS NUMERIC) = 2.0 THEN 'Coffee'
      WHEN CAST(price_per_unit AS NUMERIC) = 4.0 THEN 'Smoothie'
      ELSE NULL
    END

  -- Clean value passthrough
  ELSE NULLIF(NULLIF(NULLIF(item, 'ERROR'), 'UNKNOWN'), '')
END AS item,

    -- Contextual cleanup of quantity column    
 CASE
	 
 	WHEN quantity IN ('ERROR', 'UNKNOWN', '')
       AND price_per_unit NOT IN ('ERROR', 'UNKNOWN', '')
       AND total_spent NOT IN ('ERROR', 'UNKNOWN', '')
      AND price_per_unit::NUMERIC != 0 --to avoid divide-by-zero erros
  	THEN (CAST(total_spent AS NUMERIC) / CAST(price_per_unit AS NUMERIC))::INT  -- round to nearest integer
  	
  	ELSE CAST(NULLIF(NULLIF(NULLIF(quantity, 'ERROR'), 'UNKNOWN'), '') AS INTEGER)
  	
END AS quantity,

    -- Contextual cleanup of price_per_unit column
CASE 
	
  WHEN (price_per_unit IS NULL OR price_per_unit IN ('ERROR', 'UNKNOWN', ''))
       AND quantity IS NOT NULL AND total_spent IS NOT NULL
       AND NULLIF(quantity, '') ~ '^[0-9]+$'
       AND NULLIF(total_spent, '') ~ '^[0-9\.]+$'
  THEN ROUND(CAST(total_spent AS NUMERIC) / CAST(quantity AS NUMERIC), 2)

  WHEN price_per_unit NOT IN ('ERROR', 'UNKNOWN', '')
  THEN CAST(price_per_unit AS NUMERIC)

  ELSE null
  
END AS price_per_unit,

    -- Contextual cleanup of total_spent column  
CASE
    WHEN (total_spent IS NULL OR total_spent IN ('', 'UNKNOWN', 'ERROR'))
         AND quantity ~ '^\d+(\.\d+)?$'
         AND price_per_unit ~ '^\d+(\.\d+)?$'
    THEN ROUND(CAST(quantity AS NUMERIC) * CAST(price_per_unit AS NUMERIC), 2)

    WHEN total_spent ~ '^\d+(\.\d+)?$'
    THEN CAST(total_spent AS NUMERIC)

    ELSE NULL
END AS total_spent,


    -- Contextual cleanup of payment_method column    
CASE
    WHEN (payment_method IS NULL OR payment_method IN ('', 'UNKNOWN', 'ERROR'))
         AND item IN ('Cake', 'Coffee', 'Salad','Smoothie') AND location = 'In-store'
    THEN 'Cash'

    WHEN (payment_method IS NULL OR payment_method IN ('', 'UNKNOWN', 'ERROR'))
         AND item IN ('Cookie', 'Juice','Sandwich') AND location = 'In-store'
    THEN 'Credit Card'

    WHEN (payment_method IS NULL OR payment_method IN ('', 'UNKNOWN', 'ERROR'))
         AND item IN ('Tea') AND location = 'In-store'
    THEN 'Digital Wallet'
	
	WHEN (payment_method IS NULL OR payment_method IN ('', 'UNKNOWN', 'ERROR'))
         AND item IN ('Coffee', 'Salad', 'Cookie', 'Juice') AND location = 'Takeaway'
    THEN 'Digital Wallet'
	
	WHEN (payment_method IS NULL OR payment_method IN ('', 'UNKNOWN', 'ERROR'))
         AND item IN ('Cake', 'Smoothie') AND location = 'Takeaway'
    THEN 'Credit Card'
	
	WHEN (payment_method IS NULL OR payment_method IN ('', 'UNKNOWN', 'ERROR'))
         AND item IN ('Sandwich', 'Tea') AND location = 'Takeaway'
    THEN 'Cash'

    ELSE NULLIF(NULLIF(NULLIF(payment_method, 'UNKNOWN'), 'ERROR'), '')
END AS payment_method,
	
    -- Contextual cleanup of Location column
CASE
  -- Primary rule-based logic using item and payment_method
  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Cake', 'Juice', 'Salad', 'Smoothie') 
       AND payment_method = 'Cash'
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Coffee', 'Cookie', 'Sandwich', 'Tea') 
       AND payment_method = 'Cash'
  THEN 'Takeaway'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Cookie', 'Juice', 'Salad', 'Sandwich') 
       AND payment_method = 'Credit Card'
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Coffee', 'Cake', 'Smoothie', 'Tea') 
       AND payment_method = 'Credit Card'
  THEN 'Takeaway'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Cake', 'Juice', 'Sandwich') 
       AND payment_method = 'Digital Wallet'
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item IN ('Coffee', 'Cookie', 'Salad', 'Tea', 'Smoothie') 
       AND payment_method = 'Digital Wallet'
  THEN 'Takeaway'

  -- 🔒 Regex-safe inference using item + price_per_unit
  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Tea' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.5
  THEN 'Takeaway'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Cookie' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 1.0
  THEN 'Takeaway'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Cake' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 3.0
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Coffee' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 2.0
  THEN 'Takeaway'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Juice' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 3.0
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Smoothie' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 4.0
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Salad' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 5.0
  THEN 'In-store'

  WHEN (location IS NULL OR location IN ('', 'UNKNOWN', 'ERROR'))
       AND item = 'Sandwich' AND price_per_unit ~ '^\d+(\.\d+)?$' AND CAST(price_per_unit AS NUMERIC) = 4.0
  THEN 'Takeaway'

  ELSE NULLIF(NULLIF(NULLIF(location, 'ERROR'), 'UNKNOWN'), '')
END AS location,


  -- Contextual cleanup of transaction_date column
CASE
    WHEN transaction_date IS NULL OR transaction_date IN ('ERROR', 'UNKNOWN', '')
    THEN TO_DATE('1900-01-01', 'YYYY-MM-DD')

    ELSE TO_DATE(transaction_date, 'YYYY-MM-DD')
END AS transaction_date

FROM raw_cafe_sales;
