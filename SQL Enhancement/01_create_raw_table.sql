-- Create the raw_cafe_sales table to import dirty CSV data
DROP TABLE IF EXISTS raw_cafe_sales;

CREATE TABLE raw_cafe_sales (
    transaction_id TEXT,
    item TEXT,
    quantity TEXT,
    price_per_unit TEXT,
    total_spent TEXT,
    payment_method TEXT,
    location TEXT,
    transaction_date TEXT
);
