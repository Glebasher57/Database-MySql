-- 1. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

SELECT SUM(l_count) AS likes_sum FROM (
	SELECT COUNT(*) AS l_count 
	FROM likes l JOIN profiles p2 
	ON l.target_id = p2.user_id AND l.target_type = 2
	GROUP BY target_id 
	ORDER BY birthday DESC 
	LIMIT 10
	) AS select_count
;

-- 10 самых молодых, среди тех, кто есть в target_id в таблице likes т.е. те кому ставили лайки.

SELECT SUM(likes_count) FROM (
  SELECT COUNT(*) AS likes_count, l.target_id 
    FROM likes l JOIN profiles p 
    ON l.target_id IN (SELECT * FROM (
      SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10
    ) AS sorted_profiles)
      AND l.target_type = 2 AND l.target_id = p.user_id 
    GROUP BY l.target_id
) AS likes_total
;

-- 10 самых молодых, если еще считать пользователей которых нет в target_id в таблице likes т.е. подсчет среди всех пользователей вообще.

-- 2. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT 
	COUNT(l.id), gender
FROM likes l 
	JOIN profiles p 
ON 
	l.user_id = p.user_id 
GROUP BY 
	gender;

-- 3. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

SELECT DISTINCT 
  u.id,
  COUNT(DISTINCT mes.to_user_id) +    -- почему работает именно с приравниванием from_user_id к u.id, 
  COUNT(DISTINCT p.id) +              -- а подсчет делается по to_user_id (НЕМНОГО ПОНЯТНО (НЕ ПОНЯТНО))
  COUNT(DISTINCT l.id) +
  COUNT(DISTINCT m.id) AS total
  FROM users u 
    LEFT JOIN messages mes
      ON mes.from_user_id = u.id
    LEFT JOIN posts p
      ON p.user_id = u.id
    LEFT JOIN likes l
      ON l.user_id = u.id
    LEFT JOIN media m
      ON m.user_id = u.id
  GROUP BY u.id
  ORDER BY total
  LIMIT 10
 ;