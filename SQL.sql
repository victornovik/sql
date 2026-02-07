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

-- или
select *
from Clients c
where c.Name in (
	select Name
	from Clients
	group by Name
	having count(1) > 1)

-- или
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
--------------------------------------------------------------------------

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


-- У вас есть база данных, которая отслеживает проекты и сотрудников, назначенных на эти проекты. 
-- Вам необходимо проанализировать состав команд проектов, чтобы оценить средний уровень опыта.
-- Округлите значения average_years до 2 знаков после запятой.
SELECT project_id, ROUND(AVG(e.experience_years), 2) AS average_years
FROM project p INNER JOIN employee e
ON p.employee_id = e.employee_id
GROUP BY project_id


-- Найти пользователей, которые совершили заказы на товары из категории 'Electronics', с указанием общей суммы заказов по этой категории.
SELECT u.id AS user_id, u.name AS user_name, SUM(o.quantity * p.price) AS total_order_value
FROM users u 
INNER JOIN orders o on u.id = o.user_id
INNER JOIN products p on o.product_id = p.id
INNER JOIN categories c on p.category_id = c.id and c.name = 'Electronics'
GROUP BY u.id


-- Выведите список имён сотрудников, получающих большую заработную плату, чем у непосредственного руководителя
SELECT e.name AS name
FROM employees e INNER JOIN employees chiefs
ON e.chief_id = chiefs.id
WHERE e.salary > chiefs.salary


-- Выведите идентификаторы преподавателей, у которых есть хотя бы одно занятие в каждом одиннадцатом классе.
-- Всего 3 разных одиннадцатых класса
SELECT s.teacher AS teacher
FROM schedule s INNER JOIN class c ON s.class = c.id AND c.name LIKE '11%'
GROUP BY s.teacher
HAVING COUNT(DISTINCT c.id) = 3


-- Необходимо получить имена студентов и общую сумму стоимости всех курсов, которые они посещают, 
-- но только для тех студентов, у которых общая стоимость курсов превышает 10 000
SELECT s.name, SUM(c.price)
FROM students s 
INNER JOIN students_courses sc ON s.id = sc.student_id
INNER JOIN courses c ON sc.course_id = c.id
GROUP BY s.name
HAVING SUM(c.price) > 10000


-- Выведите для каждого пользователя первое наименование, которое он заказал (первое по времени транзакции).
-- Решение #1 через CTE
WITH earliest_ts AS (
    SELECT user_id, MIN(transaction_ts) AS min_ts
    FROM transactions t
    GROUP BY user_id
)
SELECT t.user_id, t.item
FROM transactions t
INNER JOIN earliest_ts ON t.user_id = earliest_ts.user_id AND t.transaction_ts = earliest_ts.min_ts


-- Решение #2 через оконку
SELECT 
    DISTINCT user_id,
    -- transaction_ts,
    -- item,
    FIRST_VALUE(item) OVER (partition by user_id ORDER BY transaction_ts ASC) item
FROM transactions t


-- Решение #3 через вложенный запрос
SELECT user_id, item
FROM transactions
WHERE transaction_ts IN (
		SELECT MIN(transaction_ts)
		FROM transactions
		GROUP BY user_id)


-- Вывести id тех пользователей, которые считаются ботами. 
-- Предполагается, что если кто-то зарегистрировался с email, который уже есть в базе, то это бот.
-- Т.е. реальный пользователь тот, кто первым зарегистрировался с данным email.
SELECT id
FROM
    (SELECT 
        id,
        email,
        row_number() OVER (partition by email order by id asc) as seq_num
    FROM users)
WHERE seq_num > 1


-- Напишите запрос, который выдаст последнюю цену каждой валюты.
-- Поля в результирующей таблице: name, price.
WITH latest_price AS (
    SELECT name, MAX(date) as latest_date
    FROM currency
    GROUP BY name
)
SELECT c.name, c.price
FROM currency c
INNER JOIN latest_price lp ON c.name = lp.name AND c.date = lp.latest_date


-- Дана таблица orders с информацией о заказах.
-- Необходимо получить список идентификаторов магазинов (shop_id), которые выполнили более 50 заказов за сентябрь.
SELECT shop_id
FROM orders
WHERE EXTRACT(MONTH FROM created_at) = 9
GROUP BY shop_id
HAVING COUNT(*) > 50


