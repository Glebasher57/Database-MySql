-- Практическое задание по теме “Оптимизация запросов”

-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products 
-- в таблицу logs помещается время и дата создания записи, название таблицы, 
-- идентификатор первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	table_name VARCHAR(30),
	primary_key INT UNSIGNED,
	name VARCHAR(255),
	created_at DATETIME
) ENGINE = Archive;

DELIMITER -

DROP TRIGGER IF EXISTS send_log_usr_insert-
CREATE TRIGGER send_log_usr_insert AFTER INSERT ON users
FOR EACH ROW
BEGIN
	DECLARE pk BIGINT;
	DECLARE val_name VARCHAR(255);
	DECLARE create_date DATETIME;
	DECLARE table_name VARCHAR(30);
	SET table_name = 'users';
	
	SELECT id, name, created_at INTO pk, val_name, create_date 
	  FROM users 
	    ORDER BY id DESC LIMIT 1;
	
	INSERT INTO logs(
		table_name, 
		primary_key, 
		name,
		created_at
		)
	VALUES (
		table_name,
		pk,
		val_name, 
		create_date
		);
END-

DROP TRIGGER IF EXISTS send_log_cat_insert-
CREATE TRIGGER send_log_cat_insert AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
	DECLARE pk BIGINT;
	DECLARE val_name VARCHAR(255);
	DECLARE create_date DATETIME;
	DECLARE table_name VARCHAR(30);
	SET table_name = 'catalogs';
	
	SELECT id, name, created_at INTO pk, val_name, create_date FROM catalogs ORDER BY id DESC LIMIT 1;
	
	INSERT INTO logs(
		table_name, 
		primary_key, 
		name,
		created_at
		)
	VALUES (
		table_name,
		pk,
		val_name, 
		create_date
		);
END-

DROP TRIGGER IF EXISTS send_log_prod_insert-
CREATE TRIGGER send_log_prod_insert AFTER INSERT ON products
FOR EACH ROW
BEGIN
	DECLARE pk BIGINT;
	DECLARE val_name VARCHAR(255);
	DECLARE create_date DATETIME;
	DECLARE table_name VARCHAR(30);
	SET table_name = 'products';
	
	SELECT id, name, created_at INTO pk, val_name, create_date FROM products ORDER BY id DESC LIMIT 1;
	
	INSERT INTO logs(
		table_name, 
		primary_key, 
		name,
		created_at
		)
	VALUES (
		table_name,
		pk,
		val_name, 
		create_date
		);
END-

DELIMITER ;

SHOW TABLE STATUS LIKE 'logs';

INSERT INTO products(name) VALUES ('Покрывало');
INSERT INTO users(name, birthday_at) VALUES ('Василий', '2001.02.22');
INSERT INTO catalogs(name) VALUES ('Выпечка');

SELECT * FROM logs;

-- упрощеный вариант

CREATE TRIGGER products_insert AFTER INSERT ON products
FOR EACH ROW
BEGIN
    INSERT INTO logs(table_name, primary_key, name, created_at) VALUES ("users", NEW.id, NEW.name, NEW.created_at);
END//

-- и т.д.


-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
 	
DELIMITER -

DROP PROCEDURE IF EXISTS insert_values-
CREATE PROCEDURE insert_values(IN num INT)
BEGIN
	DECLARE i INT DEFAULT 1;
	WHILE i <= num DO
		INSERT INTO users(name) VALUES (i);
		SET i = i + 1;
	END WHILE;
END-

DELIMITER ;

CALL insert_values(3);

-- Практическое задание по теме “NoSQL”
-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

HMSET ip 79.0.0.0 1 83.0.0.0 1 92.0.0.0 1

-- 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу 
-- и наоборот, поиск электронного адреса пользователя по его имени.

SET username username@mail.ru
SET username@mail.ru username
GET username
GET username@mail.ru

-- или

HMSET users 
	username1 "username1@mail.ru" 
	username2 "username2@mail.ru"
HMSET emails 
	username1@mail.ru "username1" 
	username2@mail.ru "username2"

HMGET users username1 username2
HGETALL users
HMGET emails username1@mail.ru username2@mail.ru
HGETALL emails

-- 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

use shop
db.shop.insert(
	{'catalogs': [
		{id: 1, name: 'Процессоры'}, 
		{id: 2, name: 'Мат. платы'}, 
		{id: 3, name: 'Видеокарты'}
		] 
	}
)

db.shop.insert(
	{'products': [
		{id: 1, name: 'Intel Core i3-8100', price: 7890.00, catalog_id: 1}, 
		{id: 2, name: 'Intel Core i5-7400', price: 12700.00, catalog_id: 1}, 
		{id: 3, name: 'AMD FX-8320E', price: 4780.00, catalog_id: 1}, 
		{id: 4, name: 'ASUS ROG MAXIMUS X HERO', price: 19310.00, catalog_id: 2}, 
		{id: 5, name: 'Gigabyte H310M S2H', price: 4790.00, catalog_id: 2}, 
		{id: 6, name: 'MSI B250M GAMING PRO', price: 5060.00, catalog_id: 2}
		] 
	}
)

db.shop.find()

-- ____________________________________________________________
-- правильный вариант

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