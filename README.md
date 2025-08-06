
# ☕ Café Sales ETL Project

A complete end-to-end data engineering project showcasing raw data ingestion, SQL-based data repair, Python orchestration, job scheduling, and Power BI visualization — all within a modular, production-ready structure.

---

## 📌 Project Summary

This project is part of my guided learning journey to become a Cloud ETL Engineer. It demonstrates how to:

- Design modular ETL pipelines
- Perform data cleaning using SQL and Python
- Use PostgreSQL as the data warehouse backend
- Automate and containerize ETL tasks
- Build business-ready dashboards in Power BI

---

## 🧱 Tech Stack

| Tool | Purpose |
|------|---------|
| **Python (pandas, psycopg2)** | ETL script logic |
| **PostgreSQL** | Database for staging and cleaned tables |
| **SQL (CTEs & CASE logic)** | Advanced data transformations |
| **Docker** | Containerize and deploy ETL job |
| **Windows Task Scheduler** | Automation and scheduling |
| **Power BI** | Data visualization |

---

## 🗂️ Project Structure

```plaintext
ETL_PROJECT/
│
├── .gitignore                        # Tracks excluded files
├── requirements.txt                 # Python dependencies
├── etl.log                          # ETL run logs
├── etl_scheduler.log                # Logs for scheduled runs
├── FolderStructure.txt             # Describes project layout
├── README.md                        # Project overview and progress
│
├── cafe-sales-etl/                  # Core ETL pipeline logic
│   ├── airflow/                     # Apache Airflow DAGs & config
│   │   ├── dags/                    # Folder to hold DAG scripts (To be added)
│   │   ├── logs/                    # Auto-generated Airflow logs
│   │   ├── plugins/                 # Custom operators/plugins (optional)
│   │   ├── docker-compose.yml       # Compose config for Airflow services
│   │   └── .env                     # Environment variables (e.g., AIRFLOW_UID)
│   │
│   ├── docker/                      # Dockerfile for containerized ETL
│   │   └── Dockerfile
│   │
│   ├── power_bi/                    # Power BI dashboards & visuals
│   │   ├── CafeSalesDashboard.pbix
│   │   ├── ETL_Cafe_Sales_Dashboard.pbix
│   │   └── README.md
│   │
│   ├── raw data/                    # Raw input data files
│   │   ├── dirty_cafe_sales.csv
│   │   ├── product_info.csv
│   │   └── store_info.csv
│   │
│   ├── scheduling/                  # Batch files for automation
│   │   ├── run_etl.bat
│   │   └── run_etl_cloud.bat
│   │
│   ├── scripts/                     # Python orchestrators
│   │   └── run_sql_etl.py
│   │
│   └── sql_etl/                     # SQL ETL logic: raw → staging
│       ├── 01_create_raw_table.sql
│       ├── 02_create_staging_table.sql
│       └── 03_validation_queries.sql
│
└── SQL_Enhancement/                 # Deep SQL-based data cleaning
    ├── README.md                    # In-depth documentation
    ├── data_architecture_cafe_sales.png
    └── PowerBI Dashboard/          # Cleaned dashboard (optional folder)
```

---

## 🧪 ETL Approaches

### 1. 🐍 Python-Only Pipeline
- Implemented in `scripts/run_python_etl.py`
- Extracts → Transforms → Loads via pandas + psycopg2
- Ideal for light-to-moderate data workloads

### 2. 🧠 SQL-Based Modular ETL 
- Powerful contextual data repair using CTEs
- Multi-layered logic: quantity, price, item, location, and payment inference
- Final table: `staging_cafe_sales`
- Explained in `SQL_Enhancement/README.md`

---

### 🧪 ETL Pipeline Flow

```flowchart TD
    A[dirty_cafe_sales.csv] --> B[Python: run_sql_etl.py]
    B --> C[raw_cafe_sales (raw table)]
    C --> D[staging_cafe_sales (cleaned via SQL CTEs)]
    D --> E[Data available for Power BI / Reporting]
```

---

### 🚀 Run the ETL

Install dependencies:
```bash
pip install -r requirements.txt
```

Run the SQL-based ETL pipeline:
```bash
python cafe-sales-etl/scripts/run_sql_etl.py
```

---

## 📊 Business Insights