-- Выведите id сотрудников с разницей в заработной плате в пределах 5000 рублей.
SELECT lhs.id AS id1, rhs.id AS id2
FROM employees lhs, employees rhs
WHERE rhs.salary BETWEEN (lhs.salary - 5000) AND (lhs.salary + 5000)
AND lhs.id < rhs.id
ORDER BY lhs.id


-- Дано: две таблицы: region — справочник регионов. town — список городов.
-- Задача: Вывести список только тех регионов, в которых есть хотя бы один город, основанный до 1900 года (включительно), с указанием общего количества таких городов в каждом регионе.
-- Поля в результирующей таблице: title, old_towns_count.
SELECT r.title AS title, COUNT(t.title) AS old_towns_count
FROM region r INNER JOIN town t ON r.id = t.region_id AND t.year_ < 1901
GROUP BY r.title
ORDER BY old_towns_count DESC, title ASC


-- Дано: две таблицы: units — справочник подразделений компании. employees — список сотрудников.
-- Задача: Напишите SQL-запрос, который выведет минимальную и максимальную зарплату по каждому отделу, исключая уволенных сотрудников.
-- Поля в результирующей таблице: unit_id, min_salary, max_salary.
SELECT u.id AS unit_id, MIN(e.salary) AS min_salary, MAX(e.salary) AS max_salary
FROM units u INNER JOIN employees e ON u.id = e.unit_id AND e.fired = 0
GROUP BY u.id
ORDER BY u.id


-- Выведите уникальные комбинации пользователя и id товара для всех покупок, совершенных пользователями до того, как их забанили. 
-- Результат отсортируйте в порядке возрастания сначала по имени пользователя, потом по SKU.
-- Если пользователь не был забанен, учитываются все его покупки.
SELECT u.id AS user_id, u.first_name, u.last_name, p.sku
FROM users u 
LEFT JOIN ban_list b ON u.id = b.user_id
INNER JOIN purchases p ON u.id = p.user_id
WHERE b.date_from IS NULL OR b.date_from > p.date
ORDER BY u.first_name, p.sku


-- Есть две таблицы: 
-- таблица продаж (sales), в которой содержится информация о дате продажи, магазине, артикуле, который продали, и количестве проданных штук данного артикула
-- вторая таблица (prices) - справочник цен с информацией по ценам всех артикулов
-- Напишите запрос, который посчитает сумму продаж по магазину с shop = 100 за 1 января 2024 года.
-- Поля в результирующей таблице: total_revenue.
-- Количество проданных штук может быть отрицательным для возвратов.
SELECT SUM(s.quantity * p.price) as total_revenue
FROM sales s INNER JOIN prices p ON s.art = p.art AND s.shop = 100 AND s.datetime BETWEEN '2024-01-01 00:00:00' AND '2024-01-02 00:00:00'


-- Даны таблицы:
-- items - таблица истории цен.
-- orders - журнал транзакций.
-- Напишите запрос, который выведет актуальные цены товаров на 17 декабря 2025 года.
WITH latest_price AS (
    SELECT item_id, MAX(update_date) as latest_date
    FROM items
    WHERE update_date <= '2025-12-17'
    GROUP BY item_id
)
SELECT i.item_id, i.name, i.price, i.update_date
FROM items i
INNER JOIN latest_price lp ON i.item_id = lp.item_id AND i.update_date = lp.latest_date


-- Даны таблицы:
-- items - таблица истории цен.
-- orders - журнал транзакций.
-- Напишите запрос, который выведет сумму всех покупок до 1 февраля 2026 г. включительно.
SELECT SUM(i.price) AS total_sales
FROM items i INNER JOIN orders o ON i.item_id = o.item_id AND o.order_date <= '2026-02-01'
WHERE (i.item_id, i.update_date) IN (
    SELECT item_id, MAX(update_date)
    FROM items 
    WHERE update_date <= o.order_date
    GROUP BY item_id
)

-- Решение #2 через CTE и оконки
with prices as (
   select *
   from orders o
   join items i on o.item_id = i.item_id and o.order_date >= i.update_date
   where o.order_date <= '2026-02-01'
),
ordered as (
  select *, row_number() over(partition by order_id order by update_date desc) as rnum from prices
)
select sum(price) as total_sales from ordered where rnum = 1


