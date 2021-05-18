-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT CONCAT("Больше всех лайков поставили ", IF(p.gender = "M", "мужчины", "женщины")) as `result`, 
		COUNT(l.id) as `Likes count` 
	FROM likes l 
	LEFT JOIN profiles p 
		ON p.user_id = l.user_id 
	GROUP BY p.gender
	ORDER BY 2 DESC
	LIMIT 1;
	

-- Вывести для каждого пользователя количество созданных сообщений, постов, 
-- загруженных медиафайлов и поставленных лайков.


SELECT  CONCAT(u.first_name, ' ', u.last_name) as `name`,
		COUNT(DISTINCT m.id) as `messages`,
		COUNT(DISTINCT p.id) as `posts`,
		COUNT(DISTINCT m2.id) as `media`,
		COUNT(DISTINCT l.id) as `likes`
	FROM users u 
	LEFT JOIN messages m 
		ON u.id = m.from_user_id 
	LEFT JOIN  posts p 
		ON u.id = p.user_id 	
	LEFT JOIN media m2 
		ON	u.id = m2.user_id 
	LEFT JOIN likes l 
		ON u.id = l.user_id 
	GROUP BY `name` ;


-- (по желанию) Подсчитать количество лайков которые получили 10 самых молодых 
-- пользователей.

SELECT CONCAT(u.first_name, ' ', u.last_name) as `name` , 
		TIMESTAMPDIFF(YEAR, p.birthday, NOW()) as `age`,
		COUNT(l.id) as `likes`
	FROM profiles p 
	LEFT JOIN likes l 
		ON p.user_id = l.target_id 
	INNER JOIN users u 
		ON u.id = p.user_id 
	WHERE l.target_type = 'users'
	GROUP BY p.user_id
	ORDER BY p.birthday DESC 
	LIMIT 10;
