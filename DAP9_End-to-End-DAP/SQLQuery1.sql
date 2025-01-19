SELECT * FROM retail_orders;

-- FINDING THE TOP 10 HIGHEST REVENUE GENERATING PRODUCTS
SELECT TOP 10 product_id, SUM(sale_price) AS sales
FROM retail_orders
GROUP BY product_id
ORDER BY sales DESC;

-- FIND TOP 5 HIGHEST SELLING PRODUCTS IN EACH REGION
WITH CTE AS (
SELECT region, product_id, SUM(sale_price) AS sales
FROM retail_orders
GROUP BY region, product_id)
SELECT * FROM (
SELECT *
, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales desc) AS rn
FROM CTE) A
WHERE rn<=5

--FIND MONTH OVER MONTH GROWTH COMPARISON 2022 AND 223 SALES
WITH CTE AS (
SELECT DISTINCT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, 
SUM(sale_price) AS sales 
FROM retail_orders
GROUP BY YEAR(order_date), MONTH(order_date)
--ORDER BY YEAR(order_date), MONTH(order_date
)

SELECT order_month
, SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022
, SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE
GROUP BY order_month
ORDER BY order_month

-- FOR EACH CATEGORY WHICH MONTH HAD HIGHEST SALES
WITH CTE AS (
SELECT category, FORMAT(order_date, 'yyyy-MM') AS order_year_month, SUM(sale_price) AS sales 
FROM retail_orders
GROUP BY category, FORMAT(order_date, 'yyyy-MM')
--ORDER BY category, FORMAT(order_date, 'yyyy-MM')
)
SELECT * FROM (
SELECT  *, 
ROW_NUMBER() OVER(PARTITION BY CATEGORY ORDER BY SALES DESC) AS RN
FROM CTE
) A
WHERE rn=1

-- WHICH SUB CATEGORY HAD HIGHEST GROWTH BY PROFIT  IN 2023 COMPARE TO 2022
WITH CTE AS (
SELECT sub_category, YEAR(order_date) AS order_year,
SUM(sale_price) AS sales 
FROM retail_orders
GROUP BY sub_category, YEAR(order_date)
--ORDER BY YEAR(order_date), MONTH(order_date
)
, CTE2 AS (
SELECT sub_category
, SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022
, SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM CTE
GROUP BY sub_category
)

SELECT TOP 1 *
, (sales_2023-sales_2022)*100/sales_2022

FROM CTE2
ORDER BY (sales_2023-sales_2022)*100/sales_2022 DESC