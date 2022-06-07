USE coffee_chain_db;

-- INSERT PROCEDURE
delimiter $$
DROP PROCEDURE IF EXISTS Insert_Batch;
CREATE PROCEDURE Insert_Batch
(new_id INT, 
new_m_id INT, 
new_mgr_id INT, 
new_i_date DATE, 
new_e_date DATE, 
new_quantity FLOAT)
BEGIN
	DECLARE m_count INT DEFAULT 0;
	DECLARE e_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO m_count FROM M_BATCH WHERE ba_id = new_id;
	-- lo hang da ton tai
    IF m_count > 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(new_id AS CHAR), ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	SELECT COUNT(*) INTO e_count FROM EMPLOYEE WHERE emp_id = new_mgr_id;
	-- nhan vien quan li khong ton tai
	IF e_count = 0 THEN
		SET @error_msg = CONCAT('Nhan vien quan ly ma so: ',CAST(new_mgr_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    -- loi nhap so luong
    IF new_quantity <= 0 THEN	
		SET @error_msg = CONCAT('So luong nhap phai duong');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    -- loi nhap ngay 
    IF new_i_date >= new_e_date THEN
		SET @error_msg = CONCAT('Ngay nhap phai nho hon ngay het han');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg;	
	END IF;
        
	
	INSERT INTO M_BATCH 
	VALUES(new_id, new_m_id, new_mgr_id, new_i_date, new_e_date, new_quantity);
END 
$$

-- DELETE PROCEDURE
delimiter $$
DROP PROCEDURE IF EXISTS Delete_Batch;
CREATE PROCEDURE Delete_Batch
(d_id INT)
BEGIN
	DECLARE b_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = d_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(d_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	DELETE FROM M_BATCH
    WHERE ba_id = d_id;
END 
$$

-- UPDATE PROCEDURE
delimiter $$
DROP PROCEDURE IF EXISTS Update_Batch_ID;
CREATE PROCEDURE Update_Batch_ID
(old_id INT, new_id INT)
BEGIN
	DECLARE b_count INT DEFAULT 0;
	DECLARE n_count INT DEFAULT 0;

	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = old_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(old_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	SELECT COUNT(*) INTO n_count FROM M_BATCH WHERE ba_id = new_id;
	-- ID muon cap nhat da ton tai
    IF n_count > 0 THEN
		SET @error_msg = CONCAT('ID muon cap nhat ID: ',CAST(new_id AS CHAR), ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	UPDATE M_BATCH
    SET ba_id = new_id
    WHERE ba_id = old_id;
END 
$$


delimiter $$
DROP PROCEDURE IF EXISTS Update_Batch_Manager;
CREATE PROCEDURE Update_Batch_Manager
(b_id INT, new_mng_id INT)
BEGIN
	DECLARE b_count INT DEFAULT 0;
	DECLARE n_count INT DEFAULT 0;

	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = b_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(b_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    
	SELECT COUNT(*) INTO n_count FROM EMPLOYEE WHERE emp_id = new_mng_id;
    -- quan li khong ton tai
	IF n_count = 0 THEN
		SET @error_msg = CONCAT('Nguoi quan li voi ID: ',CAST(new_mng_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	UPDATE M_BATCH
    SET mng_id = new_mng_id
    WHERE ba_id = b_id;
END 
$$

delimiter $$

DROP PROCEDURE IF EXISTS Update_Batch_Material;
CREATE PROCEDURE Update_Batch_Material
(b_id INT, new_m_id INT)
BEGIN
	DECLARE b_count INT DEFAULT 0;

	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = b_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(b_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    
	UPDATE M_BATCH
    SET m_id = new_m_id
    WHERE ba_id = b_id;
END 
$$


delimiter $$
DROP PROCEDURE IF EXISTS Update_Batch_Import_Date;
CREATE PROCEDURE Update_Batch_Import_Date
(b_id INT, new_imp_date INT)
BEGIN
	DECLARE b_count INT DEFAULT 0;
	DECLARE export_date DATE;

	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = b_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(b_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    
	SELECT exp_date INTO export_date FROM M_BATCH WHERE ba_id = b_id;
    
	IF export_date < new_imp_date THEN
		SET @error_msg = CONCAT('Ngay nhat lo hang phai nho hon ngay het han');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	UPDATE M_BATCH
    SET imp_date = new_imp_date
    WHERE ba_id = b_id;
END 
$$

delimiter $$

DROP PROCEDURE IF EXISTS Update_Batch_Export_Date;
CREATE PROCEDURE Update_Batch_Export_Date
(b_id INT, new_exp_date INT)
BEGIN
	DECLARE b_count INT DEFAULT 0;
	DECLARE import_date DATE;

	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = b_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(b_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    
	SELECT imp_date INTO import_date FROM M_BATCH WHERE ba_id = b_id;
    
	IF import_date > new_exp_date THEN
		SET @error_msg = CONCAT('Ngay nhat lo hang phai nho hon ngay het han');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	UPDATE M_BATCH
    SET exp_date = new_exp_date
    WHERE ba_id = b_id;
END 
$$


delimiter $$

DROP PROCEDURE IF EXISTS Update_Batch_Quantity;
CREATE PROCEDURE Update_Batch_Quantity
(b_id INT, new_quantity INT)
BEGIN
	DECLARE b_count INT DEFAULT 0;

	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = b_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Lo hang voi ID: ',CAST(b_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	IF new_quantity <= 0 THEN
		SET @error_msg = CONCAT('So luong cua lo hang phai duong');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	UPDATE M_BATCH
    SET quantity = new_quantity
    WHERE ba_id = b_id;
END 
$$



