select * from df_orders;

-- find top 10 highest revenue generating products

select top 5 product_id, sum(sold_price) as sales
from df_orders 
group by product_id
order by sales desc

-- find top 5 highest selling products in each region
with cte as (
select region, product_id, sum(sold_price) as sales 
from df_orders
group by region, product_id)
select * from (
select * 
, row_number() over (partition by region order by sales desc) as rn
from cte) A
where rn <= 5


-- Find month over month growth comparison for '22 and '23 sales : jan 22 vs jan 23

with cte as (
select year(order_date) as order_year, 
month(order_date) as order_month,
sum(sold_price) as sales
from df_orders
group by year(order_date), month(order_date)
)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month


-- for each cateogry which month had highest sales

WITH cte AS (
    SELECT category, 
           format(order_date, 'yyyy_MM') AS year_month, 
           SUM(sold_price) AS sales
    FROM df_orders
    GROUP BY category, format(order_date, 'yyyy_MM')
)

SELECT * FROM (SELECT category, 
       year_month, 
       sales, 
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
FROM cte) A
WHERE rn = 1

-- which subcategory had highest growth by profit from 2022 to 2023


WITH cte AS (
    SELECT sub_category, 
           SUM(sold_price) AS sales, 
           YEAR(order_date) AS order_year 
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
),

cte2 AS (
    SELECT sub_category, 
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_22,
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_23
    FROM cte
    GROUP BY sub_category
)

SELECT TOP 1 *, 
       ((sales_23 - sales_22) * 100) / sales_22 AS growth_percentage
FROM cte2
ORDER BY growth_percentage DESC;
