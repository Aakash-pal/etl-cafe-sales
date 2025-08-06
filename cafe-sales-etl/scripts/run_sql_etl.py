import psycopg2
from psycopg2 import sql
import os

# Set up database connection parameters
DB_NAME = "cafe_sales"
DB_USER = "postgres"
DB_PASSWORD = "mysecretpassword" 
DB_HOST = "localhost"
DB_PORT = "5432"

# File paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_CSV_PATH = "/opt/airflow/sql_etl/raw_data/dirty_cafe_sales.csv"
SQL_DIR = os.path.join(BASE_DIR, "sql_etl")

# Helper function to run a SQL file
def run_sql_file(cursor, filepath):
    with open(filepath, 'r', encoding='utf-8') as file:
        sql_script = file.read()
        cursor.execute(sql_script)

def main():
    try:
        print("📥 Loading raw CSV data...")

        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        conn.autocommit = True
        cur = conn.cursor()
        # Step 1: Drop and recreate raw_cafe_sales table
        run_sql_file(cur, os.path.join(SQL_DIR, "01_create_raw_table.sql"))
        # Step 2: Load data using correct column mapping
        with open(RAW_CSV_PATH, 'r', encoding='utf-8') as f:
            copy_sql = """
            COPY raw_cafe_sales (
                transaction_id,
                item,
                quantity,
                price_per_unit,
                total_spent,
                payment_method,
                location,
                transaction_date
            )
            FROM STDIN WITH CSV HEADER DELIMITER ',' NULL '' ENCODING 'UTF8';
            """
            cur.copy_expert(copy_sql, f)
        print("✅ Loaded raw data into raw_cafe_sales table")

        # Step 3: Run transformation and validation queries
        sql_files = [
            "02_create_staging_table.sql",
            "03_validation_queries.sql"
        ]
        for sql_file in sql_files:
            print(f"🔹 Running {sql_file}...")
            run_sql_file(cur, os.path.join(SQL_DIR, sql_file))
            print("✅ Done.")
        cur.close()
        conn.close()
        print("\n🎉 ETL SQL pipeline completed successfully!")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
