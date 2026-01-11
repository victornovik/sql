CREATE TABLE [dbo].[Clients](
	[ClientId] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Age] [int] NULL,
 CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED ([ClientId] ASC)
)

CREATE TABLE [dbo].[Orders](
	[OrderId] [int] NOT NULL,
	[ClientId] [int] NULL,
	[Qty] [int] NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ([OrderId] ASC)
)
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Clients] FOREIGN KEY([ClientId])
REFERENCES [dbo].[Clients] ([ClientId])

CREATE TABLE [dbo].[Sales](
	[Country] [varchar](50) NULL,
	[Region] [varchar](50) NULL,
	[Sales] [int] NULL
)

-- Записи обо всех клиентах и заказах, не важно есть ли у клиентов заказы
select *
from Clients c left join Orders o
on c.ClientId = o.ClientId

-- Записи обо всех клиентах и заказах, не важно есть ли у заказов клиенты
select *
from Clients c right join Orders o
on c.ClientId = o.ClientId

-- Записи обо всех клиентах, у которых нет заказов
select *
from Clients c left join Orders o
on c.ClientId = o.ClientId
where o.ClientId is null

-- Записи только о тех клиентах и заказах, если у клиентов есть заказы
select *
from Clients c inner join Orders o
on c.ClientId = o.ClientId

-- Записи обо всех существующих клиентах и заказах
select *
from Clients c full outer join Orders o
on c.ClientId = o.ClientId

-- Записи о клиентах без заказов и заказах без клиентов
select *
from Clients c full outer join Orders o
on c.ClientId = o.ClientId
where c.ClientId is null or o.ClientId is null

-- Клиенты, у которых заказов больше 10
select c.Name, count(1) as Count
from Clients c inner join Orders o
on c.ClientId = o.ClientId
group by c.Name
having count(1) > 10

-- Проверка что все клиенты имеют уникальные имена
SELECT 'All client names are distinct' AS Result
FROM Clients c
HAVING COUNT(DISTINCT c.name) = COUNT(c.name);

-- Только клиенты с уникальными именами
SELECT c.Name
FROM Clients c
GROUP BY c.name
HAVING COUNT(DISTINCT c.name) = COUNT(c.name);

-- Только клиенты чьи имена повторяются
SELECT c.Name, count(c.Name) as Duplicates
FROM Clients c
GROUP BY c.name
HAVING COUNT(DISTINCT c.name) < COUNT(c.name);
-- или
select c.Name, count(c.Name) as Duplicates
from Clients c
group by c.Name
having count(c.Name) > 1


select *
from Clients c
where c.Name in (
	select Name
	from Clients
	group by Name
	having count(1) > 1)

select * from (
  select *, count(*) over (partition by Name) as names from Clients
) groups
where groups.names > 1


-- Returns 1 row
select 1 as foo
union
select 1 as foo

-- Returns 2 rows
select 1 as foo
union all
select 1 as foo

-- Reusing CTE
with cte as (select * from orders o where o.qty > 15)
select * 
from cte left join cte as c
on cte.ClientId = c.ClientId

-- Использование IN для поиска в множестве по нескольким значениям
CREATE TABLE users (userId int NOT NULL, depId int NOT NULL, salary int NOT NULL);
INSERT INTO users (userId, depId, salary) 
VALUES (1, 1, 100), (2, 1, 100), (3, 1, 300), (4, 2, 1), (5, 2, 2), (6, 3, 10), (7, 3, 5);

select * from users
where (salary, depId) in
(
	select min(salary) as salary, depId
	from users
	group by depId
)

/* 
TRUNCATE TABLE can be rolled back within a transaction in PostgreSQL and MS SQL, but TRUNCATE TABLE commits transaction in Oracle.
DELETE statement removes rows one at a time and records an entry in the transaction log for each deleted row. 
TRUNCATE TABLE removes the data by deallocating the data pages used to store the table data and records only the page deallocations in the transaction log.
*/
CREATE TABLE Books (
	id INT,
	name VARCHAR(50) NOT NULL,
	genre VARCHAR(50) NOT NULL,
	cost INT NOT NULL
);

INSERT INTO Books (id, name, genre, cost)
VALUES
(1, 'Book 1', 'Action', 1000),
(2, 'Book 2', 'Fantasy', 500),
(3, 'Book 3', 'Horror', 300);

BEGIN TRANSACTION;
TRUNCATE TABLE Books;
ROLLBACK;

select * from Books;


-- How to measure execution time of the SQL query
DECLARE @EndTime datetime
DECLARE @StartTime datetime 
SELECT @StartTime=GETDATE() 

-- Write Your Query

SELECT @EndTime=GETDATE()
--This will return execution time of your query
SELECT DATEDIFF(ms,@StartTime,@EndTime) AS [Duration in millisecs]

--------------------------------------------------------------------------

set statistics time on

-- Write Your Query in SSMS

set statistics time off

That will have the output looking something like this in your Messages window:

SQL Server Execution Times: CPU time = 7 ms, elapsed time = 7 ms.
--------------------------------------------------------------------------

sqllocaldb info
sqllocaldb info Test

sqlcmd -S (localDB)\Test



/*DROP TABLE [dbo].[Names];

CREATE TABLE [dbo].[Names](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [nvarchar](max) NOT NULL,
	[lastName] [nvarchar](max) NOT NULL,
CONSTRAINT [PK_Names] PRIMARY KEY CLUSTERED ([id] ASC));

INSERT INTO [dbo].[Names] (firstName, lastName)
VALUES ('Victor', 'Novik'), ('John', 'Smith')*/

-- Swap values between two rows
UPDATE Names
SET 
    firstName = CASE id
        WHEN 1 THEN (SELECT firstName FROM Names WHERE id = 2)
        WHEN 2 THEN (SELECT firstName FROM Names WHERE id = 1)
    END,
    lastName = CASE id
        WHEN 1 THEN (SELECT lastName FROM Names WHERE id = 2)
        WHEN 2 THEN (SELECT lastName FROM Names WHERE id = 1)
    END
WHERE id IN (1, 2);