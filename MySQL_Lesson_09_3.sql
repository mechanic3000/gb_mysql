-- “Хранимые процедуры и функции, триггеры"


-- Создайте хранимую функцию hello(), которая будет возвращать 
-- приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция 
-- должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать 
-- фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".


DELIMITER //
DROP FUNCTION IF EXISTS hello //

CREATE FUNCTION hello()
RETURNS VARCHAR(255) NO SQL
BEGIN
	DECLARE cur_time DATETIME;
	SET cur_time = NOW();
	
	IF (STR_TO_DATE("06:00", "%H:%i") <= cur_time and cur_time < STR_TO_DATE("12:00", "%H:%i")) THEN 
		RETURN "Доброе утро!";
	
	ELSEIF (STR_TO_DATE("12:00", "%H:%i") <= cur_time and cur_time < STR_TO_DATE("18:00", "%H:%i")) THEN 
		RETURN "Добрый день!";
	
	ELSEIF (STR_TO_DATE("18:00", "%H:%i") <= cur_time and cur_time < STR_TO_DATE("00:00", "%H:%i")) THEN 
		RETURN "Добрый вечер!";
	
	ELSE  
		RETURN "Доброй ночи!";
	
	END IF;
END//

DELIMITER ;


SELECT hello();



-- В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное 
-- значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были 
-- аполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.


DELIMITER // 

CREATE TRIGGER tg_products_name BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Имя и описание не могут быть пустыми";
	END IF;
END // 

DELIMITER ;

INSERT INTO products (name, description, price) VALUES ('Товар 1', NULL, 500);
INSERT INTO products (name, description, price) VALUES (NULL, 'Очень удобные грабли', 200);
INSERT INTO products (name, description, price) VALUES (NULL, NULL, 1000);

SELECT * FROM products p ;

DELIMITER // 

CREATE TRIGGER tg_products_name BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	IF NEW.name IS NULL AND NEW.description IS NULL THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Имя и описание не могут быть пустыми";
	END IF;
END // 


-- (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.


DELIMITER //

DROP PROCEDURE IF EXISTS fibonacci //

CREATE PROCEDURE fibonacci (IN pos INT)
BEGIN
	DECLARE num_1, num_2 INT DEFAULT 1;
	DECLARE num_3, i INT DEFAULT 0;
	SET num_2 = 1;
	IF (pos > 0 ) THEN
		WHILE i < pos-2 DO
			SET num_3 = num_1 + num_2;
			SET num_1 = num_2;
			SET num_2 = num_3;
			SET i = i + 1;
		END WHILE;
		SELECT num_3 as `result`;
	ELSE
		SELECT 0 as `result`;
	END IF;
END //

DELIMITER ;

CALL fibonacci(10);
