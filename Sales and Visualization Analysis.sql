CREATE DATABASE Sales_Analysis;

USE Sales_Analysis;

CREATE TABLE Product_Master (
    Product_ID VARCHAR(20) PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100),
    Brand VARCHAR(100),
    Cost_Price DECIMAL(12,2),
    Unit_Price DECIMAL(12,2)
);

CREATE TABLE Customer_Master (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Gender VARCHAR(20),
    Age_Group VARCHAR(50),
    State VARCHAR(100),
    City VARCHAR(100),
    Customer_Segment VARCHAR(50)
);

CREATE TABLE Region_Master (
    State VARCHAR(100) PRIMARY KEY,
    Region VARCHAR(50),
    Zone VARCHAR(50)
);

CREATE TABLE Sales_Data (
    Order_ID VARCHAR(30) PRIMARY KEY,
    Order_Date DATE,
    Ship_Date DATE,

    Customer_ID VARCHAR(20),
    Customer_Name VARCHAR(100),
    Gender VARCHAR(20),

    State VARCHAR(100),
    City VARCHAR(100),
    Region VARCHAR(50),

    Channel VARCHAR(50),

    Product_ID VARCHAR(20),
    Product_Name VARCHAR(100),
    Category VARCHAR(100),
    Sub_Category VARCHAR(100),

    Quantity INT,
    Unit_Price DECIMAL(12,2),
    Discount_Pct DECIMAL(6,4),
    Shipping_Fee DECIMAL(12,2),

    Payment_Method VARCHAR(50),
    Order_Status VARCHAR(50),

    Rating DECIMAL(3,1),

    Gross_Sales DECIMAL(14,2),
    Discount_Amount DECIMAL(14,2),
    Net_Sales DECIMAL(14,2),

    Cost DECIMAL(14,2),
    Profit DECIMAL(14,2)
);

BULK INSERT Product_Master
FROM 'C:\Users\singh\OneDrive\Desktop\Sales_Data_Analysis_Dataset_\Product_Master.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

USE Sales_Analysis;
GO

TRUNCATE TABLE Product_Master;
GO

BULK INSERT Customer_Master
FROM 'C:\Users\singh\OneDrive\Desktop\Sales_Data_Analysis_Dataset_\Customer_Master.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

BULK INSERT Region_Master
FROM 'C:\Users\singh\OneDrive\Desktop\Sales_Data_Analysis_Dataset_\Region_Master.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

BULK INSERT Sales_Data
FROM 'C:\Users\singh\OneDrive\Desktop\Sales_Data_Analysis_Dataset_\Sales_Data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

--Identify your 4 tables
SELECT TOP 10 * FROM [dbo].[Sales_Data];
SELECT TOP 10 * FROM Customer_Master;
SELECT TOP 10 * FROM Product_Master;
SELECT TOP 10 * FROM Region_Master;

-- Number of records
SELECT COUNT(*) AS Total_Rows
FROM Sales_Data

SELECT COUNT(*) AS Total_Customers
FROM Customer_Master;

SELECT COUNT(*) AS Total_Products
FROM Product_Master;

SELECT COUNT(*) AS Total_Regions
FROM Region_Master;

-- Check duplicate Order IDs
SELECT
    Order_ID,
    COUNT(*) AS Duplicate_Count
FROM Sales_Data
GROUP BY Order_ID
HAVING COUNT(*) > 1;

-- Check NULL values
SELECT
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Null_Order_ID,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Null_Order_Date,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Null_Customer_ID,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Null_Product_ID,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN Net_Sales IS NULL THEN 1 ELSE 0 END) AS Null_Net_Sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Null_Profit
FROM Sales_Data

-- Check data types
EXEC sp_help 'Sales_Data'

-- Sales Analysis
-- Total_Revenue
select SUM(Net_Sales) as Revenue from Sales_Data

-- Total_Profit
select SUM(profit) as Total_Profit from Sales_Data

-- Total_Quantity
select SUM(quantity) as Total_Quantity from Sales_Data

-- Number_Of_Orders
select COUNT(distinct Order_ID) as Total_Orders from sales_data

