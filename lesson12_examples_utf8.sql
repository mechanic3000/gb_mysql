-- Урок 12
-- Оптимизация запросов

-- Разбор ДЗ
-- Задания на БД vk:

-- 1. Проанализировать какие запросы могут выполняться наиболее часто в
-- процессе работы приложения и добавить необходимые индексы.

-- 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах 
-- (общее количество пользователей в группе /  всего пользователей в системе) * 100

-- Вопрос 
-- Что выполняется быстрее обычные запросы или оконные ф-и? 

-- Вариант с вложенными запросами в части SELECT
SELECT DISTINCT 
  communities.name AS group_name,
  COUNT(communities_users.user_id) OVER() 
    / (SELECT COUNT(*) FROM communities) AS avg_users_in_groups,
  FIRST_VALUE(CONCAT_WS(" ", users.first_name, users.last_name)) 
    OVER (w_community ORDER BY profiles.birthday DESC) AS youngest,
  FIRST_VALUE(CONCAT_WS(" ", users.first_name, users.last_name)) 
    OVER (w_community ORDER BY profiles.birthday ASC) AS oldest,
  COUNT(communities_users.user_id) OVER w_community AS users_in_group,
  (SELECT COUNT(*) FROM users) AS users_total,
  COUNT(communities_users.user_id) OVER w_community / (SELECT COUNT(*) FROM users) *100 AS '%%'
    FROM communities
      LEFT JOIN communities_users 
        ON communities_users.community_id = communities.id
      LEFT JOIN users 
        ON communities_users.user_id = users.id
      LEFT JOIN profiles 
        ON profiles.user_id = users.id
      WINDOW w_community AS (PARTITION BY communities.id);    
                              
             
-- Вариант с вложенными запросами в объединении JOIN
SELECT DISTINCT 
  communities.name AS group_name,
  COUNT(communities_users.user_id) OVER() / total_communities AS avg_users_in_groups,
  FIRST_VALUE(CONCAT_WS(" ", users.first_name, users.last_name)) 
    OVER (w_community ORDER BY profiles.birthday DESC) AS youngest,
  FIRST_VALUE(CONCAT_WS(" ", users.first_name, users.last_name)) 
    OVER (w_community ORDER BY profiles.birthday ASC) AS oldest,
  COUNT(communities_users.user_id) OVER w_community AS users_in_group,
  total_users,
  COUNT(communities_users.user_id) OVER w_community / total_communities * 100 AS '%%'
    FROM 
        (SELECT COUNT(*) AS total_users FROM users) AS tu
  	  CROSS JOIN 
  	    (SELECT COUNT(*) AS total_communities FROM communities) AS tc
  	  CROSS JOIN communities
      LEFT JOIN communities_users 
        ON communities_users.community_id = communities.id
      LEFT JOIN users 
        ON communities_users.user_id = users.id
      LEFT JOIN profiles 
        ON profiles.user_id = users.id
      WINDOW w_community AS (PARTITION BY communities.id); 

-- Практическое задание тема "Оптимизация запросов"
-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users,
-- catalogs и products в таблицу logs помещается время и дата создания записи, название
-- таблицы, идентификатор первичного ключа и содержимое поля name.

CREATE TABLE Logs (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    created_at datetime DEFAULT CURRENT_TIMESTAMP,
    table_name varchar(50) NOT NULL,
    row_id INT UNSIGNED NOT NULL,
    row_name varchar(255)
) ENGINE = Archive;

CREATE TRIGGER products_insert AFTER INSERT ON products
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "products", NEW.id, NEW.name);
END;

CREATE TRIGGER users_insert AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "users", NEW.id, NEW.name);
END;

CREATE TRIGGER catalogs_insert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
    INSERT INTO Logs VALUES (NULL, DEFAULT, "catalogs", NEW.id, NEW.name);
END;

