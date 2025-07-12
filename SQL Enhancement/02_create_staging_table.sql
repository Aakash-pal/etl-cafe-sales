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
	quantity,
    price_per_unit,
    total_spent,
    payment_method,
    location,
    transaction_date
FROM raw_cafe_sales;
