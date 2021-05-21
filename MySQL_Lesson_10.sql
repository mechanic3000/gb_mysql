-- Проанализировать какие запросы могут выполняться наиболее часто 
-- в процессе работы приложения и добавить необходимые индексы.

CREATE INDEX user_full_name_idx ON users(`id`, `first_name`, `last_name`);
CREATE INDEX likes_targegt_idx ON likes(`target_id`, `target_type`);
CREATE INDEX posts_head_idx ON posts(`id`, `head`);


-- Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах (сумма количестива пользователей во всех группах делённая 
--            на количество групп)
-- самый молодой пользователь в группе (желательно вывести имя и фамилию)
-- самый старший пользователь в группе (желательно вывести имя и фамилию)
-- количество пользователей в группе
-- всего пользователей в системе (количество пользователей в таблице users)
-- отношение в процентах для последних двух значений (общее количество пользователей в 
-- 				группе / всего пользователей в системе) * 100


SELECT DISTINCT c.name, 
	COUNT(cu.user_id) OVER()/COUNT(c.id) OVER() as `avg_users`,
	FIRST_VALUE(CONCAT(u.first_name, ' ', u.last_name)) 
					OVER(PARTITION BY cu.community_id ORDER BY p.birthday) as `yongest`,
	FIRST_VALUE(CONCAT(u.first_name, ' ', u.last_name)) 
					OVER(PARTITION BY cu.community_id ORDER BY p.birthday DESC) as `older`,
	COUNT(cu.user_id) OVER(PARTITION BY cu.community_id) as `users`,
	COUNT(u.id) OVER() as `total_users`,
	COUNT(cu.user_id) OVER(PARTITION BY cu.community_id)/COUNT(u.id) OVER() * 100 as `%%`
	FROM communities c 
		LEFT JOIN communities_users cu 
			ON c.id = cu.community_id 
		LEFT JOIN profiles p 
			ON cu.user_id = p.user_id
		LEFT JOIN users u 
			ON p.user_id = u.id;
