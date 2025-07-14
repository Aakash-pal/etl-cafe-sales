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
    
 CASE
	 
 	WHEN quantity IN ('ERROR', 'UNKNOWN', '')
       AND price_per_unit NOT IN ('ERROR', 'UNKNOWN', '')
       AND total_spent NOT IN ('ERROR', 'UNKNOWN', '')
       AND price_per_unit::NUMERIC != 0 --to avoid divide-by-zero erros
  	THEN (CAST(total_spent AS NUMERIC) / CAST(price_per_unit AS NUMERIC))::INT  -- round to nearest integer
  	
  	ELSE CAST(NULLIF(NULLIF(NULLIF(quantity, 'ERROR'), 'UNKNOWN'), '') AS INTEGER)
  	
END AS quantity,

CASE
	 
 	WHEN (price_per_unit is null or price_per_unit IN ('ERROR', 'UNKNOWN', ''))
       AND quantity NOT IN ('ERROR', 'UNKNOWN', '')
       AND total_spent NOT IN ('ERROR', 'UNKNOWN', '')
       AND quantity::NUMERIC != 0 --to avoid divide-by-zero erros
  	THEN (CAST(total_spent AS NUMERIC) / CAST(quantity AS NUMERIC))::INT  -- round to nearest integer
  	
  	ELSE CAST(NULLIF(NULLIF(NULLIF(quantity, 'ERROR'), 'UNKNOWN'), '') AS INTEGER)
  	
END as price_per_unit,
    total_spent,
    payment_method,
    location,
    transaction_date
FROM raw_cafe_sales;
