-- Топ 10 ресторанов по кол-ву доставок

SELECT 	r.name, 
		rt.restoran_type as 'type' ,
		COUNT(o.id) as 'orders'
	FROM restorans r 
		LEFT JOIN orders o 
			ON o.restoran_id = r.id
			AND o.status = 'delivered'
		LEFT JOIN restoran_type rt 
			ON rt.id = r.restoran_type_id 
	GROUP BY r.name, rt.restoran_type
	ORDER BY orders DESC
	LIMIT 10;
		


-- Топ рестораны из группы по количеству заказов

SELECT 	DISTINCT rt.restoran_type as 'restoran type',
		FIRST_VALUE(r.name) OVER (PARTITION BY rt.id ORDER BY sort_orders.orders DESC) as 'restoran name',
		MAX(sort_orders.orders) OVER (PARTITION BY r.restoran_type_id) as 'orders count'
	FROM 
		(SELECT o.restoran_id ,
				COUNT(o.id) as 'orders'
			FROM orders o 
			GROUP BY o.restoran_id) as sort_orders
		LEFT JOIN restorans r 
			ON r.id = sort_orders.restoran_id
		LEFT JOIN restoran_type rt 
			ON r.restoran_type_id = rt.id
	;



-- Самый дорогой исполненный заказ

SELECT DISTINCT o.id as 'order id',
	SUM(mi.price) OVER (PARTITION BY oi.order_id) as 'sum'
	FROM orders o 
		RIGHT JOIN order_items oi 
			ON oi.order_id = o.id
		LEFT JOIN menu_items mi 
			on oi.menu_item_id = mi.id 
	WHERE o.status = 'delivered'
	ORDER BY sum DESC
	LIMIT 1;



-- Сумма по заказам с разбивкой по ресторанам и компаниям

WITH orders_summ AS
(
SELECT DISTINCT oi.order_id,
		SUM(mi.price * oi.count) OVER (PARTITION BY oi.order_id) as 'order_sum',
		o.restoran_id 
	FROM order_items oi 
		JOIN orders o 
			ON o.id = oi.order_id
			AND o.status = 'delivered'
		JOIN menu_items mi 
			ON mi.id = oi.menu_item_id
		AND mi.to_date > o.created_at 
		AND mi.created_at < o.created_at 
)	

SELECT DISTINCT c.name as 'company name',
				c.inn as 'inn',
				c.ogrn as 'ogrn',
				r.name as 'restoran name',
				IFNULL(SUM(os.order_sum) OVER (PARTITION BY os.restoran_id), 0) as 'orders_sum'
	FROM companies c 
		RIGHT JOIN restorans r 
				ON r.company_id = c.id
		LEFT JOIN orders o 
				ON o.restoran_id = r.id 
				AND o.status = 'delivered'
-- 				AND o.created_at >= '2020-01-01'
-- 				AND o.created_at < '2021-01-01'
		LEFT JOIN orders_summ as os
				ON os.order_id = o.id
-- 		WHERE inn = 5719310889
;



