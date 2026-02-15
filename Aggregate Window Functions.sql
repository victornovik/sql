SELECT CustomerID, SalesOrderID,
	 FORMAT(MIN(OrderDate) OVER(PARTITION BY CustomerID),'yyyy-MM-dd') AS FirstOrderDate,
	 FORMAT(MAX(OrderDate) OVER(PARTITION BY CustomerID),'yyyy-MM-dd') AS LastOrderDate,
	 COUNT(*) OVER(PARTITION BY CustomerID) OrderCount,
	 FORMAT(SUM(TotalDue) OVER(PARTITION BY CustomerID),'C') AS TotalAmount
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;


-- Calculate the percent of sales
SELECT P.ProductID,
	 FORMAT(SUM(OrderQty * UnitPrice),'C') AS ProductSales,
	 FORMAT(SUM(SUM(OrderQty * UnitPrice)) OVER(),'C') AS TotalSales,
	 FORMAT(SUM(OrderQty * UnitPrice) / SUM(SUM(OrderQty * UnitPrice)) OVER(), 'P') AS PercentOfSales
FROM Sales.SalesOrderDetail AS SOD
JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
JOIN Production.ProductSubcategory AS SUB ON P.ProductSubcategoryID = SUB.ProductSubcategoryID
JOIN Production.ProductCategory AS CAT ON SUB.ProductCategoryID = CAT.ProductCategoryID
WHERE CAT.Name = 'Bikes'
GROUP BY P.ProductID
ORDER BY PercentOfSales DESC;


-- Running total
SELECT CustomerID, SalesOrderID, CAST(OrderDate AS DATE) AS OrderDate, TotalDue, 
	SUM(TotalDue) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) AS RunningTotal
FROM Sales.SalesOrderHeader;

-- Running and reverse running totals
SELECT CustomerID, CAST(OrderDate AS DATE) AS OrderDate, SalesOrderID,TotalDue,
    SUM(TotalDue) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID ROWS UNBOUNDED PRECEDING) AS RunningTotal,
    SUM(TotalDue) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS ReverseTotal
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;


-- Sliding window for 3 months (moving sum and moving average)
-- Three month sum and average for products qty sold
SELECT MONTH(SOH.OrderDate) AS OrderMonth, SOD.ProductID, SUM(SOD.OrderQty) AS QtySold,
    SUM(SUM(SOD.OrderQty)) OVER(PARTITION BY SOD.ProductID ORDER BY MONTH(SOH.OrderDate) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeMonthSum,
    AVG(SUM(SOD.OrderQty)) OVER(PARTITION BY SOD.ProductID ORDER BY MONTH(SOH.OrderDate) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeMonthAvg
FROM Sales.SalesOrderHeader AS SOH 
JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN Production.Product AS P ON SOD.ProductID = P.ProductID WHERE OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01'
GROUP BY MONTH(SOH.OrderDate), SOD.ProductID;


-- Moving sum and average
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, COUNT(*) AS OrderCount,
    SUM(COUNT(*)) OVER(ORDER BY YEAR(OrderDate), MONTH(OrderDate) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeMonthCount,
    AVG(COUNT(*)) OVER(ORDER BY YEAR(OrderDate), MONTH(OrderDate) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeMonthAvg
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2012-01-01' AND OrderDate < '2013-01-01'
GROUP BY YEAR(OrderDate), MONTH(OrderDate);


-- Compare the logical difference between ROWS and RANGE
-- Pay attention to lines 7, 8 and 9
-- The window for ROWS in this case starts with the first row and includes all rows up to the current row sorted by the ORDER BY. 
-- The window for RANGE is all rows starting with the first row and up to any rows WITH THE SAME value as the current row’s ORDER BY expression. 
-- When the window for row 7 is determined, RANGE looks at not just the position but also the value. 
-- The value for the OrderDate for row 8 is the same as the value for row 7, so row 8 is included in the window for row 7 when we use RANGE.
SELECT CustomerID, CAST(OrderDate AS DATE) AS OrderDate, SalesOrderID, TotalDue,
    SUM(TotalDue) OVER(ORDER BY OrderDate ROWS UNBOUNDED PRECEDING) AS RunningTotalRows,
    SUM(TotalDue) OVER(ORDER BY OrderDate RANGE UNBOUNDED PRECEDING) AS RunningTotalRange
FROM Sales.SalesOrderHeader
WHERE CustomerID =11300
ORDER BY SalesOrderID;


-- The task is to replace each NULL with the previous non-NULL value.
CREATE TABLE #TheTable(ID INT, Data INT);
INSERT INTO #TheTable(ID, Data) VALUES(1,1),(2,1),(3,NULL),(4,NULL),(5,6),(6,NULL),(7,5),(8,10),(9,13),(10,12),(11,NULL);
SELECT * FROM #TheTable;
-- Find the max non-null row
WITH MaxData AS (
	SELECT ID, Data, MAX(CASE WHEN Data IS NOT NULL THEN ID END) OVER(ORDER BY ID) AS MaxRowID
    FROM #TheTable
)
SELECT ID, Data, MAX(Data) OVER(PARTITION BY MaxRowID) AS NewData
FROM MaxData;


-- People subscribe and unsubscribe. Find the number of active subscriptions at the end of each month
CREATE TABLE #Registrations(ID INT NOT NULL IDENTITY PRIMARY KEY, DateJoined DATE NOT NULL, DateLeft DATE NULL);

DECLARE @Rows INT = 10000, @Years INT = 5, @StartDate DATE = '2019-01-01'

INSERT INTO #Registrations (DateJoined)
SELECT TOP(@Rows) DATEADD(DAY,CAST(RAND(CHECKSUM(NEWID())) * @Years * 365  as INT) ,@StartDate)
FROM sys.objects a CROSS JOIN sys.objects b CROSS JOIN sys.objects c;

UPDATE TOP(75) PERCENT #Registrations
SET DateLeft = DATEADD(DAY,CAST(RAND(CHECKSUM(NEWID())) * @Years * 365 as INT),DateJoined)

SELECT *
FROM #Registrations
ORDER BY DateJoined;


-- Solve the active subscription problem
WITH NewSubs AS (
    SELECT EOMONTH(DateJoined) AS TheMonth, COUNT(DateJoined) AS PeopleJoined
    FROM #Registrations
    GROUP BY EOMONTH(DateJoined)
), Cancelled AS (
    SELECT EOMONTH(DateLeft) AS TheMonth, COUNT(DateLeft) AS PeopleLeft
    FROM #Registrations
    GROUP BY EOMONTH(DateLeft)
)
SELECT NewSubs.TheMonth, NewSubs.PeopleJoined, Cancelled.PeopleLeft,
    SUM(NewSubs.PeopleJoined - ISNULL(Cancelled.PeopleLeft, 0)) OVER(ORDER BY NewSubs.TheMonth) AS ActiveSubscriptions
FROM NewSubs LEFT JOIN Cancelled ON NewSubs.TheMonth = Cancelled.TheMonth;


-- If FILTER is specified then window function accepts only rows filtered by FILTER (WHERE).
SELECT 
    count(*) AS unfiltered,
    count(*) FILTER (WHERE i < 5) AS filtered
FROM generate_series(1, 10) AS s(i);
