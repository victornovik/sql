-- Using PERCENT_RANK and CUME_DIST
-- PERCENT_RANK =  (Rank-1)/(N-1). PERCENT_RANK = 94% means it is higher than 94% and is higher than or the same as 95%
-- CUME_DIST = Rank/N
SELECT COUNT(*) NumberOfOrders, Month(OrderDate) AS OrderMonth,
    RANK() OVER(ORDER BY COUNT(*)) AS Rank,
    PERCENT_RANK() OVER(ORDER BY COUNT(*)) AS PercentRank,
    CUME_DIST() OVER(ORDER BY COUNT(*)) AS CumeDist
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01'
GROUP BY Month(OrderDate);


-- The same query as above using plain old RANK()
SELECT COUNT(*) NumberOfOrders, Month(OrderDate) AS OrderMonth,
    ((RANK() OVER(ORDER BY COUNT(*)) - 1) * 1.0) / (COUNT(*) OVER() - 1) AS PercentRank,
    (RANK() OVER(ORDER BY COUNT(*)) * 1.0) / COUNT(*) OVER() AS CumeDist
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01'
GROUP BY  Month(OrderDate);