-- Какой средний возраст клиентов, купивших Smartwatch (использовать наименование товара products.name) в 2024 году?
-- Поля в результирующей таблице: average_age﻿﻿﻿
WITH unique_users AS (
    SELECT DISTINCT ON (c.name) c.name, c.age
    FROM customers c 
    INNER JOIN purchases pu ON c.customer_key = pu.customer_key AND EXTRACT(YEAR FROM pu.date) = 2024
    INNER JOIN products pr ON pu.product_key = pr.product_key AND pr.name = 'Smartwatch'
)
SELECT AVG(u.age) average_age
FROM unique_users u

-- Решение #2
select avg(age) as average_age from customers where customer_key in (
    select customer_key from purchases pur
    join products prod on prod.product_key = pur.product_key
    where prod.name = 'Smartwatch' and date_part('year', pur.date) = 2024
)


-- Необходимо написать SQL-запрос, который найдет в таблице purchases транзакции, продублированные в результате технической ошибки.
SELECT *
FROM purchases p
WHERE (p.datetime, p.amount, p.user_id) IN
(
    SELECT p.datetime, p.amount, p.user_id
    FROM purchases p
    GROUP BY p.datetime, p.amount, p.user_id
    HAVING COUNT(*) > 1
)


-- Напишите SQL-запрос, который определит самый часто используемый промокод.
-- Необходимо вывести название этого промокода и количество раз, которое он был использован в заказах.
SELECT p.name, COUNT(*) as usage_count
FROM orders o INNER JOIN promocodes p ON o.promocode_id = p.promocode_id
GROUP BY p.name
ORDER BY usage_count DESC
LIMIT 1


-- Напишите SQL-запрос, который выведет уникальные имена пользователей, которые покупали товары из категории Книги, 
-- но при этом никогда не покупали товары из категории Одежда.
WITH subtraction AS (
    SELECT p.user_id
    FROM purchases p
    WHERE p.item = 'Книги'
    EXCEPT
    SELECT p.user_id
    FROM purchases p
    WHERE p.item = 'Одежда')
SELECT u.name
FROM users u
WHERE u.user_id IN (SELECT user_id FROM subtraction)

-- Решение #2
with results as (
    select u.name, p.item from users u
    join purchases p on p.user_id = u.user_id
)
select name from results where item = 'Книги'
except
select name from results where item = 'Одежда'


-- Найдите страну, в которой используется наибольшее количество различных языков, и выведите её название.
SELECT c.name
FROM countries c INNER JOIN country_languages l ON c.code = l.country_code
GROUP BY c.name
ORDER BY COUNT(DISTINCT l.language) DESC
LIMIT 1


-- Дана таблица clickstream со следующими полями:
-- sid_long — идентификатор устройства;
-- user_id — идентификатор пользователя;
-- action — действие.
-- Напишите SQL-запрос, который вернёт все уникальные пары (sid_long, user_id), удовлетворяющие условиям:
-- 		исключить все sid_long, у которых встречаются две и более различных user_id.
--		исключить все user_id, у которых в таблице обнаруживается более 7 уникальных sid_long.
WITH less_than_two_users AS (
    SELECT sid_long
    FROM clickstream
    GROUP BY sid_long
    HAVING COUNT(DISTINCT user_id) < 2
), less_than_eight_sids AS (
    SELECT user_id
    FROM clickstream
    GROUP BY user_id
    HAVING COUNT(DISTINCT sid_long) < 8
)
SELECT DISTINCT c.sid_long, c.user_id
FROM clickstream c 
INNER JOIN less_than_two_users u ON c.sid_long = u.sid_long
INNER JOIN less_than_eight_sids s ON c.user_id = s.user_id
ORDER BY c.sid_long, c.user_id


