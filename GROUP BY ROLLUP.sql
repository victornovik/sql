SELECT Country, Region, SUM(sales) AS TotalSales
FROM Sales
GROUP BY Country, Region;

-- Groups with subtotals and totals
SELECT Country, Region, SUM(sales) AS TotalSales
FROM Sales
GROUP BY ROLLUP (Country, Region);

-- Groups for all combinations of Country and Region
SELECT Country, Region, SUM(sales) AS TotalSales
FROM Sales
GROUP BY CUBE (Country, Region);

-- Returns the union of the ROLLUP and CUBE results for Country and Region
SELECT Country, Region, SUM(Sales) AS TotalSales
FROM Sales
GROUP BY GROUPING SETS ( ROLLUP (Country, Region), CUBE (Country, Region) );


--CREATE TABLE Sales ( 
--Country VARCHAR(50), 
--Region VARCHAR(50), 
--Sales INT );

--INSERT INTO sales VALUES (N'Canada', N'Alberta', 100);
--INSERT INTO sales VALUES (N'Canada', N'Columbia', 200);
--INSERT INTO sales VALUES (N'Canada', N'Columbia', 300);
--INSERT INTO sales VALUES (N'Canada', N'Columbia', 300);
--INSERT INTO sales VALUES (N'Canada', N'Alberta', 100);
--INSERT INTO sales VALUES (N'United States', N'Montana', 100);
--INSERT INTO sales VALUES (N'Columbia', N'Columbia', 300);
--INSERT INTO sales VALUES (N'Columbia', N'Center', 150);

