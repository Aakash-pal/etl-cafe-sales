###📊 Power BI Dashboard – Cafe Sales Insights
This dashboard visualizes core business insights from the cleaned and enriched final_cafe_sales dataset produced in Week 3 of the ETL project. It supports decision-making around product performance, customer behavior, and store operations.

###🗂️ Dashboard Structure
Visual	Description
Bar Chart – Best-Selling Items	Displays the top 5 products by total quantity sold. Helps identify customer favorites.
Line Chart – Monthly Revenue Trend	Visualizes total revenue generated per month, highlighting seasonal or growth patterns.
Stacked Column Chart – Category Sales	Shows both quantity and revenue across different product categories (e.g., Beverages, Bakery).
Stacked Bar Chart – Payment Method by Store Type	Compares payment preferences (Cash, Card, Wallet) across Urban and Suburban store types.
Card Visual – Top City by Revenue	Displays the city with the highest total revenue. Quick glance KPI for geographic analysis.

###📦 Data Source
Database: PostgreSQL

Schema/Table: final_cafe_sales

###Connection: DirectQuery or Import mode via PostgreSQL connector in Power BI Desktop

###✅ Dataset Fields Used
Column	Role in Dashboard
item	Used to determine best-sellers
transaction_date	Time dimension for revenue trend
category	Breakdown of product categories
store_type	Comparison basis for payment methods
payment_method	Used in stacking bar charts
city	Geography used for revenue by location
total_spent	Revenue metric across all visualizations
quantity	Sales volume in category and item breakdown

###🛠️ Instructions to Run
Open Power BI Desktop.

Click Get Data → PostgreSQL.

Enter your connection credentials.

Select the final_cafe_sales table.

Load the data in Import Mode or DirectQuery.

Use the provided SQL logic or visuals guide to design your report.

Save as CafeSalesDashboard.pbix and publish or export as .pdf.

###📁 Files
File	Description
CafeSalesDashboard.pbix	Power BI dashboard file
PowerBI/README.md	This documentation file