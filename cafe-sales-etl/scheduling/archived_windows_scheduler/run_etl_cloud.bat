@echo off
echo [%DATE% %TIME%] Starting ETL job... >> etl_scheduler.log
docker run --rm -v %cd%:/app palaakash/etl-cafe-sales:latest >> etl_scheduler.log 2>&1
echo [%DATE% %TIME%] ETL job completed. >> etl_scheduler.log
