-- INSERt PROCEDURE
delimiter ;
DROP PROCEDURE IF EXISTS Insert_Customer;
delimiter $$
CREATE PROCEDURE Insert_Customer
(first_name VARCHAR(10), last_name VARCHAR(20), id INT, phone_number CHAR(10), s CHAR(1), add_number INT, mail VARCHAR(40), reg_date DATE)
BEGIN
	DECLARE c_count INT DEFAULT 0;

	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count > 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	IF length(phone_number) != 10 THEN
		SET @error_msg = CONCAT('So dien thoai phai gom chinh xac 10 so');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    IF 
    mail NOT REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$'
    THEN
		SET @error_msg = CONCAT('Dia chi email khong hop le');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	INSERT INTO CUSTOMER
    VALUES(first_name, last_name, id, phone_number, s, add_number, mail, reg_date); 
END 
$$

delimiter ;
DROP PROCEDURE IF EXISTS Delete_Customer;
delimiter $$
CREATE PROCEDURE Delete_Customer
(id INT)
BEGIN
	DECLARE c_count INT DEFAULT 0;

	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	DELETE FROM CUSTOMER
    WHERE cus_id = id;
END 
$$

delimiter ;
DROP PROCEDURE IF EXISTS Update_Customer_ID;
delimiter $$
CREATE PROCEDURE Update_Customer_ID
(id INT, new_id INT)
BEGIN
	DECLARE c_count INT DEFAULT 0;
	DECLARE n_count INT DEFAULT 0;

	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	SELECT COUNT(*) INTO n_count FROM CUSTOMER WHERE cus_id = new_id;
    
	IF n_count > 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(new_id AS CHAR), ' da ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    
	UPDATE CUSTOMER
    SET cus_id = new_id
    WHERE cus_id = id;
END 
$$


delimiter ;
DROP PROCEDURE IF EXISTS Update_Customer_Name;
delimiter $$
CREATE PROCEDURE Update_Customer_Name
(id INT, first_name VARCHAR(10), last_name VARCHAR(20))
BEGIN
	DECLARE c_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    
	UPDATE CUSTOMER
    SET fname = first_name, lname = last_name
    WHERE cus_id = id;
END 
$$

delimiter ;
DROP PROCEDURE IF EXISTS Update_Customer_Phone_Number;
delimiter $$
CREATE PROCEDURE Update_Customer_Phone_Number
(id INT, p_num CHAR(10))
BEGIN
	DECLARE c_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    IF LENGTH(p_num) != 10 THEN
		SET @error_msg = CONCAT('So dien thoai phai gom chinh xac 10 chu so');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	UPDATE CUSTOMER
    SET phone_num = p_num
    WHERE cus_id = id;
END 
$$


delimiter ;
DROP PROCEDURE IF EXISTS Update_Customer_Add_Num;
delimiter $$

CREATE PROCEDURE Update_Customer_Add_Num
(id INT, new_add_num INT)
BEGIN
	DECLARE c_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    
	UPDATE CUSTOMER
    SET add_num = new_add_num
    WHERE cus_id = id;
END 
$$


delimiter ;
DROP PROCEDURE IF EXISTS Update_Customer_Sex;
delimiter $$

CREATE PROCEDURE Update_Customer_Sex
(id INT, S CHAR(1))
BEGIN
	DECLARE c_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	UPDATE CUSTOMER
    SET sex = S
    WHERE cus_id = id;
END 
$$

delimiter ;
DROP PROCEDURE IF EXISTS Update_Customer_Email;
delimiter $$
CREATE PROCEDURE Update_Customer_Email
(id INT, mail VARCHAR(40))
BEGIN
	DECLARE c_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	IF 
    mail NOT REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$'
    THEN
		SET @error_msg = 'Dia chi email khong hop le';
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	UPDATE CUSTOMER
    SET gmail = mail
    WHERE cus_id = id;
END 
$$


delimiter ;
DROP PROCEDURE IF EXISTS Update_Customer_Reg_Date;
delimiter $$
CREATE PROCEDURE Update_Customer_Reg_Date
(id INT, new_reg_date DATE)
BEGIN
	DECLARE c_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Khach hang voi ID: ',CAST(id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	UPDATE CUSTOMER
    SET res_date = new_reg_date
    WHERE cus_id = id;
END
$$