-- У компании по доставке еды есть таблица deliveries заказов пеших курьеров. 
-- В конце каждого месяца компания выдает премию для своих курьеров, средняя скорость доставки за прошедший месяц которых больше средней скорости среди всех курьеров. 
-- Необходимо узнать сколько курьеров получили премию за июль 2024.
-- Важно! Средняя скорость рассчитывается как суммарное расстояние за период делить на суммарное время доставок.
WITH avg_velocity_for_july AS (
    SELECT SUM(distance) / SUM(travel_time) AS avg_vel
    FROM deliveries d
    WHERE date_part('year', d.date) = 2024 AND date_part('month', d.date) = 7
    GROUP BY courier_id
), best_courier_ids AS (
    SELECT courier_id
    FROM deliveries d
    WHERE date_part('year', d.date) = 2024 AND date_part('month', d.date) = 7
    GROUP BY courier_id
    HAVING SUM(distance) / SUM(travel_time) > (SELECT AVG(avg_vel) FROM avg_velocity_for_july)
)
SELECT COUNT(courier_id) AS rewarded_couriers
FROM best_courier_ids


-- Постройте запрос, чтобы вычислить 5 авторов с самым большим количеством всех их проданных книг.
-- Поля в результирующей таблице: author_id, author_name, total_books_sold.
SELECT a.author_id, a.author_name, SUM(b.book_sold) AS total_books_sold
FROM authors a 
INNER JOIN books_authors ba ON a.author_id = ba.author_id
INNER JOIN books b ON ba.book_id = b.book_id
GROUP BY a.author_id, a.author_name
ORDER BY total_books_sold DESC
LIMIT 5


-- Даны таблицы с параметрами объявлений (адрес и цена) с историчностью в какое время, какой адрес и какая цена были актуальны.
-- Необходимо вывести актуальные адрес и цену для каждого объявления.
WITH last_address AS (
    SELECT DISTINCT ON (item_id) item_id, address
    FROM s_item_address
    ORDER BY item_id ASC, actual_date DESC
), last_price AS (
    SELECT DISTINCT ON (item_id) item_id, price
    FROM s_item_price
    ORDER BY item_id ASC, actual_date DESC
)
SELECT la.item_id, la.address, lp.price
FROM last_address la INNER JOIN last_price lp ON la.item_id = lp.item_id


-- Решение #2 через оконные функции
with addresses as (
  select item_id, address, row_number() over(PARTITION BY item_id order by actual_date desc) as rnum
  from s_item_address
),
prices as (
  select item_id, price, row_number() over(PARTITION BY item_id order by actual_date desc) as rnum
  from s_item_price
),
actual_addresses as (
  select item_id, address from addresses where rnum = 1    
),
actual_prices as (
  select item_id, price from prices where rnum = 1    
)
select a.item_id, address, price from actual_addresses a join actual_prices p on a.item_id = p.item_id

-- Решение #3 через МАХ
with actual_addresses as (
  select item_id, address from s_item_address
  where (item_id, actual_date) in (select item_id, max(actual_date) from s_item_address group by item_id)
),
actual_prices as (
  select item_id, price from s_item_price
  where (item_id, actual_date) in (select item_id, max(actual_date) from s_item_price group by item_id)
)
select a.item_id, address, price from actual_addresses a join actual_prices p on a.item_id = p.item_id

-- Решение #4
with actual_addresses as (
  select item_id, address from s_item_address addr
  where not exists (select 1 from s_item_address t where t.item_id = addr.item_id and t.actual_date > addr.actual_date)
),
actual_prices as (
  select item_id, price from s_item_price pr
  where not exists (select 1 from s_item_price t where t.item_id = pr.item_id and t.actual_date > pr.actual_date)
)
select a.item_id, address, price from actual_addresses a join actual_prices p on a.item_id = p.item_id


-- Classic GROUP BY
SELECT region, product, SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY region, product;

-- Groups with subtotals and totals
SELECT region, product, SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY ROLLUP(region, product);

-- Groups for all combinations of Country and Region
SELECT region, product, SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY CUBE (region, product);

-- Returns the union of the ROLLUP and CUBE 
SELECT region, product, SUM(sales_amount) AS total_sales
FROM sales_data
GROUP BY GROUPING SETS (ROLLUP (region, product), CUBE (region, product));

CREATE TABLE sales (
    region VARCHAR(50),
    product VARCHAR(50),
    sales_amount NUMERIC
);

