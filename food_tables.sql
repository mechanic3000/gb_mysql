SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`login` VARCHAR(255) NOT NULL,
	`password` CHAR(60) NOT NULL,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY (`login`)	
) COMMENT='Пользователи';


DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`user_id` INT(10) unsigned NOT NULL,
	`first_name` VARCHAR(255),
	`last_name` VARCHAR(255),
	`email` VARCHAR(255) NOT NULL,
	`phone_number` VARCHAR(100) NOT NULL,
	`birthday_at` DATETIME,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`user_id`) REFERENCES users (`id`)
) COMMENT='Профили пользователей';

ALTER TABLE profiles ADD INDEX user_id_first_last_name_idx (`user_id`,`first_name`, `last_name`);


DROP TABLE IF EXISTS user_addresses;
CREATE TABLE user_addresses (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`user_id` INT(10) unsigned NOT NULL,
	`city` JSON,
	`lat` FLOAT(10,6),
	`lng` FLOAT(10,6),
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`user_id`) REFERENCES users (`id`)
)COMMENT="Адреса пользователей";


DROP TABLE IF EXISTS companies;
CREATE TABLE companies (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`address` JSON,
	`fact_address` JSON,
	`inn` VARCHAR(20) NOT NULL,
	`ogrn` VARCHAR(20) NOT NULL,
	`bank_account` JSON,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	UNIQUE KEY (`inn`),
	UNIQUE KEY (`ogrn`)
) COMMENT='Юридические лица';

ALTER TABLE companies ADD INDEX name_inn_ogrn_idx (`name`, `inn`, `ogrn`);

DROP TABLE IF EXISTS company_phones;
CREATE TABLE company_phones (
	`company_id` INT(10) unsigned NOT NULL,
	`phone_number` VARCHAR(100) NOT NULL,
	`phone_type` ENUM('manager', 'reseption', 'economist'),
	`phone_range` INT(10) unsigned NOT NULL,
	FOREIGN KEY (`company_id`) REFERENCES companies (`id`),
	UNIQUE KEY (`phone_number`)
) COMMENT='Телефоны компаний';


DROP TABLE IF EXISTS company_users;
CREATE TABLE company_users (
	`company_id` INT(10) unsigned NOT NULL,
	`user_id` INT(10) unsigned NOT NULL,
	`user_status` ENUM('admin', 'economist', 'manager', 'user'),
	PRIMARY KEY (`company_id`, `user_id`)
)COMMENT="Сотрудники компании";


DROP TABLE IF EXISTS restoran_type;
CREATE TABLE restoran_type (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`restoran_type` ENUM('sushi','pizza','burgers','noodles'),
	PRIMARY KEY (`id`),
	UNIQUE KEY (`restoran_type`)
)COMMENT="Тип кухни ресторана";


DROP TABLE IF EXISTS restorans;
CREATE TABLE restorans (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`address` JSON,
	`company_id` INT(10) unsigned NOT NULL,
	`restoran_type_id` INT(10) unsigned NOT NULL,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`company_id`) REFERENCES companies (`id`),
	FOREIGN KEY (`restoran_type_id`) REFERENCES restoran_type (`id`)
)COMMENT="Карточка ресторана";

ALTER TABLE restorans ADD INDEX name_idx (`name`);


DROP TABLE IF EXISTS menu_categories;
CREATE TABLE menu_categories (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`restoran_id` INT(10) unsigned NOT NULL,
	`parent_id` INT(10) unsigned NOT NULL COMMENT "Родительская категория",
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`restoran_id`) REFERENCES restorans (`id`)
)COMMENT="Категории меню";


DROP TABLE IF EXISTS delivery_zones;
CREATE TABLE delivery_zones (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`restoran_id` INT(10) unsigned NOT NULL,
	`poligon_geo_link` VARCHAR(255) NOT NULL,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`restoran_id`) REFERENCES restorans (`id`)
)COMMENT="Зоны доставки";



DROP TABLE IF EXISTS menu_items;
CREATE TABLE menu_items (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(255) NOT NULL,
	`menu_category_id` INT(10) unsigned NOT NULL,
	`description` TEXT,
	`picture` VARCHAR(255),
	`weight` INT(10) unsigned COMMENT "Вес позиции",
	`price` INT(10) unsigned,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`to_date` DATETIME DEFAULT '2222-12-31 00:00:00',
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`menu_category_id`) REFERENCES menu_categories (`id`)
)COMMENT="Позиции меню";


DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`user_id` INT(10) unsigned NOT NULL,
	`restoran_id` INT(10) unsigned NOT NULL,
	`user_address_id` INT(10) unsigned NOT NULL,
	`delivery_time` DATETIME COMMENT "Доставка ко времени",
	`persons_count` INT(10) unsigned COMMENT "Количество персон",
	`status` ENUM('created', 'accepted', 'handed', 'delivered', 'canceled'),
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`user_id`) REFERENCES users (`id`),
	FOREIGN KEY (`restoran_id`) REFERENCES restorans (`id`),
	FOREIGN KEY (`user_address_id`) REFERENCES user_addresses (`id`)
)COMMENT="Заказы";

ALTER TABLE orders ADD INDEX restoran_id_idx (`restoran_id`);


DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
	`order_id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`menu_item_id` INT(10) unsigned NOT NULL,
	`count` INT(10) unsigned NOT NULL,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`order_id`, `menu_item_id`)
)COMMENT="Позиции заказа";


DROP TABLE IF EXISTS billing;
CREATE TABLE billing (
	`id` INT(10) unsigned NOT NULL AUTO_INCREMENT,
	`company_inn` VARCHAR(50) NOT NULL,
	`status` ENUM('created','confirmed','paid'),
	`summ` DECIMAL(10,2) NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`company_inn`) REFERENCES companies (`inn`)
);

SET FOREIGN_KEY_CHECKS = 1;


