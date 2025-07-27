import psycopg2
import os

# Define your PostgreSQL credentials
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "cafe_sales"
DB_USER = "postgres"
DB_PASS = "mysecretpassword"  # Update if your password is different

# Path to SQL files
SQL_FOLDER = os.path.join(os.path.dirname(__file__), '..', 'sql_etl')
sql_files = [
    "01_create_raw_table.sql",
    "02_create_staging_table.sql",
    "03_validation_queries.sql"  # optional, 
]

def run_sql_file(cursor, file_path):
    print(f"🔹 Running {os.path.basename(file_path)}...")
    with open(file_path, 'r', encoding='utf-8') as file:
        sql = file.read()
        cursor.execute(sql)
        print("✅ Done.")

def main():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
        conn.autocommit = True
        cursor = conn.cursor()

        for sql_file in sql_files:
            full_path = os.path.join(SQL_FOLDER, sql_file)
            run_sql_file(cursor, full_path)

        cursor.close()
        conn.close()
        print("\n🎉 ETL SQL pipeline completed successfully!")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