-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
CREATE TABLE samples (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO samples (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29'),
  ('Аркадий', '1994-03-17'),
  ('Ольга', '1981-07-10'),
  ('Владимир', '1988-06-12'),
  ('Екатерина', '1992-09-20');

SELECT
  COUNT(*)
FROM
  samples AS fst,
  samples AS snd,
  samples AS thd,
  samples AS fth,
  samples AS fif,
  samples AS sth;

SELECT COUNT(*) FROM users;

SELECT * FROM users LIMIT 10;


-- Практическое задание тема "NoSQL"
-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.
HINCRBY addresses '127.0.0.1' 1
HGETALL addresses

HINCRBY addresses '127.0.0.2' 1
HGETALL addresses

HGET addresses '127.0.0.1'

-- 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному
-- адресу и наоборот, поиск электронного адреса пользователя по его имени.
HSET emails 'igor' 'igorsimdyanov@gmail.com'
HSET emails 'sergey' 'sergey@gmail.com'
HSET emails 'olga' 'olga@mail.ru'

HGET emails 'igor'

HSET users 'igorsimdyanov@gmail.com' 'igor'
HSET users 'sergey@gmail.com' 'sergey'
HSET users 'olga@mail.ru' 'olga'

HGET users 'olga@mail.ru'

-- 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.
-- Предлагаемый вариант

show dbs

use shop

db.createCollection('catalogs')
db.createCollection('products')

db.catalogs.insert({name: 'Процессоры'})
db.catalogs.insert({name: 'Мат.платы'})
db.catalogs.insert({name: 'Видеокарты'})

db.products.insert(
  {
    name: 'Intel Core i3-8100',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 7890.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'Intel Core i5-7400',
    description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.',
    price: 12700.00,
    catalog_id: new ObjectId("5b56c73f88f700498cbdc56b")
  }
);

db.products.insert(
  {
    name: 'ASUS ROG MAXIMUS X HERO',
    description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX',
    price: 19310.00,
    catalog_id: new ObjectId("5b56c74788f700498cbdc56c")
  }
);

db.products.find()

db.products.find({catalog_id: ObjectId("5b56c73f88f700498cbdc56bdb")})


-- Примеры оптимизации

-- Синтаксис EXPLAIN http://www.mysql.ru/docs/man/EXPLAIN.html
-- Определить активность пользователя
SELECT CONCAT(first_name, ' ', last_name) AS user_name,
  COUNT(DISTINCT messages.id) + 
  COUNT(DISTINCT likes.id) + 
  COUNT(DISTINCT media.id) AS activity 
  FROM users
    LEFT JOIN messages 
      ON users.id = messages.from_user_id
    LEFT JOIN likes
      ON users.id = likes.user_id
    LEFT JOIN media
      ON users.id = media.user_id
  WHERE first_name = "Lillian" AND last_name = "Stracke";
  
-- Применяем EXPLAIN
EXPLAIN SELECT CONCAT(first_name, ' ', last_name) AS user_name,
  COUNT(DISTINCT messages.id) + 
  COUNT(DISTINCT likes.id) + 
  COUNT(DISTINCT media.id) AS activity 
  FROM users
    LEFT JOIN messages 
      ON users.id = messages.from_user_id
    LEFT JOIN likes
      ON users.id = likes.user_id
    LEFT JOIN media
      ON users.id = media.user_id
  WHERE first_name = "Lillian" AND last_name = "Stracke";
  
-- Создаём индексы		
CREATE INDEX users_first_name_last_name_idx 
  ON users(first_name, last_name);  
		
-- Создаём внешние ключи
ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id);

ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id);		
    
ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id);
    
-- Удаляем если нужно внешние ключи и индексы  
ALTER TABLE likes DROP FOREIGN KEY likes_user_id_fk; 
ALTER TABLE likes DROP INDEX likes_user_id_fk;
  
ALTER TABLE media DROP FOREIGN KEY media_user_id_fk; 
ALTER TABLE media DROP INDEX media_user_id_fk;  

ALTER TABLE messages DROP FOREIGN KEY messages_from_user_id_fk; 
ALTER TABLE messages DROP INDEX messages_from_user_id_fk;  

-- Удаляем индексы если нужно
DROP INDEX users_first_name_last_name_idx ON users; 


-- Документация по Workbench execution plan
-- https://dev.mysql.com/doc/workbench/en/wb-performance-explain.html


-- Требования к курсовому проекту:

-- общее текстовое описание БД и решаемых ею задач;
-- минимальное количество таблиц - 10;
-- скрипты создания структуры БД (с первичными ключами,
-- индексами, внешними ключами);
-- создать ERDiagram для БД;
-- скрипты наполнения БД данными;
-- скрипты характерных выборок
-- (включающие группировку, JOIN, вложенные запросы);
-- представления (минимум 2);
-- хранимые процедуры / триггеры;
-- ...
-- Примеры: описать модель хранения данных популярного веб-сайта:
-- кинопоиск, booking.com, wikipedia,
-- интернет-магазин, geekbrains, госуслуги...

-- Думайте об этом задании, как о том, чем Вы похвастаетесь
-- на своем следующем собеседовании.
