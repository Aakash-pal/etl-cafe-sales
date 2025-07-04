# Base image
FROM python:3.10-slim

#This is to match the timezone in localhost
ENV TZ=Asia/Kolkata
RUN apt-get update && apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
	
# Set working directory inside the container
WORKDIR /app

# Copy local files to container
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Default command to run
CMD ["python", "etl_cafe_sales.py"]