INSERT INTO sales_data (region, product, sales_amount) VALUES
('North', 'Product A', 100),
('North', 'Product A', 120),
('North', 'Product B', 150),
('North', 'Product B', 250),
('South', 'Product A', 120),
('South', 'Product B', 180),
('South', 'Product B', 120),
('East', 'Product A', 90),
('East', 'Product B', 130),
('West', 'Product A', 110),
('West', 'Product A', 190),
('West', 'Product B', 160);


-- Дана таблица subscriptions с историей всех подписочных периодов для каждого клиента.
-- Напишите SQL-запрос, который преобразует историю подписок в хронологический список событий.
-- Пример исходных данных:
| customer_id | membership_start_date | membership_end_date | membership_status |
|-------------|-----------------------|---------------------|-------------------|
| 115         | 2020-01-01            | 2020-02-15          | Free              |
| 115         | 2020-02-15            | 2020-03-15          | Paid              |
| 115         | 2020-03-15            | 2020-04-01          | Non-member        |
| 115         | 2020-04-01            | 2020-10-01          | Paid              |

-- Основные правила переходов:
Free → Paid: 'Convert'
Paid → Free: 'ReverseConvert'
Paid → Non-member: 'Cancel'
Free → Non-member: 'Cancel'
Non-member → Paid: 'ColdStart'
Non-member → Free: 'WarmStart'
Paid → Paid: 'Renewal'
Free → Free: 'Renewal'

-- Пример результата:
| customer_id | change_date | event      |
|-------------|-------------|------------|
| 115         | 2020-01-01  | WarmStart  |
| 115         | 2020-02-15  | Convert    |
| 115         | 2020-03-15  | Cancel     |
| 115         | 2020-04-01  | ColdStart  |
| 115         | 2020-10-01  | Cancel     |

-- Поля в результирующей таблице: customer_id, change_date, event.
WITH transitions AS (
    SELECT 'Free' AS src, 'Paid' AS dst, 'Convert' AS event
    UNION
    SELECT 'Paid', 'Free', 'ReverseConvert'
    UNION 
    SELECT 'Paid', 'Non-member', 'Cancel'
    UNION 
    SELECT 'Free', 'Non-member', 'Cancel'
    UNION 
    SELECT 'Non-member', 'Paid', 'ColdStart'
    UNION 
    SELECT 'Non-member', 'Free', 'WarmStart'
    UNION 
    SELECT 'Non-member', 'Non-member', 'Non-member'
    UNION 
    SELECT 'Paid', 'Paid', 'Renewal'
    UNION 
    SELECT 'Free', 'Free', 'Renewal' 
)
SELECT COALESCE(s1.customer_id, s2.customer_id) customer_id, COALESCE(s1.membership_end_date, s2.membership_start_date) change_date, t.event 
FROM subscriptions s1
FULL OUTER JOIN subscriptions s2 ON s1.customer_id = s2.customer_id AND s1.membership_end_date = s2.membership_start_date
INNER JOIN transitions t ON COALESCE(s1.membership_status, 'Non-member') = t.src AND COALESCE(s2.membership_status, 'Non-member') = t.dst
WHERE event != 'Non-member'
ORDER BY customer_id, change_date;

--SELECT * 
--FROM subscriptions s1
--ORDER BY s1.customer_id, s1.membership_start_date;


-- Решение #2 через оконку LAG()
with subscriptions_ex as (
  select *, row_number() over(partition by customer_id order by membership_end_date desc) as rnum from subscriptions
), history as (
    select *,
    coalesce(lag(membership_status) over(partition by customer_id order by membership_start_date), 'Non-member') as prev_status
    from subscriptions
    UNION ALL
    select customer_id, membership_end_date as membership_start_date, null as membership_end_date, 'Non-member' as membership_status,
    membership_status as prev_status
    from subscriptions_ex
    where rnum = 1
), events as (
  select customer_id, membership_start_date as change_date,-- prev_status, membership_status,
  case
    when prev_status = 'Free' and membership_status = 'Paid' then 'Convert'
    when prev_status = 'Paid' and membership_status = 'Free' then 'ReverseConvert'
    when prev_status = 'Paid' and membership_status = 'Non-member' then 'Cancel'
    when prev_status = 'Free' and membership_status = 'Non-member' then 'Cancel'
    when prev_status = 'Non-member' and membership_status = 'Paid' then 'ColdStart'
    when prev_status = 'Non-member' and membership_status = 'Free' then 'WarmStart'
    when prev_status = 'Paid' and membership_status = 'Paid' then 'Renewal'
    when prev_status = 'Free' and membership_status = 'Free' then 'Renewal'
  else null end as event    
  from history
)
select * from events
where event is not null
order by customer_id, change_date


