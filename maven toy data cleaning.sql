SELECT * FROM sales;
SELECT * FROM stores;
SELECT * FROM products;
SELECT * FROM inventory;

-- Trim the '$' sign from the product_cost and product_price columns in the products table,
-- and change their data type to FLOAT to allow arithmetic and aggregation operations.

UPDATE products
SET product_cost = RIGHT(product_cost, -1);

ALTER TABLE products
ALTER COLUMN product_cost TYPE FLOAT USING product_cost::FLOAT;

UPDATE products
SET product_price = RIGHT(product_price, -1);

ALTER TABLE products
ALTER COLUMN product_price TYPE FLOAT USING product_price::FLOAT;
