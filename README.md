# maven-toys-retail-expansion-analysis

## Project Overview
In this project, I assume the role of a Business Intelligence (BI) consultant hired by the fictional company Maven Toys. As the company prepares to expand its retail footprint by opening new stores, they’ve engaged me to uncover patterns and trends within their historical sales, inventory, products, and store data. The objective is to deliver actionable insights that will inform their expansion strategy, inventory planning, and overall business decisions.

## About the dataset

The dataset provided contains 4 tables in CSV format:

1. The Products table contains the 35 unique products sold at Maven Toys,  with fields containing details about the product category, cost, and retail price.
2. The Stores table contains the 50 Maven Toys stores, with fields containing details about the store location, type, and date it opened.
3. The sales table contains the units sold in over 800,000 sales transactions, each record represents the purchase of a specific product at a specific store on a specific date.
4. The inventory table contains over 1,500 records that represent the stock on hand of each product in each store at the current point in time.

## Project Workflow
1. Database Setup
2. Data Import
3. Data Cleaning
4. Data Analysis

### Database Setup
I created a database for the company and four tables.

``` sql

CREATE DATABSE maven_toys;

```

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
[Here](https://github.com/beingEniola/maven-toys-retail-expansion-analysis/blob/cef860c457220d219f4c4ddc6a88105483400e62/Maven%20toy%20schema.sql) is the full codes on how I created all the needed table.

### Data Import

I imported the raw CSV data into the respective database tables using the import wizard feature in pgAdmin.

### Data Model (ERD)

![Database Schema Model](https://github.com/user-attachments/assets/fea320c8-08bf-4639-bbbc-54b6e53b9c39)

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
Data Cleaning file can be found [here](https://github.com/beingEniola/maven-toys-retail-expansion-analysis/blob/cef860c457220d219f4c4ddc6a88105483400e62/maven%20toy%20data%20cleaning.sql)

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

| Year | Revenue      | Growth Ratio |
|:------|:------------|:-------------|
| 2022 | 7,482,498.08 | —            |
| 2023 | 6,962,074.27 | -6.96%       |

full analysis please click [here]()
For a detailed walkthrough of the business questions, SQL solutions, insights, and recommendations from this project, check out the full write-up on [Medium](https://medium.com/@dorcazkayode/maven-toys-retail-expansion-analysis-395a10fb8a61). 

## Insights 

1. Ciudad de Mexico 2 is the top-performing store, generating significantly higher revenue than the others. This store is a good model for new locations.
2. Lego Bricks is a consistent top selling product across all stores
3. Even though revenue fell by 6% in 2023, Downtown stores still made the most money. Their performance stayed more stable than other store types, which saw drops between 2% and 11%. This makes Downtown areas a strong option for opening new stores
4. Cities like Ciudad de Mexico , Guadalajara, and Monterrey topped in revenue and achieved a profit margin of almost 30%.
5. Fast selling products are  'Action Figure' and 'Colorbuds'.
6. Campeche 2, La Paz 1, and 30 other stores are currently generating sales lower than the average.

## Recommendations

1. Prioritize opening new stores in Downtown areas due to their strong and stable revenue performance despite the market decline.
2. Model new store operations after top performers like Ciudad de Mexico 2, specifically analyzing and replicating their inventory mix, pricing, and customer engagement strategies.
3. Increase inventory and promotions in December, especially for Mall and Urban stores, to leverage the annual sales peak.
4. Ensure consistent stock availability for high-performing products such as Lego Bricks, Colorbuds, and Action Figures to maximize revenue and customer satisfaction.
5. Improve inventory monitoring and restocking to solve the stockout issues at stores like La Paz 1, Hermosillo 2, and Pachuca 1.
6. Review how stores like Campeche 2 and La Paz 1 are doing, along with other below-average locations, to find out what's wrong or how they can be improved.
