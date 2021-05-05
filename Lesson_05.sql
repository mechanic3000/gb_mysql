-- 1

-- Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
-- Заполните их текущими датой и временем.

UPDATE users u SET u.created_at = NOW(), u.updated_at = NOW();

-- ----------------

-- Таблица users была неудачно спроектирована. Записи created_at и updated_at были з
-- аданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.

UPDATE users u SET 
	u.created_at = STR_TO_DATE(u.created_at, '%d.%m.%Y %h:%i'), 
	u.updated_at = STR_TO_DATE(u.updated_at, '%d.%m.%Y %h:%i');

ALTER TABLE users MODIFY created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users MODIFY updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- ----------------

-- В таблице складских запасов storehouses_products в поле value могут встречаться 
-- самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. 
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения 
-- значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.

SELECT * FROM storehouses_products sp ORDER BY sp.value = 0, sp.value ;

-- ----------------

-- (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий (may, august)

SELECT u.name FROM users u WHERE LOWER(MONTHNAME(u.birthday_at)) IN ("may", "august");


-- (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.

SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY id = 2, id = 1, id = 5; 


-- 2

-- Подсчитайте средний возраст пользователей в таблице users.

SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, u.birthday_at, NOW())),0) as avg_old FROM users u ;


-- Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.


SELECT DATE_FORMAT(DATE_FORMAT(u.birthday_at, CONCAT('%d.%m.', YEAR(NOW()))), '%W') as day_of_week 
		, COUNT(*) as count
	FROM users u 
GROUP BY day_of_week;



-- (по желанию) Подсчитайте произведение чисел в столбце таблицы.

CREATE TEMPORARY TABLE numbers (
	value INT(10));

INSERT INTO numbers (value) VALUES (1),(2),(3),(4);

SELECT EXP((SUM(LN(value)))) FROM numbers;