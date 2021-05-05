-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT CONCAT("Больше всех лайков поставили ", 
				likes.gender,
				", в количестве ",
				likes.likes_count,
				" штук.") as Answer
	FROM (	
			SELECT 'женщины' as gender, COUNT(*) as likes_count FROM likes l , profiles p 
				WHERE l.user_id = p.user_id
					AND p.gender = "F"
			UNION
			SELECT 'мужчины', COUNT(*) FROM likes l , profiles p 
				WHERE l.user_id = p.user_id
					AND p.gender = "M"
			ORDER BY likes_count DESC 
		) AS likes
	LIMIT 1;
  
  
  
-- (по желанию) Подсчитать количество лайков которые получили 10 
-- самых молодых пользователей.


SELECT CONCAT(u.first_name, " ", u.last_name) as Name, COUNT(l.id) as 'Likes count'
	FROM likes l, 
			(SELECT user_id FROM (
							SELECT p.user_id 
							FROM profiles p 
							ORDER BY p.birthday DESC 
							LIMIT 10) AS tmp_youngest
			) AS youngest_users,
		users u
	WHERE l.target_type = "users"
		AND l.target_id = youngest_users.user_id
		AND l.target_id = u.id
	GROUP BY l.target_id ;
