-- Check remaining NULLs in item
SELECT COUNT(*) AS null_items_remaining
FROM staging_cafe_sales
WHERE item IS NULL;

-- Spot possible missed "Cake" rows
SELECT *
FROM staging_cafe_sales
WHERE item IS NULL
  AND price_per_unit = '3.0'
  AND payment_method IN ('Cash', 'Credit Card', 'Digital Wallet')
  AND location IN ('In-store', 'Takeaway');
