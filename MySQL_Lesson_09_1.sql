--  “Транзакции, переменные, представления”


-- В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;

SELECT * FROM shop.users u WHERE u.id = 1;
INSERT INTO sample.users (name, birthday_at ) (SELECT u.name , u.birthday_at FROM shop.users u WHERE u.id = 1);
DELETE FROM shop.users u WHERE u.id = 1;

COMMIT;


-- Создайте представление, которое выводит название name товарной позиции из таблицы products и 
-- соответствующее название каталога name из таблицы catalogs.


CREATE VIEW goods AS 
	SELECT p.name as `name`, c.name as `catalog` 
		FROM products as p 
		LEFT JOIN catalogs as c 
		ON p.catalog_id = c.id ;
	

	
-- (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные 
-- записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который 
-- выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном 
-- таблице и 0, если она отсутствует.
	

INSERT INTO orders VALUES
(NULL, 3, TIMESTAMP('2018-08-01'), NOW()),
(NULL, 7, TIMESTAMP('2016-08-04'), NOW()),
(NULL, 1, TIMESTAMP('2018-08-16'), NOW()),
(NULL, 2, TIMESTAMP('2018-08-17'), NOW());


CREATE TEMPORARY TABLE days (`date` INT(2));
INSERT INTO days VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
						(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
						(21),(22),(23),(24),(25),(26),(27),(28),(29),(30),(31);

SELECT d.`date`, IF(o.id, 1, 0) 
	FROM days d 
	LEFT JOIN orders o 
		ON d.`date` = DAY(TIMESTAMP(o.created_at)) 
		AND o.created_at < TIMESTAMP('2018-09-01')
		AND o.created_at >= TIMESTAMP('2018-08-01');

	
-- (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет 
-- устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
	
CREATE TABLE IF NOT EXISTS orders_tmp SELECT * FROM orders o ;

DELETE FROM orders_tmp as t1
	 WHERE t1.id NOT IN (SELECT * FROM (SELECT id FROM orders_tmp ORDER BY created_at DESC LIMIT 5) as tmp);

SELECT * FROM orders_tmp;
	


