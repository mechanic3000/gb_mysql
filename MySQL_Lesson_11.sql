-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в 
-- таблицах users, catalogs и products в таблицу logs помещается время и 
-- дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.


CREATE TABLE logs (
	id INT(10) unsigned NOT NULL AUTO_INCREMENT,
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	table_name VARCHAR(255),
	row_id INT(10) unsigned,
	row_name VARCHAR(255),
	UNIQUE KEY (`id`)
) ENGINE=Archive DEFAULT CHARSET=utf8mb4;


DELIMITER // 

DROP TRIGGER IF EXISTS tg_user_insert// 
CREATE TRIGGER tg_user_insert
	AFTER INSERT
	ON users FOR EACH ROW
		BEGIN
			INSERT INTO logs (table_name, row_id, row_name) 
				VALUES ('users', NEW.id, NEW.name);
		END//
		
DROP TRIGGER IF EXISTS tg_catalogs_insert// 
CREATE TRIGGER tg_catalogs_insert
	AFTER INSERT
	ON catalogs FOR EACH ROW
		BEGIN
			INSERT INTO logs (table_name, row_id, row_name) 
				VALUES ('catalogs', NEW.id, NEW.name);
		END//
		
DROP TRIGGER IF EXISTS tg_products_insert// 
CREATE TRIGGER tg_products_insert
	AFTER INSERT
	ON products FOR EACH ROW
		BEGIN
			INSERT INTO logs (table_name, row_id, row_name) 
				VALUES ('products', NEW.id, NEW.name);
		END//

DELIMITER ;
		

INSERT INTO users (name, birthday_at) VALUE ('Егор', DATE_FORMAT('1983-10-13', '%Y-%m-%d'));
INSERT INTO catalogs (name) VALUE ('Кабели');
INSERT INTO products (name, catalog_id) VALUE ('Кабель USB', 6);

select * from logs l;




-- (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

DELIMITER //
DROP PROCEDURE IF EXISTS one_billion_users // 
CREATE PROCEDURE one_billion_users ()
BEGIN
	DECLARE i INT DEFAULT 0;
	
	WHILE i < 1000000 DO
		INSERT INTO users (name, birthday_at) 
		VALUES (CONCAT(substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), 
						substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), 
						substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1)), 
				CURRENT_DATE - INTERVAL FLOOR(RAND() * 36500) DAY);
		SET i = i + 1;
	END WHILE;
END//
	
	
CALL one_billion_users //

DELIMITER ;

SELECT COUNT(*) FROM users;