USE coffee_db;

-- Employee

DROP PROCEDURE IF EXISTS insert_employee;

DELIMITER //
CREATE PROCEDURE insert_employee (
    fname       VARCHAR(10), 
    lname       VARCHAR(20), 
    new_emp_id  CHAR(6), 
    bdate       DATE,
    address     VARCHAR(100),
    sex         CHAR(1),
    startdate   DATE, 
    ssn         CHAR(11), 
    b_account   VARCHAR(19), 
    salary_rate FLOAT, 
    phone_num   CHAR(10), 
    work_hour   INT,
    email       VARCHAR(40),
    degree      VARCHAR(40),
    position    VARCHAR(20),
    cur_mng_id  CHAR(6))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = new_emp_id);
    SET @cur_br_id = (SELECT br_id FROM EMPLOYEE WHERE emp_id = cur_mng_id);
    IF @e_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Employee ID must be unique.';
    ELSEIF sex <> 'M' AND sex <> 'F' AND
    email NOT REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$' AND
    length(phone_num) != 10 AND 
    phone_num NOT REGEXP '0[0-9]+'
    THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid value! Please input the correct format of contact.';
    ELSEIF (YEAR(CURDATE()) - YEAR(bdate)) < 18 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid value! Employee age must be 18 or older.';
    ELSEIF @cur_br_id = NULL THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Manager ID not available.';
    ELSE        

        INSERT INTO EMPLOYEE
        VALUES (fname, lname, new_emp_id, @cur_br_id, bdate, address, sex, startdate, ssn, 
                b_account, salary_rate, phone_num, work_hour, email, degree, position, cur_mng_id);
	END IF;
END//
DELIMITER ;

-- Shift
DROP PROCEDURE IF EXISTS insert_shift;

DELIMITER //
CREATE PROCEDURE insert_shift (
    new_shift_num	CHAR(6),
    start_time	    TIME,
    end_time	    TIME)
BEGIN
    SET @s_count = 0;
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = new_shift_num);
    IF @s_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Shift ID must be unique.';
    ELSEIF start_time > end_time THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! End time can not be before start time.';
    ELSE
        INSERT INTO SHIFT
        VALUES (new_shift_num, start_time, end_time);
	END IF;
END//
DELIMITER ;

-- Workdate
DROP PROCEDURE IF EXISTS insert_workdate;

DELIMITER //
CREATE PROCEDURE insert_workdate (
    new_workdate    TIME)
BEGIN
    SET @w_count = 0;
    SET @w_count = (SELECT COUNT(*) FROM WORKDATE WHERE workdate = new_workdate);
    IF @s_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Workdate has already been inserted.';
    ELSE
        INSERT INTO WORKDATE
        VALUES (new_workdate);
	END IF;
END//
DELIMITER ;

-- Imployee_Emp_Shift
DROP PROCEDURE IF EXISTS insert_emp_shift;

DELIMITER //
CREATE PROCEDURE insert_emp_shift (
    cur_shift_num	CHAR(6),
	cur_emp_id		CHAR(6),
    cur_workdate	    DATE)
BEGIN
    SET @s_count = 0;
    SET @e_count = 0;
    SET @br_count = 0;
    SET @w_count = 0;
    SET @k_count = 0;
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = cur_shift_num);
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    SET @br_count = (SELECT br_id FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    SET @w_count = (SELECT COUNT(*) FROM WORKDATE WHERE workdate = cur_workdate);
    SET @k_count = (SELECT COUNT(*) FROM EMP_SHIFT WHERE workdate = cur_workdate AND emp_id = cur_emp_id AND shift_num = cur_shift_num);
    IF @s_count = 0 OR @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Shift and Employee must be available.';
    ELSEIF @k_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Redeclared value! This shift for employee in that day has been set.';
    ELSE
        INSERT INTO EMP_SHIFT
        VALUES (cur_shift_num, emp_id, workdate, @br_count);
        IF @w_count = 0 THEN
            INSERT INTO WORKDATE
            VALUES (cur_workdate);
        END IF;
	END IF;
END//
DELIMITER ;


-- Product
DROP PROCEDURE IF EXISTS insert_product;

DELIMITER //
CREATE PROCEDURE insert_product (
    new_pr_id   CHAR(6),
	pr_name		VARCHAR(100),
    pr_type		VARCHAR(30),
    pr_img		VARCHAR(150))
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE pr_id = new_pr_id);
    IF @pr_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Product ID must be unique';
    ELSE
        INSERT INTO PRODUCT
        VALUES (new_pr_id, pr_name, pr_type, pr_img);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_prod_price;

