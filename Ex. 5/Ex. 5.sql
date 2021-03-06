“Операторы, фильтрация, сортировка и ограничение”

1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
Заполните их текущими датой и временем.

UPDATE 
	users 
SET
	created_at = NOW(),
	updated_at = NOW();

2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR 
и в них долгое время помещались значения в формате "20.10.2017 8:10". 
Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.

UPDATE 
	users 
SET 
	created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'), 
	updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');

ALTER TABLE 
	users 
MODIFY COLUMN 
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW();

3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 
0, если товар закончился и выше нуля, если на складе имеются запасы. 
Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
Однако, нулевые запасы должны выводиться в конце, после всех записей.

SELECT 
	* 
FROM 
	storehouses_products 
ORDER BY 
	value < 1;

4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
Месяцы заданы в виде списка английских названий ('may', 'august').

SELECT 
	* 
FROM 
	users 
WHERE 
	birthday_at 
RLIKE 
	'May|August';

5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.

SELECT 
	* 
FROM 
	catalogs 
WHERE 
	id 
IN 
	(5, 1, 2) 
ORDER BY 
	FIELD(id, 5, 1, 2);

___________________
“Агрегация данных”

1. Подсчитайте средний возраст пользователей в таблице users.

SELECT 
	ROUND((TO_DAYS(NOW()) - AVG(TO_DAYS(birthday_at))) / 365.25) 
FROM 
	users;

или

SELECT 
	ROUND(AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW()))) 
FROM 
	users;

Нижний вариант вроде бы более правильный.

2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
Следует учесть, что необходимы дни недели текущего года, а не года рождения.

SELECT 
	COUNT(*), 
	DAYOFWEEK(DATE_FORMAT(CONCAT(YEAR(NOW()), '-', SUBSTRING(birthday_at, 6, 5)), "%Y" "%m" "%d")) AS DAY_OF_WEEK
FROM 
	users 
GROUP BY 
	DAY_OF_WEEK;

3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.

SELECT ROUND(EXP(SUM(LN(id)))) FROM users;