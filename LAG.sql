--1-1.1 Using a correlated subquery
SELECT TickerSymbol, TradeDate, ClosePrice,
	(SELECT TOP(1) ClosePrice
	FROM StockHistory AS innerSH
	WHERE innerSH.TickerSymbol = outerSH.TickerSymbol AND innerSH.TradeDate < outerSH.TradeDate
	ORDER BY TradeDate DESC) AS PrevClosePrice
FROM StockHistory AS outerSH
ORDER BY TickerSymbol, TradeDate;


--1-1.2 Using LAG
SELECT TickerSymbol, TradeDate, ClosePrice,
	LAG(ClosePrice) OVER(PARTITION BY TickerSymbol ORDER BY TradeDate) AS PrevClosePrice
FROM StockHistory
ORDER BY TickerSymbol, TradeDate;


SELECT TickerSymbol, TradeDate, ClosePrice,
	COUNT(ClosePrice) OVER() AS Rows
FROM StockHistory
ORDER BY TickerSymbol, TradeDate;

SELECT @@VERSION;