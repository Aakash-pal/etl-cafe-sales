import pandas as pd
import psycopg2
import logging

# ✅ Setup logging to file
logging.basicConfig(
    filename='etl.log',
    filemode='a',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# ✅ Step 1: Extract data from CSV
def extract_data(file_path):
    try:
        df = pd.read_csv(file_path)
        logging.info("Data extraction successful.")
        return df
    except Exception as e:
        logging.error(f"Error during data extraction: {e}")
        return None

# ✅ Step 2: Transform data (cleaning)
def transform_data(df):
    try:
        # Clean numeric columns
        df['Quantity'] = pd.to_numeric(df['Quantity'], errors='coerce')
        df['Price Per Unit'] = pd.to_numeric(df['Price Per Unit'], errors='coerce')
        df['Total Spent'] = pd.to_numeric(df['Total Spent'], errors='coerce')

        # Convert dates and handle errors
        df['Transaction Date'] = pd.to_datetime(df['Transaction Date'], errors='coerce')

        # Replace "UNKNOWN" with None
        df['Payment Method'] = df['Payment Method'].replace("UNKNOWN", None)
        df['Location'] = df['Location'].replace("UNKNOWN", None)

        # Drop rows missing required fields
        df = df.dropna(subset=['Quantity', 'Price Per Unit', 'Total Spent', 'Transaction Date']).copy()

        # Convert data types
        df['Quantity'] = df['Quantity'].astype(int)
        df['Price Per Unit'] = df['Price Per Unit'].astype(float)
        df['Total Spent'] = df['Total Spent'].astype(float)

        logging.info(f"Data transformation successful. {len(df)} rows remain after cleaning.")
        return df

    except Exception as e:
        logging.error(f"Error during data transformation: {e}")
        return pd.DataFrame()

# ✅ Step 3: Load data into PostgreSQL
def load_data(df):
    try:
        conn = psycopg2.connect(
            dbname="postgres",              # ← update if you're using a different DB
            user="postgres",
            password="mysecretpassword",
            host="host.docker.internal",
            port="5432"
        )
        cur = conn.cursor()

        # Debug logs
        logging.info(f"Loading DataFrame shape: {df.shape}")
        logging.info(f"Column names: {df.columns.tolist()}")
        logging.info(f"First 5 rows:\n{df.head().to_dict(orient='records')}")

        inserted_count = 0

        for _, row in df.iterrows():
            transaction_date = row['Transaction Date']
            if pd.isna(transaction_date):
                transaction_date = None

            try:
                cur.execute("""
                    INSERT INTO public.cafe_sales (
                        transaction_id, item, quantity, price_per_unit,
                        total_spent, payment_method, location, transaction_date
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (transaction_id) DO NOTHING;
                """, (
                    row['Transaction ID'], row['Item'], row['Quantity'],
                    row['Price Per Unit'], row['Total Spent'],
                    row['Payment Method'], row['Location'], transaction_date
                ))
                inserted_count += 1
            except Exception as insert_err:
                logging.error(f"Insert failed for transaction_id {row['Transaction ID']}: {insert_err}")

        conn.commit()
        cur.close()
        conn.close()

        logging.info(f"Data load successful. {inserted_count} rows inserted.")
        print(f"✅ {inserted_count} rows inserted into cafe_sales.")

    except Exception as e:
        logging.error(f"Error during data load: {e}")
        print("❌ Error during data load. Check log for details.")

# ✅ Main function to run the ETL job
def main():
    logging.info("ETL job started.")
    print("🚀 ETL process started...")

    file_path = "dirty_cafe_sales.csv"  # Update with full path if needed
    df = extract_data(file_path)

    if df is not None and not df.empty:
        cleaned_df = transform_data(df)
        if not cleaned_df.empty:
            load_data(cleaned_df)
        else:
            logging.warning("Transformed data is empty. Skipping load.")
            print("⚠️ No valid rows to insert after transformation.")
    else:
        logging.warning("Extracted data is empty. Exiting.")
        print("⚠️ No data extracted from CSV.")

    logging.info("ETL job completed.")
    print("✅ ETL process completed successfully!")

# ✅ Entry point
if __name__ == "__main__":
    main()
