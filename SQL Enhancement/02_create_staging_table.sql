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
        
		WHEN (item is null OR item IN ('UNKNOWN', 'ERROR', ''))
			AND Price_per_unit = '2.0' 
			AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
			AND location IN ('Takeaway', 'In-Store')
		then 'Coffee' 
		
		WHEN (item is null OR item IN ('UNKNOWN', 'ERROR', ''))
			AND Price_per_unit = '1.0' 
			AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
			AND location IN ('Takeaway', 'In-Store')
		then 'Cookie'
		
		WHEN (item is null OR item IN ('UNKNOWN', 'ERROR', ''))
			AND Price_per_unit = '3.0' 
			AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
			AND location IN ('Takeaway', 'In-Store')
		then 'Juice'
		
		WHEN (item is null OR item IN ('UNKNOWN', 'ERROR', ''))
			AND Price_per_unit = '5.0' 
			AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
			AND location IN ('Takeaway', 'In-Store')
		then 'Salad'
		
		WHEN (item is null OR item IN ('UNKNOWN', 'ERROR', ''))
			AND Price_per_unit = '5.0' 
			AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
			AND location IN ('Takeaway', 'In-Store')
		then 'Sandwich'
		
		WHEN (item is null OR item IN ('UNKNOWN', 'ERROR', ''))
			AND Price_per_unit = '4.0' 
			AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
			AND location IN ('Takeaway', 'In-Store')
		then 'Smoothie'
		
		WHEN (item is null OR item IN ('UNKNOWN', 'ERROR', ''))
			AND Price_per_unit = '1.5' 
			AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
			AND location IN ('Takeaway', 'In-Store')
		then 'Tea'
		
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
	 
 	WHEN (price_per_unit is null or price_per_unit IN ('ERROR', 'UNKNOWN', ''))
       AND quantity NOT IN ('ERROR', 'UNKNOWN', '')
       AND total_spent NOT IN ('ERROR', 'UNKNOWN', '')
       AND quantity::NUMERIC != 0 --to avoid divide-by-zero erros
  	THEN (CAST(total_spent AS NUMERIC) / CAST(quantity AS NUMERIC))::INT  -- round to nearest integer
  	
  	ELSE CAST(NULLIF(NULLIF(NULLIF(quantity, 'ERROR'), 'UNKNOWN'), '') AS INTEGER)
  	
END as price_per_unit,
    total_spent,

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
	
    -- Contextual cleanup of location column
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
    ELSE NULLIF(NULLIF(NULLIF(location, 'ERROR'), 'UNKNOWN'), '')
END AS location,

  -- Contextual cleanup of transaction_date column
CASE
    WHEN transaction_date IS NULL OR transaction_date IN ('ERROR', 'UNKNOWN', '')
    THEN TO_DATE('1900-01-01', 'YYYY-MM-DD')

    ELSE TO_DATE(transaction_date, 'YYYY-MM-DD')
END AS transaction_date

FROM raw_cafe_sales;