-- CORRELATED SUBQUERIES


-- Вывести в порядке убывания популярности доменные имена, используемые пользователями для электронной почты. 
-- Полученный результат необходимо дополнительно отсортировать по возрастанию названий доменных имён.
SELECT SUBSTRING (email, STRPOS(email, '@') + 1) AS domain, COUNT(*) AS count
FROM users
GROUP BY domain
ORDER BY count DESC, domain ASC


-- Найдите отделы, совокупная заработная плата сотрудников которых является максимальной.
WITH max_salary AS (
    SELECT SUM(salary) AS salary
    FROM employees
    GROUP BY department_id
    ORDER BY salary DESC
    LIMIT 1
)
SELECT department_id
FROM employees
GROUP BY department_id
HAVING SUM(salary) IN (SELECT salary FROM max_salary)


-- Есть таблица products с товарами и их значениями на определенную дату.
-- Оказалось, что начиная с какой-то даты по некоторым товарам начали приходить пустые значения.
-- Нужно написать запрос, в котором все NULL в поле value будут заполнены последним известным значением value для данного товара (при отсутствии предыдущих значений поле остается NULL).
WITH cte AS (
    SELECT sku, date, value,
       COUNT(value) OVER (PARTITION BY sku ORDER BY date) AS last_not_null_seq
    FROM products
)
SELECT sku, date, 
    FIRST_VALUE(value) OVER (PARTITION BY sku, last_not_null_seq ORDER BY date) AS filled_value
FROM cte
ORDER BY sku, date;

-- Решение #2
with ordered as (
  select *, row_number() over(PARTITION BY sku order by date desc) as rnum from products
  where value is not null
)
select p.sku, p.date, coalesce(p.value, v.value) as filled_value from products p
left join ordered v on p.sku = v.sku and v.rnum = 1
order by sku, date



-- Дана таблица user_logs с данными о действиях пользователей.
-- Необходимо для каждого пользователя выбрать последнюю запись по полю dttm.
WITH last_action AS (
    SELECT user_id, MAX(dttm) max_dttm
    FROM user_logs
    GROUP BY user_id
)
SELECT DISTINCT ul.user_id, ul.dttm, ul.action
FROM user_logs ul INNER JOIN last_action la ON ul.user_id = la.user_id AND ul.dttm = la.max_dttm
ORDER BY ul.user_id


-- Даны таблицы:
-- calls - Звонки клиентов.
-- orders - Заказы.
-- goods - Справочник товаров.
-- order_goods - Позиции заказов.
-- Необходимо вывести топ-5 брендов по выручке в январе 2025 года.
SELECT g.brand, g.category, SUM(og.good_price) AS revenue
FROM orders o 
INNER JOIN order_goods og ON o.id = og.order_id AND date_part('year', o.order_created_at) = 2025 AND date_part('month', o.order_created_at) = 1
INNER JOIN goods g ON og.good_id = g.good_id
GROUP BY g.brand, g.category
ORDER BY revenue DESC
LIMIT 5


-- Вывести идентификаторы всех владельцев комнат, что размещены на сервисе бронирования жилья и сумму, которую они заработали. 
-- Если заработок отсутствует, то в результирующей таблице должно быть 0.
SELECT rooms.owner_id, SUM(COALESCE(reservations.total, 0)) AS total_earn
FROM rooms LEFT JOIN reservations ON rooms.id = reservations.room_id
GROUP BY rooms.owner_id
ORDER BY owner_id


-- Напишите SQL-запрос, который выводит уникальный список всех продуктов и их семейств, проданных в каждой стране за первые 10 недель 2020 года.
SELECT DISTINCT p.country, p.product_name, p.product_family
FROM products p INNER JOIN boxes_shipped b ON p.product_id = b.fk_product_id
AND b.delivery_week BETWEEN '2020-W01' AND '2020-W10'
ORDER BY p.country, p.product_name