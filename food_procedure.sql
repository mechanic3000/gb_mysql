DELIMITER //
DROP PROCEDURE IF EXISTS billing //

-- урпощенная версия биллинга без разбивки по периодам

CREATE PROCEDURE billing ()
BEGIN
	
	DECLARE inn VARCHAR(50);
	DECLARE orders_sum DECIMAL(10,2);
	DECLARE end_lines INT DEFAULT 0;

	DECLARE OrderCursor CURSOR FOR (
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
					
					SELECT DISTINCT c.inn as 'inn',
									IFNULL(SUM(os.order_sum) OVER (PARTITION BY r.company_id), 0) as 'orders_sum'
						FROM companies c 
							RIGHT JOIN restorans r 
									ON r.company_id = c.id
							LEFT JOIN orders o 
									ON o.restoran_id = r.id 
									AND o.status = 'delivered'
							LEFT JOIN orders_summ as os
									ON os.order_id = o.id
					);
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET end_lines=1;

	TRUNCATE TABLE billing;
	OPEN OrderCursor;
	WHILE end_lines=0 DO
		FETCH OrderCursor INTO inn, orders_sum;
		INSERT INTO billing (`company_inn`,`summ`, `status`) VALUES (inn, orders_sum,'created');
	END WHILE;

	CLOSE OrderCursor;
	

END //

DELIMITER ;

call billing();

SELECT * from billing b ;