-- Calculate profit margin
SELECT
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND(
        SUM(Profit) * 100.0 / NULLIF(SUM(Net_Sales), 0),
        2
    ) AS Profit_Margin_Percentage
FROM Sales_Data

-- Sales by category
SELECT
    Category,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Sales by region
SELECT Region,
SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Region
ORDER BY Total_Sales DESC;


-- Sales by state
SELECT
    s.State,
    r.Region,
    r.Zone,
    SUM(s.Net_Sales) AS Total_Sales,
    SUM(s.Profit) AS Total_Profit
FROM Sales_Data s
LEFT JOIN Region_Master r
    ON s.State = r.State
GROUP BY
    s.State,
    r.Region,
    r.Zone
ORDER BY Total_Sales DESC;

-- Monthly sales trend
SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Sales_Year,
    Sales_Month;

-- Yearly Sales
 SELECT
    YEAR(Order_Date) AS Sales_Year,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM Sales_Data
GROUP BY YEAR(Order_Date)
ORDER BY Sales_Year;

-- Quaterly Sales
SELECT YEAR(Order_Date) AS Sales_Year,
DATEPART(QUARTER, Order_Date) AS Sales_Quarter,
SUM(Net_Sales) AS Total_Sales,
SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY
    YEAR(Order_Date),
    DATEPART(QUARTER, Order_Date)
ORDER BY
    Sales_Year,
    Sales_Quarter;

-- Sales by channel
SELECT Channel,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Total_Quantity,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Channel
ORDER BY Total_Sales DESC;

-- Payment method analysis
SELECT
    Payment_Method,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Payment_Method
ORDER BY Total_Sales DESC;

-- Order status analysis
SELECT
    Order_Status,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Order_Status
ORDER BY Total_Orders DESC;

-- Gender analysis
SELECT
    Gender,
    COUNT(DISTINCT Customer_ID) AS Customers,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Gender
ORDER BY Total_Sales DESC;

-- Customer segment analysis
SELECT c.Customer_Segment,
    COUNT(DISTINCT s.Customer_ID) AS Customers,
    COUNT(DISTINCT s.Order_ID) AS Orders,
    SUM(s.Net_Sales) AS Total_Sales,
    SUM(s.Profit) AS Total_Profit
FROM Sales_Data s
INNER JOIN Customer_Master c
    ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY Total_Sales DESC;

-- Customer master JOIN
SELECT s.Order_ID,s.Order_Date,s.Customer_ID,
c.Customer_Name,c.Gender,c.Age_Group,c.State,c.City,c.Customer_Segment,
s.Net_Sales,s.Profit
FROM Sales_Data s INNER JOIN Customer_Master c
ON s.Customer_ID = c.Customer_ID;

-- Product master JOIN
SELECT s.Order_ID,s.Order_Date,s.Product_ID,
p.Product_Name,p.Category,p.Sub_Category,p.Brand,p.Cost_Price,p.Unit_Price,
s.Quantity,s.Net_Sales,s.Profit
FROM Sales_Data s INNER JOIN Product_Master p
ON s.Product_ID = p.Product_ID;

-- Full analytical JOIN
SELECT s.Order_ID,s.Order_Date,s.Ship_Date,s.Customer_ID,
c.Customer_Name,c.Gender,c.Age_Group,c.Customer_Segment,
s.Product_ID,
p.Product_Name,p.Category,p.Sub_Category,p.Brand,
s.State,s.City,
r.Region,r.Zone,
s.Channel,s.Quantity,s.Unit_Price,s.Discount_Pct,s.Shipping_Fee,s.Payment_Method,s.Order_Status,
s.Rating,s.Gross_Sales,s.Discount_Amount,s.Net_Sales,s.Cost,s.Profit
FROM Sales_Data s LEFT JOIN Customer_Master c
ON s.Customer_ID = c.Customer_ID LEFT JOIN Product_Master p
ON s.Product_ID = p.Product_ID LEFT JOIN Region_Master r
ON s.State = r.State;

