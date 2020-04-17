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

--Не смог справиться с 3м заданием. В таком варианте цифры в столбцах получаются верными, 
--но сложить не выходит, т.к. в некоторых ячейках присутствуют NULL значения и возвращается полностью NULL

SELECT u.id, f.mes_f_count, t.mes_t_count, p.p_count, l.l_count, m.m_count AS total
FROM users u
	LEFT JOIN (SELECT from_user_id, COUNT(*) AS mes_f_count FROM messages GROUP BY from_user_id) f
	  ON f.from_user_id = u.id
	LEFT JOIN (SELECT to_user_id, COUNT(*) AS mes_t_count FROM messages GROUP BY to_user_id) t
	  ON t.to_user_id = u.id
	LEFT JOIN (SELECT user_id, COUNT(*) AS p_count FROM posts GROUP BY user_id) p
	  ON p.user_id = u.id
	LEFT JOIN (SELECT user_id, COUNT(*) AS l_count FROM likes GROUP BY user_id) l
	  ON l.user_id = u.id
	LEFT JOIN (SELECT user_id, COUNT(*) AS m_count FROM media GROUP BY user_id) m
	  ON m.user_id = u.id
ORDER BY u.id;

-- или такой вариант: 

SELECT DISTINCT 
  u.id,
  COUNT(DISTINCT mes.from_user_id) +
  COUNT(DISTINCT p.id) +
  COUNT(DISTINCT l.id) +
  COUNT(DISTINCT m.id) AS total
  FROM users u 
    LEFT JOIN messages mes 
      ON mes.from_user_id = u.id OR mes.to_user_id = u.id
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

-- в некоторых местах ответы не сходятся... не знаю чего не хватает... ужасное задание