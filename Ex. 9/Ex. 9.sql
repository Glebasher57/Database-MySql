-- Практическое задание по теме “Транзакции, переменные, представления”

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO sample.users SELECT * FROM shop.users WHERE id = 1;
COMMIT;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

CREATE VIEW prod (product_name, catalog_name) AS
SELECT p.name, c.name 
FROM products p 
  JOIN catalogs c 
    ON p.catalog_id = c.id;

-- 3. (по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, 
-- если дата присутствует в исходном таблице и 0, если она отсутствует.

-- создание тестовых данных

DROP TABLE IF EXISTS test;
CREATE TABLE test(
	created_at DATE
);

INSERT INTO test VALUES 
	('2018-08-01'), 
	('2016-08-04'), 
	('2018-08-16'), 
	('2018-08-17');

DROP TEMPORARY TABLE IF EXISTS days;
CREATE TEMPORARY TABLE days (dom INT);
INSERT INTO days VALUES (01), (02), (03), (04), (05),
						(06), (07), (08), (09), (10), 
						(11), (12), (13), (14), (15),
						(16), (17), (18), (19), (20),
                        (21), (22), (23), (24), (25), 
                        (26), (27), (28), (29), (30), (31);

SELECT @fst_day := '2018-07-31';

SELECT 
	@fst_day + INTERVAL days DAY AS day_of_aug,
    IF(t.created_at IS NULL, 0, 1) AS having_days  
FROM days d 
  LEFT JOIN test t 
  	ON @fst_day + INTERVAL days DAY = t.created_at
ORDER BY day_of_aug;

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

DROP TABLE IF EXISTS test;
CREATE TABLE test(
	created_at DATE
);

INSERT INTO test VALUES 
	('2018-08-01'), 
	('2016-08-04'), 
	('2018-08-16'), 
	('2018-08-17'),
	('2019-12-12'),
	('2020-11-11');

DROP VIEW IF EXISTS test_view;
CREATE VIEW test_view AS
	SELECT created_at FROM test ORDER BY created_at DESC LIMIT 5;

SELECT * FROM test_view ORDER BY created_at LIMIT 1;

SELECT @fresh := (SELECT * FROM test_view ORDER BY created_at LIMIT 1);

SELECT @fresh;

DELETE FROM test WHERE created_at < @fresh;

-- Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию)

-- 1. Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.

CREATE USER 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY '12345';
GRANT SELECT ON shop.* TO 'shop_read'@'localhost';

CREATE USER 'shop'@'localhost' IDENTIFIED WITH sha256_password BY '12345';
GRANT ALL ON shop.* TO 'shop'@'localhost';

-- 2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, 
-- содержащие первичный ключ, имя пользователя и его пароль. Создайте представление username таблицы accounts, 
-- предоставляющий доступ к столбца id и name. Создайте пользователя user_read, который бы не имел доступа к таблице accounts, 
-- однако, мог бы извлекать записи из представления username.

CREATE VIEW acc AS
SELECT id, name FROM accounts;

CREATE USER 'user_read'@'localhost' IDENTIFIED WITH sha256_password BY '12345';
GRANT SELECT ON shop.acc TO 'user_read'@'localhost';


-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"

-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DELIMITER //
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello()
RETURNS VARCHAR(11) NO SQL
BEGIN
	SET @now_time = DATE_FORMAT(NOW(), '%H');
	IF (@now_time >= 6) AND (@now_time < 12) THEN
		RETURN 'Доброе утро';
	ELSEIF (@now_time >= 12) AND (@now_time < 18) THEN
		RETURN 'Добрый день';
	ELSEIF (@now_time >= 18) AND (@now_time < 0) THEN
		RETURN 'Добрый вечер';
	ELSEIF (@now_time >= 0) AND (@now_time < 6) THEN
		RETURN 'Доброй ночи';
	END IF;
END//

SELECT hello()//


-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

DELIMITER //
DROP TRIGGER IF EXISTS check_products_insert//
CREATE TRIGGER check_products_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
	IF (NEW.name IS NULL) AND (NEW.description IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Одно из полей (name/description) не заполнено.';
	END IF;
END//

DROP TRIGGER IF EXISTS check_products_update//
CREATE TRIGGER check_products_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	IF (NEW.name IS NULL) AND (NEW.description IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Одно из полей (name/description) не заполнено.';
	END IF;
END//

-- 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.

DELIMITER //

DROP FUNCTION IF EXISTS FIBONACCI//
CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE i INT DEFAULT 0;
	DECLARE total INT DEFAULT 0;
	DECLARE prev1 INT DEFAULT 0;
	DECLARE prev2 INT DEFAULT 0;

	WHILE i < num DO
		SET total = prev1 + prev2;		
		SET prev2 = prev1;
		SET prev1 = total;
	
		IF prev1 < 1 THEN
			SET prev1 = prev1 + 1;
		END IF;
		
		SET i = i + 1;
	END WHILE;
	RETURN total;
END//

SELECT FIBONACCI(10)//