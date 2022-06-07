USE coffee_chain_db;


delimiter $$
DROP PROCEDURE IF EXISTS Insert_Material;
CREATE PROCEDURE Insert_Material 
(new_id INT, new_name VARCHAR(20), new_quantity INT)
BEGIN
	DECLARE m_count INT DEFAULT 0;
    DECLARE n_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO m_count FROM MATERIAL WHERE m_id = new_id;
	SELECT COUNT(*) INTO n_count FROM MATERIAL WHERE m_name = new_name;

	-- nguyen lieu da ton tai
    IF m_count > 0 THEN
		SET @error_msg = CONCAT('Nguyen lieu voi ID: ',CAST(new_id AS CHAR), ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    -- 2 nguyen lieu khac nhau nhung co cung ten
    IF n_count > 0 THEN
		SET @error_msg = CONCAT('Nguyen lieu voi ten: ',CAST(new_name AS CHAR), ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	INSERT INTO MATERIAL 
	VALUES(new_id, new_name, new_quantity);
END 
$$

delimiter $$
DROP PROCEDURE IF EXISTS Delete_Material;
CREATE PROCEDURE Delete_Material
(d_id INT)
BEGIN
	DECLARE m_count INT DEFAULT 0;
    SELECT COUNT(*) INTO m_count FROM MATERIAL WHERE m_id = d_id;
    -- nguyen lieu khong ton tai
    IF m_count = 0 THEN
		SET @error_msg = CONCAT('Nguyen lieu voi ID: ',CAST(d_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	DELETE FROM Material 
    WHERE m_id = d_id;
END
$$


delimiter $$
DROP PROCEDURE IF EXISTS Update_Material_ID;
CREATE PROCEDURE Update_Material_ID
(u_id INT, new_id INT)
BEGIN
	DECLARE m_count INT DEFAULT 0;
    DECLARE n_count INT DEFAULT 0;
    SELECT COUNT(*) INTO m_count FROM MATERIAL WHERE m_id = u_id;
	SELECT COUNT(*) INTO n_count FROM MATERIAL WHERE m_id = new_id;
    
    -- bao loi nguyen lieu khong ton tai
    IF m_count = 0 THEN
		SET @error_msg = CONCAT('Nguyen lieu voi ID: ',CAST(u_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
    -- bao loi trung id
	IF n_count > 0 THEN
		SET @error_msg = CONCAT('Nguyen lieu voi ID: ',CAST(new_id AS CHAR), ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	UPDATE Material 
    SET m_id = new_id
    WHERE m_id = u_id;
END
$$


delimiter $$
DROP PROCEDURE IF EXISTS Update_Material_Name;
CREATE PROCEDURE Update_Material_Name
(u_id INT, new_name VARCHAR(20))
BEGIN
	DECLARE m_count INT DEFAULT 0;
    DECLARE n_count INT DEFAULT 0;
    SELECT COUNT(*) INTO m_count FROM MATERIAL WHERE m_id = u_id;
	SELECT COUNT(*) INTO n_count FROM MATERIAL WHERE m_name = new_name AND m_id != u_id;
    
    -- bao loi nguyen lieu khong ton tai
    IF m_count = 0 THEN
		SET @error_msg = CONCAT('Nguyen lieu voi ID: ',CAST(u_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
    -- bao loi trung ten nguyen lieu
	IF n_count > 0 THEN
		SET @error_msg = CONCAT('Nguyen lieu voi ten: ', new_name, ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	UPDATE MATERIAL 
    SET m_name = new_name
    WHERE m_id = u_id;
END
$$



