-- Using RANK and DENSE_RANK
-- RANK says how many rows before the current one
-- DENSE_RANK says how many different values come before the current value. 
-- Another way to think about this is that DENSE_RANK doesn’t waste any numbers, while RANK skips numbers
SELECT CustomerID, OrderDate,
	 ROW_NUMBER() OVER(ORDER BY OrderDate) AS RowNumber,
	 RANK() OVER(ORDER BY OrderDate) AS [Rank],
	 DENSE_RANK() OVER(ORDER BY OrderDate) AS DenseRank
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (11330, 29676);


-- Finding Islands and Gaps between them
CREATE TABLE #Islands(ID INT NOT NULL);
INSERT INTO #Islands(ID) VALUES(101),(102),(103),(106),(108),(108),(109),(110),(111),(112),(112), (114),(115),(118),(119);
SELECT ID FROM #Islands;

-- Subtract the RowNum from the ID
SELECT ID, ROW_NUMBER() OVER(ORDER BY ID) AS RowNum,
 ID - ROW_NUMBER() OVER(ORDER BY ID) AS Diff
FROM #Islands;

-- Use DENSE_RANK since there are duplicate IDs
SELECT ID, DENSE_RANK() OVER(ORDER BY ID) AS DenseRank, ID - DENSE_RANK() OVER(ORDER BY ID) AS Diff
FROM #Islands;

-- The complete Islands solution
-- All islands have the same Diff
WITH Islands AS 
(
	SELECT ID, DENSE_RANK() OVER(ORDER BY ID) AS DenseRank, ID - DENSE_RANK() OVER(ORDER BY ID) AS Diff
	FROM #Islands)
SELECT MIN(ID) AS IslandStart, MAX(ID) AS IslandEnd
FROM Islands
GROUP BY Diff;