DELIMITER //
CREATE PROCEDURE insert_prod_price (
    cur_pr_id	CHAR(6),
	cur_size    VARCHAR(1),
    price       INT)
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE pr_id = cur_pr_id);
    SET @price_count = 0;
    SET @price_count = (SELECT COUNT(*) FROM PR_PRICE WHERE pr_id = cur_pr_id AND size = cur_size);
    IF @pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Product ID not available.';
    ELSEIF @price_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Product ID with this size has already had its price';
    ELSEIF price < 0 THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid value! Price must be a positive value.';
    ELSE
        INSERT INTO PR_PRICE
        VALUES (cur_pr_id, cur_size, price);
	END IF;
END//
DELIMITER ;

-- Promotion
DROP PROCEDURE IF EXISTS insert_perc_promo;

DELIMITER //
CREATE PROCEDURE insert_perc_promo (
    new_promo_id	CHAR(6),
    promo_per	    INT,
    start_date      INT,
    end_date        INT)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PROMOTION WHERE promo_id = new_promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique.';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! End date can not be before start day.';
    ELSEIF promo_per < 0 THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid value! Promotion percent value must be a positive value.';
    ELSE
        INSERT INTO PROMOTION
        VALUES (new_promo_id, promo_per, start_date, end_date);
	END IF;
END//
DELIMITER ;

-- Branch
DROP PROCEDURE IF EXISTS insert_branch;
DELIMITER //
CREATE PROCEDURE insert_branch(
	ibr_id		CHAR(6), 
    imng_id 	CHAR(6), 
    iaddress 	VARCHAR(100)
)
BEGIN
	DECLARE br_num INT DEFAULT 0;
    DECLARE mng_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_num FROM BRANCH WHERE br_id = ibr_id;
    SELECT COUNT(*) INTO mng_exs FROM EMPLOYEE WHERE emp_id = imng_id;
    
	IF br_num > 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The branch ID has already registered';
	END IF;
    
    IF mng_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The manager ID does not exist';
	END IF;
    SET @br_check = (SELECT br_id FROM EMPLOYEE WHERE emp_id = imng_id);
    IF  @br_check <> ibr_id AND @br_check <> "B00000" THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This employee works at another branch';
	END IF;
    
	INSERT INTO BRANCH 
    VALUES (ibr_id, imng_id, iaddress);
END //
DELIMITER ;

-- FURNITURE
DROP PROCEDURE IF EXISTS insert_furniture;

DELIMITER //
CREATE PROCEDURE insert_furniture(
	ifur_id		CHAR(6), 
    ibr_id 		CHAR(6), 
    ifurname 	VARCHAR(20), 
    iquantity 	INT
)
BEGIN
	DECLARE count INT DEFAULT 0;
	DECLARE br_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_exs FROM BRANCH WHERE br_id = ibr_id;
    
	IF br_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    SELECT COUNT(*) INTO count FROM FURNITURE WHERE fur_id = ifur_id AND br_id = ibr_id;
    
    IF count > 0 THEN
		UPDATE FURNITURE 
		SET quantity = quantity + iquantity 
		WHERE fur_id = ifur_id AND br_id = ibr_id;
	ELSE
		INSERT INTO FURNITURE
        VALUES(ifur_id, ibr_id, ifurname, iquantity);
	END IF;
END //
DELIMITER ;

-- DELI_SERVICE
DROP PROCEDURE IF EXISTS insert_deliservice;
DELIMITER //
CREATE PROCEDURE insert_deliservice(
	ideli_ser_id 	CHAR(6), 
    ideli_ser_name VARCHAR(20)
)
BEGIN 
	DECLARE deli_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO deli_exs FROM DELI_SERVICE WHERE deli_ser_id = ideli_ser_id;

	IF deli_exs <> 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Delivery service existed';
	END IF;
            
	INSERT INTO DELI_SERVICE 
    VALUES(ideli_ser_id, ideli_ser_name);
END //
DELIMITER ;

-- Order 
DROP PROCEDURE IF EXISTS proc_insert_order;
DELIMITER //
CREATE PROCEDURE proc_insert_order (
	order_id	CHAR(6),
    order_date	DATE,
    order_time	TIME,
    promo_red	INT,	# khuyen mai quy doi
    total		INT,
    order_type	BOOL,	# 0: offline, 1: online
    rec_address	VARCHAR(100),	# noi nhan hang
    promo_id	CHAR(6),
    br_id		CHAR(6),
    cus_id		CHAR(6),
    emp_id		CHAR(6),
    stat		BOOL	# 0: chua thanh toan, 1: da thanh toan
) 
BEGIN
	IF order_id IN (SELECT order_id FROM PR_ORDER) THEN
		SET @error_msg = CONCAT('Order ID: ', CAST(mod_order_id as CHAR), ' has already existed');
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    IF cus_id NOT IN (SELECT cus_id FROM CUSTOMER) THEN
		SET @error_msg = CONCAT('Customer ID: ', CAST(cus_id as CHAR), ' do not exist');
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    IF emp_id NOT IN (SELECT emp_id FROM EMPLOYEE) THEN
		SET @error_msg = CONCAT('Employee ID: ', CAST(emp_id as CHAR), ' do not exist');
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    IF br_id NOT IN (SELECT br_id FROM BRANCH) THEN
		SET @error_msg = CONCAT('Branch ID: ', CAST(br_id as CHAR), ' do not exist');
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
	IF (promo_red <> 0 AND promo_id <> 0) THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Only apply one type of promotion at a time';
    END IF;
    
	INSERT INTO PR_ORDER VALUES(order_id, order_date, order_time, promo_red, total, order_type,
								red_address, promo_id, br_id, cus_id, emp_id, stat);
