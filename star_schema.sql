-- ============================================
-- Online Retail II — Star Schema
-- Author: Adnan Mustafa
-- Database: MySQL (Aiven Cloud)
-- ============================================

-- 1. Main Raw Table
CREATE TABLE IF NOT EXISTS online_retail_II (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    Invoice VARCHAR(20),
    StockCode VARCHAR(20),
    Description VARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    Price DECIMAL(10,2),
    Customer_ID INT,
    Country VARCHAR(100),
    Order_Status VARCHAR(20),
    Revenue DECIMAL(10,2)
);

-- 2. Products Lookup (Dimension Table)
CREATE TABLE IF NOT EXISTS Products_Lookup (
    ProductID VARCHAR(20) PRIMARY KEY,
    Description VARCHAR(255)
);

INSERT IGNORE INTO Products_Lookup (ProductID, Description)
SELECT StockCode, MAX(Description)
FROM online_retail_II
WHERE StockCode IS NOT NULL
GROUP BY StockCode;

-- Remove trailing spaces from ProductID
SET SQL_SAFE_UPDATES = 0;
DELETE FROM Products_Lookup WHERE LENGTH(ProductID) > LENGTH(TRIM(ProductID));
UPDATE Products_Lookup SET ProductID = TRIM(ProductID);
SET SQL_SAFE_UPDATES = 1;

-- 3. Customers Lookup (Dimension Table)
CREATE TABLE IF NOT EXISTS Customers_Lookup (
    Customer_ID INT PRIMARY KEY
);

INSERT INTO Customers_Lookup (Customer_ID)
SELECT DISTINCT Customer_ID
FROM online_retail_II
WHERE Customer_ID IS NOT NULL;

-- 4. Sales Data (Fact Table)
CREATE TABLE IF NOT EXISTS Sales_Data (
    row_id INT PRIMARY KEY,
    Invoice VARCHAR(20),
    ProductID VARCHAR(20),
    CustomerID INT,
    InvoiceDate DATETIME,
    Quantity INT,
    Price DECIMAL(10,2),
    Revenue DECIMAL(10,2),
    Country VARCHAR(100),
    OrderStatus VARCHAR(20)
);

INSERT INTO Sales_Data
SELECT
    row_id,
    Invoice,
    StockCode,
    Customer_ID,
    InvoiceDate,
    Quantity,
    Price,
    Revenue,
    Country,
    Order_Status
FROM online_retail_II;

-- Trim ProductID in Sales_Data
SET SQL_SAFE_UPDATES = 0;
UPDATE Sales_Data SET ProductID = TRIM(ProductID);
SET SQL_SAFE_UPDATES = 1;

-- Verify row counts
SELECT COUNT(*) AS online_retail_rows FROM online_retail_II;
SELECT COUNT(*) AS products_lookup_rows FROM Products_Lookup;
SELECT COUNT(*) AS customers_lookup_rows FROM Customers_Lookup;
SELECT COUNT(*) AS sales_data_rows FROM Sales_Data;
