SET STATISTICS IO ON;
SET NOCOUNT ON;

-- Query to produce Sequence Project (Compute Scalar) and Segment operators that are specific for window functions
-- Enable Execution Plan by (Ctrl + M)
SELECT CustomerID, SalesOrderID, ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) AS RowNumber
FROM Sales.SalesOrderHeader;


-- A query to show the Sort operator taking 80% of query execution
SELECT CustomerID, SalesOrderID, ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS RowNumber
FROM Sales.SalesOrderHeader;

-- A query with a Table Spool operator
-- The Table Spool operator means that a worktable is created in tempdb to help solve the query
SELECT CustomerID, SalesOrderID, TotalDue, SUM(TotalDue) OVER(PARTITION BY CustomerID) AS SubTotal
FROM Sales.SalesOrderHeader;