# ☕ Café Sales ETL Enhancement Project

A fully hands-on, real-world simulation of an end-to-end **ETL pipeline** for cleaning and transforming café sales data using SQL, Python, Docker, and Power BI — designed to demonstrate data engineering best practices and automation.

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
.
├── etl_cafe_sales.py                  # Python ETL script
├── Dockerfile                         # Docker setup
├── requirements.txt                   # Python dependencies
├── run_etl.bat                        # Local ETL runner
├── run_etl_cloud.bat                  # ETL runner for cloud setup
├── dirty_cafe_sales.csv               # Raw transactional data
├── product_info.csv                   # Enriched product info
├── store_info.csv                     # Enriched store info
├── SQL_Enhancement/
│   └── PowerBI Dashboard/
│   │ 	├── CafeSalesDashboard.pbix       # Final Power BI dashboard
│   │   ├── ETL_Cafe_Sales_Dashboard.pbix # Intermediate version
│   │    └── README.md  
│   ├── 01_create_raw_table.sql
│   ├── 02_create_staging_table.sql
│   ├── 03_validation_queries.sql
│   ├── data_architecture_cafe_sales.png # Architecture diagram
│   └── README.md                        # Power BI folder documentation
└── README.md                            # (You are here)
```
---

## 🔁 ETL Flow

1. **Extract**
   - Load raw transactional data from `dirty_cafe_sales.csv`
2. **Transform**
   - Advanced data cleaning via SQL CTEs (item, price, location, payment method)
   - Quantity/price imputation using calculated logic
   - Handle `ERROR`, `UNKNOWN`, nulls with contextual repairs
3. **Load**
   - Final clean data inserted into `staging_cafe_sales` in PostgreSQL
4. **Schedule**
   - Automated batch execution via Task Scheduler
5. **Visualize**
   - Build insights in Power BI with joins to `store_info.csv` and `product_info.csv`

---

## 📈 Power BI Dashboard

- Visual KPIs: total revenue, sales trend, top-selling items
- Category & store-level breakdown
- Dashboard connected to `staging_cafe_sales` via PostgreSQL
- `.pbix` files available under `PowerBI Dashboard/`

---

## 🌐 Architecture Diagram

See `data_architecture_cafe_sales.png` for a simplified layered view of the ETL pipeline (Bronze ➝ Silver ➝ Gold).

---

## 🧪 Learning Highlights

✅ Deep dive into SQL CTEs and CASE logic  
✅ Hands-on Dockerization of Python ETL jobs  
✅ Custom transformation logic for ambiguous data  
✅ GitHub version control with multi-week enhancements  
✅ Data visualization & business insights in Power BI  

---

## 🙋‍♀️ About Me

👩‍💻 **Aakash Pal**  
🌍 Hyderabad, India  
🎯 Aspiring Cloud ETL Engineer  
🔗 GitHub: [Aakash Pal](https://github.com/Aakash-pal)

---

## 📬 Contact

If you're hiring, collaborating, or want to give feedback — feel free to reach out via LinkedIn or raise an issue in this repo.