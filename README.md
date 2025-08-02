
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
├── .gitignore → Tracks excluded files
├── requirements.txt → Python dependencies
├── logs/ → Log files from scheduled runs
├── cafe-sales-etl/ → Core pipeline logic
│ ├── airflow/ → (Upcoming) Apache Airflow DAGs
│ ├── docker/ → Dockerfile for containerized ETL
│ ├── power_bi/ → Dashboards (.pbix) and visuals
│ ├── raw data/ → Raw CSV files
│ ├── scheduling/ → Batch files for job automation
│ ├── scripts/ → Python-based orchestrators
│ └── sql_etl/ → Raw and staging SQL transformation logic
├── SQL_Enhancement/ → Deep cleaning using SQL CTEs
│ ├── README.md → In-depth explanation of logic
│ ├── data_architecture_cafe_sales.png
│ └── power_bi/                          
│# (You are here)
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

## 🙋‍♀️ About Me

👩‍💻 **Aakash Pal**  
🌍 Hyderabad, India  
🎯 Aspiring Cloud ETL Engineer  
🔗 GitHub: [Aakash Pal](https://github.com/Aakash-pal)
- This project was built to gain hands-on experience in real-world data engineering practices — focusing on raw data challenges, SQL mastery, and visual storytelling.

---

## 📬 Contact

If you're hiring, collaborating, or want to give feedback — feel free to reach out via LinkedIn or raise an issue in this repo.