Power BI dashboards provide:
- Top-selling items
- Revenue trend over time
- Category-wise sales
- Payment preference by store type
- Best-performing cities

See: [`cafe-sales-etl/power_bi/`](cafe-sales-etl/power_bi/)

---

## ⏰ Automation & Scheduling

- Local execution: `run_etl.bat`
- Cloud-compatible version: `run_etl_cloud.bat`
- Output is logged in `logs/`

---

## 🔄 Next Steps

- ✅ Integrate Python scripts to execute SQL logic
- 🚀 Orchestrate full flow using Apache Airflow
- 🧼 Continue documenting testing, validation, and enhancements
- 🔍Investigate the discrepancy in null counts between SQL-only vs Python+SQL flow

---

## 🧩 Python + SQL Hybrid ETL Integration (Week 4)

- To modularize and automate our SQL-based transformation logic, we've introduced a Python script that orchestrates the SQL ETL pipeline:
---

## 🛠️ New Components Introduced

- scripts/run_sql_etl.py: Python driver that:Loads raw CSV (dirty_cafe_sales.csv) into PostgreSQL (raw_cafe_sales)
- Executes the modular SQL logic (sql_etl/*.sql) to clean and transform the data
- Logs progress and errors to the console

---

## ✅ Latest Validation Results

- Raw data was successfully loaded into raw_cafe_sales using Python.
- SQL scripts executed cleanly via Python.
- Sanity checks confirmed valid data in staging_cafe_sales, though:
- 163 rows remain with nulls post-Python execution (to be reviewed).
- SQL-only pipeline previously had fewer nulls, suggesting slight divergence in the Python-driven flow.

---

### 🌀 Airflow Integration – SQL ETL Orchestration
- This project includes a fully functional Apache Airflow setup for orchestrating the SQL-based ETL pipeline.

### ✅ Features
- Triggers run_sql_etl.py which:
- Loads raw CSV into PostgreSQL
- Executes all SQL-based cleaning logic using modular scripts
- Uses BashOperator in Airflow DAG

### 🚀 How to Use
- Start Airflow environment

```plaintext
cd cafe-sales-etl/airflow
docker-compose up --build
```
- Access Airflow Web UI
- Visit: http://localhost:8081
- Create User and enter the Login credentials (default):
- Trigger DAG
- Go to the sql_etl_pipeline DAG
- Turn it on
- Click ▶ to trigger the job

---

### 🌀 Airflow Integration: SQL-Based ETL Pipeline
- This section introduces Apache Airflow to orchestrate the SQL-based ETL workflow for the Café Sales dataset.

## ✅ Features Implemented
- Apache Airflow setup using Docker Compose
- Airflow DAG that triggers a Python script to:
- Load raw data into the raw_cafe_sales table
- Run advanced SQL-based transformations to create staging_cafe_sales
- Execute validation queries to log data quality
- Custom PostgreSQL Connection: Named etl_postgres, defined via Airflow UI
- Correct Docker volume mounts for seamless access to:
- Raw data (raw_data/)
- SQL scripts (sql_etl/)
- Python script (scripts/run_sql_etl.py)

##🧪 Transformation Validation
- To verify the transformation logic:
- A test transaction (TXN_9999999) was added to dirty_cafe_sales.csv with partial data.
- After triggering the DAG:
- The ETL pipeline inferred missing values using SQL logic.
- Transformed output confirmed expected results.

### 🐳 Docker Setup Overview

# docker-compose.yml (excerpt)

services:
  webserver:
    ports:
      - "8081:8080"
    volumes:
      - ../scripts:/opt/airflow/sql_etl/scripts
      - ../sql_etl:/opt/airflow/sql_etl/sql_etl
      - ../raw data:/opt/airflow/sql_etl/raw_data

---
## 🙋‍♀️ About Me

👩‍💻 **Aakash Pal**  
🌍 Hyderabad, India  
🎯 Aspiring Cloud ETL Engineer  
🔗 GitHub: [Aakash Pal](https://github.com/Aakash-pal)
- This project was built to gain hands-on experience in real-world data engineering practices — focusing on raw data challenges, SQL mastery, and visual storytelling.

---

## 📬 Contact

If you're hiring, collaborating, or want to give feedback — feel free to reach out via LinkedIn or raise an issue in this repo.