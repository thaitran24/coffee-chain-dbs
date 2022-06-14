USE coffee_db;

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
			SET MESSAGE_TEXT = 'Duplicate found! Product ID has already had its price';
    ELSE
        INSERT INTO PR_PRICE
        VALUES (cur_pr_id, cur_size, price);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_perc_promo;

DELIMITER //
CREATE PROCEDURE insert_perc_promo (
    new_promo_id	CHAR(6),
    promo_per	    INT,
    start_date      INT,
    end_date        INT)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PERC_PROMOTION WHERE promo_id = new_promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique.';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! End date can not be before start day.';
    ELSE
        INSERT INTO PERC_PROMOTION
        VALUES (new_promo_id, promo_per, start_date, end_date);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_table;

DELIMITER //
# This procedure can update any table with any condition
# List of parameter:
# tablename : name of the update table
# set_value : the column and value that desires to update, deli = comma (',')
# cond      : condition of update, which included in WHERE clause
CREATE PROCEDURE update_table (
    tablename       VARCHAR(100),    
    set_value       VARCHAR(100),
    cond	        VARCHAR(100))
BEGIN
    SET SQL_SAFE_UPDATES = 0;
    IF cond = '' OR cond = ' ' THEN
        SET @up = CONCAT(" UPDATE ", tablename,
                         " SET ", set_value);
        PREPARE run_update FROM @up;
        EXECUTE run_update;
    ELSE
        SET @up = CONCAT(" UPDATE ", tablename,        
                         " SET ", set_value,
                         " WHERE ", cond);
        PREPARE run_update FROM @up;
        EXECUTE run_update;
	END IF;
    SET SQL_SAFE_UPDATES = 1;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_employee_bankacc;

DELIMITER //
CREATE PROCEDURE update_employee_bankacc (
    cur_emp_id      CHAR(6),    
    new_bank_acc    VARCHAR(16))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        UPDATE EMPLOYEE
        SET b_account = new_bank_acc
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_employee_salary_rate;

DELIMITER //
CREATE PROCEDURE update_employee_salary_rate (
    cur_emp_id          CHAR(6),    
    new_salary_rate     FLOAT)
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        UPDATE EMPLOYEE
        SET salary_rate = new_salary_rate
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_employee_workhour;

DELIMITER //
CREATE PROCEDURE update_employee_workhour (
    cur_emp_id          CHAR(6),    
    new_workhour        INT)
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        UPDATE EMPLOYEE
        SET work_hour = new_workhour
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_employee_salary_rate;

DELIMITER //
CREATE PROCEDURE update_employee_salary_rate (
    cur_emp_id             CHAR(6),    
    new_position           VARCHAR(20))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        UPDATE EMPLOYEE
        SET position = new_position
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_employee_branch;

DELIMITER //
CREATE PROCEDURE update_employee_branch(
    cur_emp_id             CHAR(6),    
    new_br_id              VARCHAR(20))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    SET @br_count = 0;
    SET @br_count = (SELECT COUNT(*) FROM BRANCH WHERE br_id = new_br_id);
    IF @e_count = 0 OR @br_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        UPDATE EMPLOYEE
        SET br_id = new_br_id
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_shift;

DELIMITER //
CREATE PROCEDURE update_shift(
    cur_shift_num       CHAR(6),    
    new_start_time      TIME,
    new_end_time        TIME)
BEGIN
    SET @s_count = 0;
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = cur_shift_num);
    IF @s_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSEIF new_start_time > new_end_time THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! End time can not be before start time.';
    ELSE
        UPDATE SHIFT
        SET start_time = new_start_time, end_time = new_end_time
        WHERE shift_num = cur_shift_num;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_emp_shift;

DELIMITER //
CREATE PROCEDURE update_emp_shift(
    cur_emp_id          CHAR(6),    
    new_shift_num       CHAR(6))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMP_SHIFT WHERE emp_id = cur_emp_id);
    SET @s_count = 0;
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = new_shift_num);
    IF @s_count = 0 OR @e_count THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        UPDATE EMP_SHIFT
        SET shift_num = new_shift_num
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_product_name;

DELIMITER //
CREATE PROCEDURE update_product_name(
    cur_pr_id	CHAR(6),
	new_pr_name	VARCHAR(100))
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE pr_id = cur_pr_id);
    IF @pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Product ID not available.';
    ELSE
        UPDATE PRODUCT
        SET pr_name = new_pr_name 
        WHERE pr_id = cur_pr_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_product_type;

DELIMITER //
CREATE PROCEDURE update_product_type(
    cur_pr_id	CHAR(6),
	new_pr_type	VARCHAR(30))
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE pr_id = cur_pr_id);
    IF @pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Product ID not available.';
    ELSE
        UPDATE PRODUCT
        SET pr_type = new_pr_type 
        WHERE pr_id = cur_pr_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_product_img;

DELIMITER //
CREATE PROCEDURE update_product_img(
    cur_pr_id	CHAR(6),
	new_pr_img	VARCHAR(150))
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE pr_id = cur_pr_id);
    IF @pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Product ID not available.';
    ELSE
        UPDATE PRODUCT
        SET pr_img = new_pr_img 
        WHERE pr_id = cur_pr_id;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS update_product_price;

DELIMITER //
CREATE PROCEDURE update_product_price(
    cur_pr_id	CHAR(6),
	cur_size	CHAR(1),
    new_pr_price INT)
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PR_PRICE WHERE pr_id = cur_pr_id AND size = cur_size);
    IF @pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Product ID not available.';
    ELSE
        UPDATE PRODUCT
        SET price = new_pr_price 
        WHERE pr_id = cur_pr_id AND size = cur_size;
    END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS delete_product_size;

DELIMITER //
CREATE PROCEDURE delete_product_size(
    cur_pr_id	CHAR(6),
	cur_size	CHAR(1))
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PR_PRICE WHERE pr_id = cur_pr_id AND size = cur_size);
    IF @pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Product ID not available.';
    ELSE
        DELETE FROM PR_PRICE
        WHERE pr_id = cur_pr_id AND size = cur_size;
        SET @pr_count = (SELECT COUNT(*) FROM PR_PRICE WHERE pr_id = cur_pr_id);
        IF @pr_count = 0 THEN
            DELETE FROM PRODUCT
            WHERE pr_id = cur_pr_id;
        END IF;
    END IF;
END//
DELIMITER ;



