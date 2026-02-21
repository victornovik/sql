SELECT CustomerID, SalesOrderID,
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)
AS RowNumber
FROM Sales.SalesOrderHeader;

--select *
--from SalesLT.SalesOrderHeader;

-- Deduplication
CREATE TABLE #dupes(Col1 INT, Col2 CHAR(1));
INSERT INTO #dupes(Col1, Col2) VALUES (1,'a'),(1,'a'),(2,'b'), (3,'c'),(4,'d'),(4,'d'),(5,'e');
SELECT Col1, Col2 FROM #dupes;

WITH Dupes AS (
	SELECT Col1, Col2, ROW_NUMBER() OVER(PARTITION BY Col1, Col2 ORDER BY Col1)	AS RowNumber
	FROM #dupes
)
DELETE Dupes WHERE RowNumber > 1;

SELECT Col1, Col2 FROM #dupes;


-- Use ROW_NUMBER to find the first four orders
WITH Orders AS (
	SELECT MONTH(OrderDate) AS OrderMonth, OrderDate, SalesOrderID, TotalDue, 
	ROW_NUMBER() OVER(PARTITION BY MONTH(OrderDate) ORDER BY SalesOrderID) AS RowNumber
	FROM Sales.SalesOrderHeader
	WHERE OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01')
SELECT *
FROM Orders
WHERE RowNumber <= 4
ORDER BY OrderMonth, SalesOrderID;

-- Using the Tally Table to Find Dates with No Orders
--2-11.1 Create the tally table
CREATE TABLE #Numbers(Number INT);

--2-11.2 Populate the tally table with numbers from 1 to 1M
INSERT INTO #Numbers(Number)
SELECT TOP(1000000) ROW_NUMBER() OVER(ORDER BY a.object_id)
FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c;

--2-12.1 Find the earliest date and the number of days
DECLARE @Min DATE, @DayCount INT;
SELECT @Min = MIN(OrderDate),
        @DayCount = DATEDIFF(DAY,MIN(OrderDate),MAX(OrderDate))
FROM Sales.SalesOrderHeader;

--2-12.2 Change numbers to dates and then find dates with no orders
WITH Dates AS (
	SELECT TOP(@DayCount) DATEADD(DAY,Number,@Min) AS OrderDate
	FROM #Numbers AS N
	ORDER BY Number
)
SELECT Dates.OrderDate
FROM Dates LEFT JOIN Sales.SalesOrderHeader SOH ON Dates.OrderDate = SOH.OrderDate
WHERE SOH.SalesOrderID IS NULL;