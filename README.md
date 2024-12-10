# Retail Orders Data Cleaning and SQL Data Analytics

This project involves data cleaning, transformation, and SQL-based analytics using Python (Pandas, SQLAlchemy) and SQL queries. The project uses a retail dataset to perform data wrangling, followed by performing various SQL queries to extract meaningful insights from the data. 

## Table of Contents
- [Project Overview](#project-overview)
- [Data Cleaning](#data-cleaning)
- [SQL Data Analytics](#sql-data-analytics)
- [Technologies Used](#technologies-used)
- [Setup and Installation](#setup-and-installation)
- [Usage](#usage)
- [Contributors](#contributors)

## Project Overview

In this project, we are working with a dataset of retail orders that includes various product and order information such as product IDs, prices, discount percentages, regions, categories, and sales data. We perform the following steps:

1. **Data Cleaning**: Preprocessing the raw data to standardize column names, handle missing values, and create new calculated columns (e.g., `discount_amount`, `sold_price`, `profit`).
2. **SQL Data Analytics**: Use SQL queries to analyze the cleaned data, uncover key insights, and generate reports on sales trends, revenue generation, and product performance.

## Data Cleaning

The data cleaning process involves the following steps:

1. **Download the Dataset**: Using Kaggle API to download the dataset and extract the CSV file.
2. **Read the CSV File**: Load the data into a Pandas DataFrame.
3. **Column Name Standardization**: Clean and standardize column names by converting them to lowercase and replacing spaces with underscores.
4. **Feature Engineering**:
   - Calculate the `discount_amount` as an actual value rather than a percentage.
   - Compute the `sold_price` by subtracting the `discount_amount` from the `list_price`.
   - Calculate the `profit` by subtracting `cost_price` from `sold_price`.
5. **Data Type Conversion**: Convert the `order_date` column to a proper datetime format.
6. **Drop Unnecessary Columns**: Drop columns that are no longer needed after feature engineering.

**Code Snippet** (for Data Cleaning):

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import kaggle
import zipfile

# Download and extract dataset
get_ipython().system('kaggle datasets download ankitbansal06/retail-orders -f orders.csv')
zip_ref = zipfile.ZipFile('orders.csv.zip')
zip_ref.extractall()
zip_ref.close()

# Read CSV into DataFrame and clean columns
df = pd.read_csv('orders.csv', na_values=['Not Available', 'unknown'])
df.columns = df.columns.str.lower().str.replace(' ', '_')

# Feature Engineering
df['discount_amount'] = df['list_price'] * df['discount_percent'] * 0.01
df['sold_price'] = df['list_price'] - df['discount_amount']
df['profit'] = df['sold_price'] - df['cost_price']

# Convert order_date to datetime
df['order_date'] = pd.to_datetime(df['order_date'], format="%Y-%m-%d")

# Drop unnecessary columns


df = df.drop(columns=['list_price', 'cost_price', 'discount_percent'])

# Connect to SQL database using SQLAlchemy
import sqlalchemy as sal
import pymysql
engine = sal.create_engine('mssql://Pirouette/master?driver=ODBC+DRIVER+17+FOR+SQL+SERVER')
conn = engine.connect()
```

# SQL Data Analytics

After cleaning and transforming the data, we use SQL queries to perform the following analyses:

- Top 10 Highest Revenue Generating Products: Identify products that generate the highest total sales.
- Top 5 Highest Selling Products in Each Region: Identify the top-selling products by region.
- Month-over-Month Sales Growth (2022 vs 2023): Compare sales growth month-over-month between 2022 and 2023.
- Highest Sales Month by Category: Identify which month had the highest sales for each product category.
- Subcategory with Highest Growth by Profit: Identify which subcategory had the highest profit growth from 2022 to 2023.

```SQL
-- Find top 10 highest revenue generating products
SELECT TOP 10 product_id, SUM(sold_price) AS total_sales
FROM df_orders
GROUP BY product_id
ORDER BY total_sales DESC;

-- Find top 5 highest selling products in each region
WITH cte AS (
    SELECT region, product_id, SUM(sold_price) AS total_sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT * 
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rn
    FROM cte
) AS ranked
WHERE rn <= 5;

-- Month-over-month growth comparison for '22 and '23 sales
WITH cte AS (
    SELECT 
        YEAR(order_date) AS order_year, 
        MONTH(order_date) AS order_month, 
        SUM(sold_price) AS total_sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN total_sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- Highest sales month by category
WITH cte AS (
    SELECT category, FORMAT(order_date, 'yyyy-MM') AS year_month, SUM(sold_price) AS total_sales
    FROM df_orders
    GROUP BY category, FORMAT(order_date, 'yyyy-MM')
)
SELECT category, year_month, total_sales
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY total_sales DESC) AS rn
    FROM cte
) AS ranked
WHERE rn = 1;

-- Subcategory with highest growth by profit from 2022 to 2023
WITH cte AS (
    SELECT sub_category, SUM(profit) AS total_profit, YEAR(order_date) AS order_year
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),
cte2 AS (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
        SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023
    FROM cte
    GROUP BY sub_category
)
SELECT TOP 1 *, 
       ((profit_2023 - profit_2022) * 100.0) / profit_2022 AS growth_percentage
FROM cte2
ORDER BY growth_percentage DESC;
```
# Technologies Used
- Python: For data cleaning and transformation using libraries like Pandas, Numpy, and Matplotlib.
- SQL: For querying and performing data analytics using SQL queries on a Microsoft SQL Server.
- SQLAlchemy: For establishing a connection between Python and the SQL Server database.
- Kaggle API: For downloading the dataset directly into the project directory.

# Setup and Installation
- Prerequisites
- Python 3.x
- Anaconda or virtual environment (optional)
- Necessary libraries:
  - pandas
  - numpy
  - matplotlib
  - kaggle
  - sqlalchemy
  - pymysql
 
  Feel free to reach out to me here: vishrutbezbarua@gmail.com, in cas you need any help!
