# maven-toys-retail-expansion-analysis

## Project Overview
In this project, I assume the role of a Business Intelligence (BI) consultant hired by the fictional company Maven Toys. As the company prepares to expand its retail footprint by opening new stores, they’ve engaged me to uncover patterns and trends within their historical sales, inventory, products, and store data. The objective is to deliver actionable insights that will inform their expansion strategy, inventory planning, and overall business decisions.

## Project Workflow
1. Database Setup
2. Data Import
3. Data Cleaning
4. Business Problem Solving

## About the dataset

The dataset provided contains 4 tables in CSV format:

1. The Products table contains the 35 products sold at Maven Toys (each record represents one product), with fields containing details about the product category, cost, and retail price.
2. The Stores table contains the 50 Maven Toys store locations (each record represents one store), with fields containing details about the store location, type, and date it opened.
3. The sales table contains the units sold in over 800,000 sales transactions (each record represents the purchase of a specific product at a specific store on a specific date).
4. The inventory table contains over 1,500 records that represent the stock on hand of each product in each store at the current point in time.

### Database Setup
I created a database for the company and four tables.

``` sql
DROP TABLE IF EXISTS sales;
CREATE TABLE sales(
	Sale_id INT PRIMARY KEY,
	Date DATE,
	Store_id INT,
	Product_id INT,
	Units INT,
	CONSTRAINT fk_s_stores FOREIGN KEY (Store_id) REFERENCES stores(Store_id),
	CONSTRAINT fk_s_products FOREIGN KEY (Product_id) REFERENCES products(Product_id)
);
```


``` sql

```
### Data Import

I imported raw CSV data into respective created database tables using the wizard in pgAdmin.

### Data Cleaning

The data was not so dirty, there was only a problem with the product_cost and product_price columns in the products table. These columns where in teXt format and also had the dollar sign prefix, due to this I won't be able to perform arithmetic and aggregation operations on them. So, I trimmed the '$' sign and changed their datatype to float.

``` sql

UPDATE products
SET product_cost = RIGHT(product_cost, -1);

ALTER TABLE products
ALTER COLUMN product_cost TYPE FLOAT USING product_cost::FLOAT;

UPDATE products
SET product_price = RIGHT(product_price, -1);

ALTER TABLE products
ALTER COLUMN product_price TYPE FLOAT USING product_price::FLOAT;

```
### Analysis
After Cleaning, I went on to answer 15 questions that will help in business expansion. This questions have been grouped to:

1. Revenue Performance & Growth Analysis
2. Product Performance
3. Store Operations & Profitability

``` sql
--  How does the revenue generated in 2022 compare to 2023

WITH yearly_rev AS (
	SELECT DATE_PART('year', s.date) AS year,
		ROUND(SUM(p.product_price * s.units)::NUMERIC, 2) as Revenue,
		LAG(ROUND(SUM(p.product_price * s.units)::NUMERIC, 2)) OVER (ORDER BY DATE_PART('year', s.date)) AS prev_revenue
	FROM sales s
	JOIN products p
		ON s.product_id = p.product_id
	GROUP BY year
	)
	
SELECT year, revenue,
       ROUND((100 * (revenue - prev_revenue) / prev_revenue)::NUMERIC, 2) AS growth_ratio
FROM yearly_rev;
```

| Year | Revenue    | Growth Ratio |
|:------|:------------|:----------------|
| 2022 | 7,482,498.08 | —              |
| 2023 | 6,962,074.27 | -6.96%         |

```sql
-- Q.8 Which product categories contribute the most to sales revenue across different stores?  

WITH revenue_cte AS (
	SELECT st.store_name, p.product_name, ROUND(SUM(p.product_price * s.units)::NUMERIC, 2) AS revenue, 
	RANK() OVER(PARTITION BY st.store_name ORDER BY SUM(p.product_price * s.units) DESC) AS rank
	FROM stores st
	JOIN sales s
		ON st.store_id = s.store_id
	JOIN products p
		ON s.product_id = p.product_id
	GROUP BY st.store_name, p.product_name
	ORDER BY st.store_name, revenue DESC
	)
	
SELECT store_name, product_name, revenue
FROM revenue_cte
WHERE rank = 1;
```

<div style="max-height: 250px; overflow-y: auto;">

| Store Name                  | Product Name      | Revenue   |
|:---------------------------|:-----------------|:----------|
| Maven Toys Aguascalientes 1 | Lego Bricks       | 40829.79  |
| Maven Toys Campeche 1       | Mini Ping Pong Set| 42397.56  |
| Maven Toys Campeche 2       | Lego Bricks       | 25673.58  |
| Maven Toys Chetumal 1       | Lego Bricks       | 52306.92  |
| Maven Toys Chihuahua 1      | Lego Bricks       | 44308.92  |
| *...scroll for more...*     |                   |           |

</div>