END //
DELIMITER ;

-- INSERT PROCEDURE BATCH
DROP PROCEDURE IF EXISTS Insert_Batch;
DELIMITER //
CREATE PROCEDURE Insert_Batch(
    new_id CHAR(6), 
    new_m_id CHAR(6),
    new_m_name VARCHAR(20), 
    new_mgr_id CHAR(6), 
    new_i_date DATE, 
    new_e_date DATE, 
    new_quantity FLOAT)
BEGIN
	DECLARE b_count INT DEFAULT 0;
	DECLARE e_count INT DEFAULT 0;
	DECLARE m_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = new_id;
	-- lo hang da ton tai
    IF b_count > 0 THEN
		SET @error_msg = CONCAT('Batch ID: ',CAST(new_id AS CHAR), ' has been declared');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	SELECT COUNT(*) INTO e_count FROM EMPLOYEE WHERE emp_id = new_mgr_id;
	-- nhan vien quan li khong ton tai
	IF e_count = 0 THEN
		SET @error_msg = CONCAT('Manager ID: ',CAST(new_mgr_id AS CHAR), ' unavailable.');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    -- loi nhap so luong
    IF new_quantity <= 0 THEN	
		SET @error_msg = CONCAT('Import quantity must be positive');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    -- loi nhap ngay 
    IF new_i_date >= new_e_date THEN
		SET @error_msg = CONCAT('Import date must be before expired day.');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg;	
	END IF;
    
	SELECT COUNT(*) INTO m_count FROM M_BATCH WHERE m_id = new_m_id AND m_name != new_m_name ANd ba_id != new_id;
	IF m_count > 0 THEN
		UPDATE M_BATCH
        SET m_name = new_m_name
        WHERE m_id = new_m_id;
    END IF;
        
	INSERT INTO M_BATCH 
	VALUES(new_id, new_m_id, new_m_name, new_mgr_id, new_i_date, new_e_date, new_quantity);
    
END//

-- Customer
DELIMITER ;
DROP PROCEDURE IF EXISTS Insert_Customer;
DELIMITER //
CREATE PROCEDURE Insert_Customer
(first_name VARCHAR(10), last_name VARCHAR(20), id CHAR(6), phone_number CHAR(10), s CHAR(1), add_number INT, mail VARCHAR(40), reg_date DATE)
BEGIN
	DECLARE c_count INT DEFAULT 0;

	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count > 0 THEN
		SET @error_msg = CONCAT('Customer ID: ',CAST(id AS CHAR), ' has been declared.');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	IF length(phone_number) != 10 THEN
		SET @error_msg = CONCAT('Phone number must have exact 10 digits.');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    IF 
    mail NOT REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$'
    THEN
		SET @error_msg = CONCAT('Invalid email.');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;
    
	INSERT INTO CUSTOMER
    VALUES(first_name, last_name, id, phone_number, s, add_number, mail, reg_date); 
END//


-- Material
DELIMITER ;
DROP PROCEDURE IF EXISTS Insert_Material;
DELIMITER //
CREATE PROCEDURE Insert_Material 
(new_id CHAR(6), new_name VARCHAR(20), new_quantity INT)
BEGIN
	DECLARE m_count INT DEFAULT 0;
    DECLARE n_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO m_count FROM MATERIAL WHERE m_id = new_id;
	SELECT COUNT(*) INTO n_count FROM MATERIAL WHERE m_name = new_name;

	-- nguyen lieu da ton tai
    IF m_count > 0 THEN
		SET @error_msg = CONCAT('Material with ID: ',CAST(new_id AS CHAR), ' has been declared');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    -- 2 nguyen lieu khac nhau nhung co cung ten
    IF n_count > 0 THEN
		SET @error_msg = CONCAT('Material with name: ',CAST(new_name AS CHAR), ' has been declared');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	INSERT INTO MATERIAL 
	VALUES(new_id, new_name, new_quantity);
END //