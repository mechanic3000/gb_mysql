-- Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.

mysql> CREATE USER shop_read;
Query OK, 0 rows affected (0.00 sec)

mysql> CREATE USER shop;
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT ALL ON shop.* TO shop;
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT SELECT ON SHOP.* TO shop_read;
Query OK, 0 rows affected (0.01 sec)

mysql> SHOW GRANTS FOR shop\G;
*************************** 1. row ***************************
Grants for shop@%: GRANT USAGE ON *.* TO `shop`@`%`
*************************** 2. row ***************************
Grants for shop@%: GRANT ALL PRIVILEGES ON `shop`.* TO `shop`@`%`
2 rows in set (0.00 sec)

mysql> SHOW GRANTS FOR shop_read\G;
*************************** 1. row ***************************
Grants for shop_read@%: GRANT USAGE ON *.* TO `shop_read`@`%`
*************************** 2. row ***************************
Grants for shop_read@%: GRANT SELECT ON `SHOP`.* TO `shop_read`@`%`
2 rows in set (0.00 sec)


-- (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие 
-- первичный ключ, имя пользователя и его пароль. Создайте представление username таблицы accounts, 
-- предоставляющий доступ к столбца id и name. Создайте пользователя user_read, который бы не имел 
-- доступа к таблице accounts, однако, мог бы извлекать записи из представления username.


mysql> CREATE TABLE accounts(
    -> id INT unsigned NOT NULL AUTO_INCREMENT,
    -> name VARCHAR(255),
    -> `password` VARCHAR(255),
    -> PRIMARY KEY (`id`));
Query OK, 0 rows affected (0.15 sec)

mysql> CREATE VIEW username AS SELECT id, name FROM accounts;
Query OK, 0 rows affected (0.02 sec)

mysql> CREATE USER user_read;
Query OK, 0 rows affected (0.07 sec)

mysql> GRANT USAGE, SELECT ON shop.username TO user_read;
Query OK, 0 rows affected (0.02 sec)

mysql> exit

parallels@"PD_U":~$ mysql -u user_read -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 67
Server version: 8.0.23-0ubuntu0.20.04.1 (Ubuntu)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> USE shop;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> SELECT * FROM accounts;
ERROR 1142 (42000): SELECT command denied to user 'user_read'@'localhost' for table 'accounts'
mysql> SELECT * FROM username;
+----+------+
| id | name |
+----+------+
|  1 | Petr |
+----+------+
1 row in set (0.00 sec)