-- ("I combined transactional sales data with customer, 
-- product and regional master data using LEFT JOINs to create an analytical dataset.")

-- Check unmatched customers
SELECT
    s.Customer_ID
FROM Sales_Data s
LEFT JOIN Customer_Master c
    ON s.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- Check unmatched products
SELECT
    s.Product_ID
FROM Sales_Data s
LEFT JOIN Product_Master p
    ON s.Product_ID = p.Product_ID
WHERE p.Product_ID IS NULL;

-- Check unmatched states
SELECT
    s.State
FROM Sales_Data s
LEFT JOIN Region_Master r
    ON s.State = r.State
WHERE r.State IS NULL;

-- Top 10 customers
SELECT TOP 10
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment,
    COUNT(DISTINCT s.Order_ID) AS Total_Orders,
    SUM(s.Net_Sales) AS Total_Sales,
    SUM(s.Profit) AS Total_Profit
FROM Sales_Data s
INNER JOIN Customer_Master c
    ON s.Customer_ID = c.Customer_ID
GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment
ORDER BY Total_Sales DESC;

-- Top 10 products
SELECT TOP 10
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Brand,
    SUM(s.Quantity) AS Total_Quantity,
    SUM(s.Net_Sales) AS Total_Sales,
    SUM(s.Profit) AS Total_Profit
FROM Sales_Data s
INNER JOIN Product_Master p
    ON s.Product_ID = p.Product_ID
GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category,
    p.Brand
ORDER BY Total_Sales DESC;

-- Top 10 cities
SELECT TOP 10
    City,
    State,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY
    City,
    State
ORDER BY Total_Sales DESC;

-- Top brands
SELECT
    p.Brand,
    SUM(s.Net_Sales) AS Total_Sales,
    SUM(s.Profit) AS Total_Profit,
    SUM(s.Quantity) AS Total_Quantity
FROM Sales_Data s
INNER JOIN Product_Master p
    ON s.Product_ID = p.Product_ID
GROUP BY p.Brand
ORDER BY Total_Sales DESC;

-- Category profitability
SELECT
    Category,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Net_Sales), 0),
        2
    ) AS Profit_Margin

FROM Sales_Data
GROUP BY Category
ORDER BY Profit DESC;

-- Loss-making products
SELECT
    p.Product_Name,
    p.Category,
    SUM(s.Net_Sales) AS Sales,
    SUM(s.Profit) AS Profit
FROM Sales_Data s
INNER JOIN Product_Master p
    ON s.Product_ID = p.Product_ID
GROUP BY
    p.Product_Name,
    p.Category
HAVING SUM(s.Profit) < 0
ORDER BY Profit ASC;

-- Product ranking within category
SELECT
    p.Product_Name,
    p.Category,
    SUM(s.Net_Sales) AS Total_Sales,

    RANK() OVER
    (
        PARTITION BY p.Category
        ORDER BY SUM(s.Net_Sales) DESC
    ) AS Product_Rank

FROM Sales_Data s

INNER JOIN Product_Master p
    ON s.Product_ID = p.Product_ID

GROUP BY
    p.Product_Name,
    p.Category;

-- Top product in each category
WITH ProductRanking AS
(
    SELECT
        p.Product_Name,
        p.Category,
        SUM(s.Net_Sales) AS Total_Sales,

        RANK() OVER
        (
            PARTITION BY p.Category
            ORDER BY SUM(s.Net_Sales) DESC
        ) AS Product_Rank

    FROM Sales_Data s

    INNER JOIN Product_Master p
        ON s.Product_ID = p.Product_ID

    GROUP BY p.Product_Name,p.Category)

SELECT
    Product_Name,
    Category,
    Total_Sales
FROM ProductRanking
WHERE Product_Rank = 1
ORDER BY Category;

-- Monthly sales with LAG
WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        SUM(Net_Sales) AS Monthly_Sales
    FROM Sales_Data
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
)

SELECT
    Sales_Year,
    Sales_Month,
    Monthly_Sales,

    LAG(Monthly_Sales) OVER
    (
        ORDER BY Sales_Year, Sales_Month
    ) AS Previous_Month_Sales

FROM MonthlySales
ORDER BY
    Sales_Year,
    Sales_Month;

-- Month-over-month growth
WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        SUM(Net_Sales) AS Monthly_Sales
    FROM Sales_Data
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),

