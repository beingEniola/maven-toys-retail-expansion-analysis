
DROP TABLE IF EXISTS stores;
CREATE TABLE stores(
	Store_id INT PRIMARY KEY,
	Store_Name VARCHAR(100),
	Store_City VARCHAR(50),
	Store_Location VARCHAR(50),
	Store_Open_Date DATE
);
	
DROP TABLE IF EXISTS products;
CREATE TABLE products(
	Product_id INT PRIMARY KEY,
	Product_Name VARCHAR(50),
	Product_Category VARCHAR(50),
	Product_Cost VARCHAR(50),
	Product_Price VARCHAR(50)
);

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

DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory(
	Store_id INT,
	Product_id INT,
	Stock_On_Hand INT,
	CONSTRAINT fk_i_products FOREIGN KEY (Product_id) REFERENCES products(Product_id),
	CONSTRAINT fk_i_stores FOREIGN KEY (Store_id) REFERENCES stores(Store_id)
);