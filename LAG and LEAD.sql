-- Find close price from the previous date using a correlated subquery
USE StockAnalysis;
SELECT TickerSymbol, TradeDate, ClosePrice,
	(SELECT TOP(1) ClosePrice
	FROM StockHistory AS innerSH
	WHERE innerSH.TickerSymbol = outerSH.TickerSymbol AND innerSH.TradeDate < outerSH.TradeDate
	ORDER BY TradeDate DESC) AS PrevClosePrice
FROM StockHistory AS outerSH
ORDER BY TickerSymbol, TradeDate;


-- Find close price from the previous date using LAG
USE StockAnalysis;
SELECT TickerSymbol, TradeDate, ClosePrice,
	LAG(ClosePrice) OVER(PARTITION BY TickerSymbol ORDER BY TradeDate) AS PrevClosePrice
FROM StockHistory
ORDER BY TickerSymbol, TradeDate;


--6-1.1 Use LAG and LEAD
USE AdventureWorks2014;
SELECT CustomerID, SalesOrderID, CAST(OrderDate AS DATE) AS OrderDate,
    LAG(CAST(OrderDate AS DATE)) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) AS PrevOrderDate,
    LEAD(CAST(OrderDate AS DATE)) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) AS NextOrderDate
FROM Sales.SalesOrderHeader;

--6-1.2 Use LAG and LEAD as an argument
SELECT CustomerID, SalesOrderID, CAST(OrderDate AS DATE) AS OrderDate,
    DATEDIFF(DAY, LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID), OrderDate) AS DaysSincePrevOrder,
    DATEDIFF(DAY, OrderDate, LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)) AS DaysUntilNextOrder
FROM Sales.SalesOrderHeader;



--6-5.1 Calculate Year-Over-Year Growth
WITH Level1 AS (
    SELECT YEAR(OrderDate) AS SalesYear, 
        MONTH(OrderDate) AS SalesMonth, 
        SUM(TotalDue) AS TotalSales
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
Level2 AS (
    SELECT SalesYear, SalesMonth, TotalSales, LAG(TotalSales, 12) OVER(ORDER BY SalesYear) AS PrevYearSales
    FROM Level1
)
SELECT SalesYear, SalesMonth,
    FORMAT(TotalSales,'C') AS TotalSales,
    FORMAT(PrevYearSales,'C') AS PrevYearSales,
    FORMAT((TotalSales - PrevYearSales) / PrevYearSales, 'P') AS YOY_Growth
FROM Level2
WHERE PrevYearSales IS NOT NULL;



-- Calculate how long each employee worked on each shift.
-- Create the table
DROP TABLE IF EXISTS #TimeCards;
CREATE TABLE #TimeCards(
    TimeStampID INT NOT NULL IDENTITY PRIMARY KEY,
    EmployeeID INT NOT NULL,
    ClockDateTime DATETIME2(0) NOT NULL,
    EventType VARCHAR(5) NOT NULL);

-- Populate the table
INSERT INTO #TimeCards(EmployeeID,
    ClockDateTime, EventType)
VALUES
    (1,'2019-01-02 08:00','ENTER'),
    (2,'2019-01-02 08:03','ENTER'),
    (2,'2019-01-02 12:00','EXIT'),
    (2,'2019-01-02 12:34','ENTER'),
    (3,'2019-01-02 16:30','ENTER'),
    (2,'2019-01-02 16:00','EXIT'),
    (1,'2019-01-02 16:07','EXIT'),
    (3,'2019-01-03 01:00','EXIT'),
    (2,'2019-01-03 08:10','ENTER'),
    (1,'2019-01-03 08:15','ENTER'),
    (2,'2019-01-03 12:17','EXIT'),
    (3,'2019-01-03 16:00','ENTER'),
    (1,'2019-01-03 15:59','EXIT'),
    (3,'2019-01-04 01:00','EXIT');

-- Display the rows
SELECT TimeStampID, EmployeeID, ClockDateTime, EventType
FROM #TimeCards;

-- Calculate how long each employee worked on each shift.
WITH Level1 AS (
    SELECT EmployeeID, EventType, ClockDateTime, LEAD(ClockDateTime) OVER(PARTITION BY EmployeeID ORDER BY ClockDateTime) AS NextDateTime
    FROM #TimeCards
),
Level2 AS (
    SELECT EmployeeID, CAST(ClockDateTime AS DATE) AS WorkDate, SUM(DATEDIFF(second, ClockDateTime, NextDateTime)) AS Seconds 
    FROM Level1
    WHERE EventType = 'Enter'
    GROUP BY EmployeeID, CAST(ClockDateTime AS DATE))
SELECT EmployeeID, WorkDate, TIMEFROMPARTS(Seconds / 3600, Seconds % 3600 / 60, Seconds % 3600 % 60, 0, 0) AS HoursWorked
FROM Level2
ORDER BY EmployeeID, WorkDate;