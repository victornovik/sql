SELECT CustomerID, SalesOrderID,
	ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)
AS RowNumber
FROM Sales.SalesOrderHeader;

--select *
--from SalesLT.SalesOrderHeader;
