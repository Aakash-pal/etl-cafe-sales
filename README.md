# ☕ Cafe Sales ETL Pipeline

A complete end-to-end ETL pipeline that extracts, cleans, and loads transactional cafe sales data into a PostgreSQL database — containerized with Docker and scheduled for automated execution.

---

## 🚀 Project Summary

This project was built as part of my hands-on ETL learning journey to simulate a real-world data pipeline. It processes a sample cafe sales dataset, handles dirty records, logs errors, and ensures only clean, deduplicated data is inserted into the target database.

---

## 🧰 Tech Stack

- **Python** (Pandas, psycopg2)
- **PostgreSQL**
- **Docker**
- **Windows Task Scheduler**
- **Power BI** *(optional visualization)*

---

## 📂 Folder Structure

etl-cafe-sales/
├── etl_cafe_sales.py # ETL script (extract, transform, load)
├── Dockerfile # Docker image setup
├── requirements.txt # Python dependencies
├── run_etl.bat # Batch file to automate container runs
├── dirty_cafe_sales.csv # Sample raw dataset (sanitized)
├── etl.log # Logged ETL output
└── dashboards/
└── cafe_sales_dashboard.pbix / .png


---

## ⚙️ How It Works

1. **Extract** raw cafe sales data from a CSV file
2. **Transform** the data:
   - Cleans invalid entries (e.g. "ERROR", missing values)
   - Converts and casts types safely
   - Deduplicates based on `transaction_id`
3. **Load** cleaned records into a PostgreSQL database
4. **Log** the process with timestamps, row counts, and errors
5. **Containerized** with Docker for portability
6. **Automated** via Windows Task Scheduler (daily run)

---

## 🐳 Running the Pipeline with Docker

```bash
docker build -t etl-cafe-sales .
docker run --rm -v %cd%:/app etl-cafe-sales
Ensure your PostgreSQL instance is running on host.docker.internal:5432.

📈 Power BI Dashboard (Optional)
Visualizes sales volume, revenue breakdown, top items, and monthly trends.

📝 What This Project Demonstrates
Clean, modular ETL architecture

Handling of invalid/missing data

Logging, error catching, and performance tracking

Docker-based deployment

Task scheduling and automation

Optional data visualization (Power BI)

🙋‍♀️ About Me
👩‍💻 Aakash Pal
🌍 Hyderabad, India
🎯 Aspiring Cloud ETL Engineer
🔗 GitHub - https://github.com/Aakash-pal

📬 Contact
Want to collaborate, hire, or give feedback?
Reach out to me on LinkedIn or raise an issue in this repo.