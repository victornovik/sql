--2-4.1 Using RANK and DENSE_RANK
-- RANK says how many rows before the current one
-- DENSE_RANK says how many different values come before the current value. 
-- Another way to think about this is that DENSE_RANK doesn’t waste any numbers, while RANK skips numbers
SELECT CustomerID, OrderDate,
	 ROW_NUMBER() OVER(ORDER BY OrderDate) AS RowNumber,
	 RANK() OVER(ORDER BY OrderDate) AS [Rank],
	 DENSE_RANK() OVER(ORDER BY OrderDate) AS DenseRank
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (11330, 29676);