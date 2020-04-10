-- 1. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

-- Не особо понял условие, поэтому если что-то не так понял, могу переделать.
 
-- Общее количество лайков, которые получили 10 самых молодых пользователей.

SELECT 
	SUM(likes_count)
FROM 
	(SELECT * FROM
		(SELECT 
		 	COUNT(*) AS likes_count, -- считаем лайки поставленные пользователю
			(SELECT birthday FROM profiles WHERE user_id = likes.user_id) AS birthday -- определяем день рождения пользователя для группировки
		FROM likes
		WHERE user_id IN (
				SELECT target_id FROM likes WHERE target_type = 2
				)
		GROUP BY user_id -- группируем по юзер ид и получаем, сколько лайков поставили каждому пользователю
		ORDER BY birthday DESC -- сортировка по дню рождения
		LIMIT 10
		) AS liked_users
	) AS total;

-- Т.е. самые молодые, которым вообще ставили лайки.

-- 2. Определить кто больше поставил лайков (всего) - мужчины или женщины?

(SELECT 
	COUNT(*) AS 'MALE/FEMALE'
FROM likes
WHERE user_id IN (SELECT user_id FROM profiles WHERE gender = 'm'))
UNION
(SELECT 
	COUNT(*)
FROM likes
WHERE user_id IN (SELECT user_id FROM profiles WHERE gender = 'f'));

-- 3. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

SELECT 
	SUM(total) AS activity, 
	user_id FROM (
		(SELECT COUNT(*) AS total, user_id FROM media GROUP BY user_id)-- кол-во медиа пользователя
		UNION
		(SELECT COUNT(*), user_id FROM posts GROUP BY user_id) -- кол-во постов пользователя + посты пользователя в группах
		UNION
		(SELECT SUM(count_mess) sum_user_mess, from_user_id FROM (
			SELECT COUNT(*) count_mess, from_user_id FROM messages GROUP BY from_user_id
			UNION
			SELECT COUNT(*), to_user_id FROM messages GROUP BY to_user_id
		) AS count_all_user_mess GROUP BY from_user_id) -- кол-во сообщений пользователя
	) AS activity_of_users 
GROUP BY 
	user_id 
ORDER BY 
	activity 
LIMIT 10;