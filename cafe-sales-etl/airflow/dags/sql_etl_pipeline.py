from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime
import os

# Define paths
BASE_DIR = "/opt/airflow/sql_etl"
SQL_DIR = os.path.join(BASE_DIR, "sql_etl")
SCRIPT_DIR = os.path.join(BASE_DIR, "scripts")
RAW_CSV_PATH = os.path.join(BASE_DIR, "raw_data", "dirty_cafe_sales.csv")

# Helper function to run SQL files
def run_sql_file(cur, file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        sql = f.read()
        cur.execute(sql)

# Main task
def run_sql_etl():
    hook = PostgresHook(postgres_conn_id="etl_postgres")  # Must match what's in Airflow UI
    conn = hook.get_conn()
    cur = conn.cursor()

    print("📥 Loading raw CSV data...")

    # Step 1: Drop and recreate raw table
    run_sql_file(cur, os.path.join(SQL_DIR, "01_create_raw_table.sql"))

    # Step 2: Load raw CSV into raw_cafe_sales
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

    # Step 3: Create staging table
    print("🔹 Running 02_create_staging_table.sql...")
    run_sql_file(cur, os.path.join(SQL_DIR, "02_create_staging_table.sql"))
    print("✅ Done.")

    # Step 4: Run validation queries
    print("🔹 Running 03_validation_queries.sql...")
    run_sql_file(cur, os.path.join(SQL_DIR, "03_validation_queries.sql"))
    print("✅ Done.")

    conn.commit()
    cur.close()
    conn.close()
    print("\n🎉 ETL SQL pipeline completed successfully!")

# Define DAG
with DAG(
    dag_id="sql_etl_pipeline",
    start_date=datetime(2025, 8, 6),
    schedule_interval=None,
    catchup=False,
    tags=["sql_etl"],
    description="DAG to run SQL ETL scripts via Python",
) as dag:

    run_etl_task = PythonOperator(
        task_id="run_sql_etl_script",
        python_callable=run_sql_etl
    )
