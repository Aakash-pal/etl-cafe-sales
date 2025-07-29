import pandas as pd
import psycopg2
import os


# Define your PostgreSQL credentials
DB_CONFIG = {
    "host" :  "localhost",
    "port" :  "5432",
    "dbname" :  "cafe_sales",
    "user" :  "postgres",
    "password" :  "mysecretpassword"  # Update if your password is different
}
# Path to your SQL scripts
SQL_DIR = os.path.join("cafe-sales-etl", "sql_etl")
RAW_DATA_PATH = os.path.join("cafe-sales-etl", "raw data", "dirty_cafe_sales.csv")

def connect_db():
    return psycopg2.connect(**DB_CONFIG)

def load_csv_to_db(conn):
    df = pd.read_csv(RAW_DATA_PATH)

    # Replace invalid strings with NULLs for PostgreSQL compatibility
    df = df.where(pd.notnull(df), None)

    # Insert data row-by-row using psycopg2
    with conn.cursor() as cur:
        for row in df.itertuples(index=False):
            cur.execute("""
                INSERT INTO raw_cafe_sales (
                    transaction_id, transaction_date, location, payment_method,
                    item, quantity, price_per_unit, total_spent
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, tuple(row))
    conn.commit()
    print("✅ Loaded raw data into raw_cafe_sales table")

def run_sql_files(conn):
    for sql_file in ["02_create_staging_table.sql", "03_validation_queries.sql"]:
        path = os.path.join(SQL_DIR, sql_file)
        print(f"🔹 Running {sql_file}...")
        with open(path, "r") as file:
            sql = file.read()
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()
        print(f"✅ Done.")

if __name__ == "__main__":
    try:
        conn = connect_db()
        print("📥 Loading raw CSV data...")
        load_csv_to_db(conn)
        run_sql_files(conn)
        print("\n🎉 ETL SQL pipeline completed successfully!")
    except Exception as e:
        print("❌ Error:", e)
    finally:
        if conn:
            conn.close()