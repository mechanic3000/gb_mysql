DROP TRIGGER IF EXISTS menu_items_trg;

DELIMITER //
CREATE TRIGGER menu_items_trg BEFORE DELETE ON menu_items
FOR EACH ROW BEGIN 
	SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Нельзя удалять записи из таблицы. Для удаления установите значение to_date = NOW()';
END//

DELIMITER ;
DELETE FROM menu_items WHERE id = 100;
