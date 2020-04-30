-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения 
-- и добавить необходимые индексы.

	CREATE UNIQUE INDEX users_email_uq_idx ON users(email);
	CREATE UNIQUE INDEX users_phone_uq_idx ON users(phone);
	CREATE INDEX profiles_user_id_gender_idx ON profiles (user_id, gender);
	CREATE INDEX profiles_gender_user_id_idx ON profiles (gender, user_id);
	CREATE INDEX profiles_city_idx ON profiles(city);
	CREATE INDEX profiles_country_idx ON profiles(country);
	CREATE INDEX profiles_user_id_country_idx ON profiles(user_id, country);
	CREATE INDEX profiles_country_user_id_idx ON profiles(country, user_id);
	CREATE INDEX profiles_user_id_city_idx ON profiles(user_id, city);
	CREATE INDEX profiles_city_user_id_idx ON profiles(city, user_id);
	CREATE INDEX communities_users_community_id_user_id_idx ON communities_users(community_id, user_id);
	CREATE INDEX communities_users_user_id_community_id_idx ON communities_users(user_id, community_id);
	CREATE INDEX likes_user_id_target_id_idx ON likes(user_id, target_id);
	CREATE INDEX likes_target_id_user_id_idx ON likes(target_id, user_id);
	CREATE INDEX likes_target_id_target_type_idx ON likes(target_id, target_type);
	CREATE INDEX likes_target_type_target_id_idx ON likes(target_type, target_id);
	-- и т.д.

-- 2. Задание на оконные функции.
-- Провести аналитику в разрезе групп.
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый пожилой пользователь в группе
-- количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (количество пользователей в группе / всего пользователей в системе) * 100

SELECT DISTINCT c.name AS group_name,
 	COUNT(cu.user_id) OVER() / 2 AS avg_amount,
 	FIRST_VALUE(cu.user_id) OVER (w ORDER BY p.birthday DESC) AS younger,
 	FIRST_VALUE(cu.user_id) OVER (w ORDER BY p.birthday) AS older,
	COUNT(cu.user_id) OVER w AS amount_users_in_gp,
	COUNT(p.user_id) OVER() AS total_users,
	COUNT(cu.user_id) OVER w / COUNT(p.user_id) OVER() * 100 AS '%%'
  FROM profiles p
  	LEFT JOIN communities_users cu
      ON p.user_id = cu.user_id
    JOIN communities c
      ON cu.community_id = c.id
      WINDOW w AS (PARTITION BY cu.community_id);

--исправленный вариант

SELECT DISTINCT c.name AS group_name,
 	COUNT(cu.user_id) OVER() / (SELECT COUNT(*) FROM communities) AS avg_amount,
 	FIRST_VALUE(cu.user_id) OVER (w ORDER BY p.birthday DESC) AS younger,
 	FIRST_VALUE(cu.user_id) OVER (w ORDER BY p.birthday) AS older,
	COUNT(cu.user_id) OVER w AS amount_users_in_gp,
	(SELECT COUNT(*) FROM users) AS total_users,
	COUNT(cu.user_id) OVER w / (SELECT COUNT(*) FROM users) * 100 AS '%%'
  FROM communities c
  	LEFT JOIN communities_users cu
      ON cu.community_id = c.id
    LEFT JOIN profiles p
      ON p.user_id = cu.user_id
      WINDOW w AS (PARTITION BY cu.community_id);
      
-- 3. (по желанию) Задание на денормализацию
-- Разобраться как построен и работает следующий запрос:
-- Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

SELECT users.id,
COUNT (DISTINCT messages.id) +
COUNT (DISTINCT likes.id) +
COUNT (DISTINCT media.id) AS activity
FROM users
LEFT JOIN messages
ON users.id = messages.from_user_id
LEFT JOIN likes
ON users.id = likes.user_id
LEFT JOIN media
ON users.id = media.user_id
GROUP BY users.id
ORDER BY activity
LIMIT 10;

/*Запрос включает в себя выборку значений из таблиц users, messages, likes, media
при помощи левого объединения к таблице users. В выборку попадает колонка id пользователя, из таблицы users,
и activity, представляющая собой сумму количества строк (функция COUNT) из таблиц messages (кол-во сообщений ползователя),
likes (кол-во лайков пользователя), media(кол-во медиа пользователя), сгрупированных по id пользователя таблицы users (определяем его активность).
Сортировка по колонке activity. Лимит вывода - 10 значений. Запрос верный. Идей по поводу денормализации особо нет. 
Может быть как-нибудь хранить все действия пользователя (лайки, сообщения, медиа) в общей таблице?*/

-- Правильно-ли он построен?
-- Какие изменения, включая денормализацию, 
-- можно внести в структуру БД чтобы существенно повысить скорость работы этого запроса?