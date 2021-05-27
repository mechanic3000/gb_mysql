CREATE OR REPLACE VIEW login_name_v AS 
		SELECT u.login , p.first_name , p.last_name FROM users u 
			JOIN profiles p 
			ON u.id = p.user_id; 
			
		
CREATE OR REPLACE VIEW restorans_menu_categories AS 
		SELECT r.id as restoran_id, mc.name as category_name FROM restorans r 
			JOIN menu_categories mc  
			ON r.id = mc.restoran_id 
			ORDER BY r.id ;
			
	
CREATE OR REPLACE VIEW restorans_economist_phone AS 
		SELECT r.name as restoran, cp.phone_number as economist_phone FROM restorans r 
			JOIN company_phones cp 
				ON cp.company_id = r.company_id 
				AND cp.phone_type = 'economist';
		