MoM AS
(
    SELECT
        Sales_Year,
        Sales_Month,
        Monthly_Sales,

        LAG(Monthly_Sales) OVER
        (
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Sales

    FROM MonthlySales
)

SELECT
    Sales_Year,
    Sales_Month,
    Monthly_Sales,
    Previous_Month_Sales,

    ROUND(
        (Monthly_Sales - Previous_Month_Sales) * 100.0 /
        NULLIF(Previous_Month_Sales, 0),
        2
    ) AS MoM_Growth_Percentage

FROM MoM
ORDER BY
    Sales_Year,
    Sales_Month;

-- Running revenue
WITH MonthlySales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        SUM(Net_Sales) AS Monthly_Sales
    FROM Sales_Data
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
)

SELECT
    Sales_Year,
    Sales_Month,
    Monthly_Sales,

    SUM(Monthly_Sales) OVER
    (
        ORDER BY Sales_Year, Sales_Month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Revenue

FROM MonthlySales
ORDER BY
    Sales_Year,
    Sales_Month;

-- Customers above average spending
WITH CustomerSales AS
(
    SELECT
        Customer_ID,
        SUM(Net_Sales) AS Total_Sales
    FROM Sales_Data
    GROUP BY Customer_ID
)

SELECT
    Customer_ID,
    Total_Sales
FROM CustomerSales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM CustomerSales
)
ORDER BY Total_Sales DESC;

-- Regional ranking
SELECT
    Region,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,

    RANK() OVER
    (
        ORDER BY SUM(Net_Sales) DESC
    ) AS Region_Rank

FROM Sales_Data
GROUP BY Region
ORDER BY Region_Rank;

-- Discount analysis
SELECT
    Category,
    ROUND(AVG(Discount_Pct) * 100, 2) AS Avg_Discount_Percentage,
    SUM(Discount_Amount) AS Total_Discount,
    SUM(Net_Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM Sales_Data
GROUP BY Category
ORDER BY Avg_Discount_Percentage DESC;

-- Shipping performance 
-- how many days it takes to ship
SELECT
    AVG(DATEDIFF(DAY, Order_Date, Ship_Date) * 1.0)
        AS Average_Shipping_Days
FROM Sales_Data;

-- Shipping time by region
SELECT
    Region,
    AVG(DATEDIFF(DAY, Order_Date, Ship_Date) * 1.0)
        AS Average_Shipping_Days
FROM Sales_Data
GROUP BY Region
ORDER BY Average_Shipping_Days DESC;

-- Customer lifetime sales
SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment,
    COUNT(DISTINCT s.Order_ID) AS Total_Orders,
    SUM(s.Net_Sales) AS Lifetime_Sales,
    SUM(s.Profit) AS Lifetime_Profit,

    ROUND(
        SUM(s.Net_Sales) * 1.0 /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS Average_Order_Value

FROM Sales_Data s

INNER JOIN Customer_Master c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Segment

ORDER BY Lifetime_Sales DESC;

-- Create the final analytical VIEW
CREATE OR ALTER VIEW vw_Sales_Analysis
AS

SELECT
    s.Order_ID,
    s.Order_Date,
    s.Ship_Date,

    s.Customer_ID,
    c.Customer_Name,
    c.Gender,
    c.Age_Group,
    c.Customer_Segment,

    s.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,
    p.Brand,

    s.State,
    s.City,
    r.Region,
    r.Zone,

    s.Channel,

    s.Quantity,
    s.Unit_Price,
    s.Discount_Pct,
    s.Shipping_Fee,

    s.Payment_Method,
    s.Order_Status,
    s.Rating,

    s.Gross_Sales,
    s.Discount_Amount,
    s.Net_Sales,
    s.Cost,
    s.Profit,

    DATEDIFF(DAY, s.Order_Date, s.Ship_Date)
        AS Shipping_Days

FROM Sales_Data s

LEFT JOIN Customer_Master c
    ON s.Customer_ID = c.Customer_ID

LEFT JOIN Product_Master p
    ON s.Product_ID = p.Product_ID

LEFT JOIN Region_Master r
    ON s.State = r.State;
GO

SELECT TOP 20 *
FROM vw_Sales_Analysis;