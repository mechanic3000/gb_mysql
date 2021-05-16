-- Составьте список пользователей users, которые осуществили 
-- хотя бы один заказ orders в интернет магазине.

SELECT u.name
	FROM users u 
	JOIN orders o 
	ON u.id = o.user_id 
GROUP BY u.id ;


-- Выведите список товаров products и разделов catalogs, который соответствует товару.

SELECT p.name , c.name 
	FROM products p 
	JOIN catalogs c 
	ON p.catalog_id = c.id ;
	

-- (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов 
-- cities (label, name). Поля from, to и label содержат английские названия городов, 
-- поле name — русское. Выведите список рейсов flights с русскими названиями городов.

SELECT c.name, c2.name
	FROM flights f 
	JOIN cities c
	JOIN cities c2
	ON f.`from` = c.lable AND f.`to` = c2.lable
	ORDER BY f.id;