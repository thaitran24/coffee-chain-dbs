USE coffee_db;

DROP PROCEDURE IF EXISTS insert_employee;

DELIMITER //
CREATE PROCEDURE insert_employee (
    fname       VARCHAR(10), 
    lname       VARCHAR(20), 
    new_emp_id  INT, 
    cur_br_id   INT,
    bdate       DATE,
    address     VARCHAR(100),
    sex         CHAR(1),
    startdate   DATE, 
    ssn         CHAR(10), 
    b_account   VARCHAR(16), 
    salary_rate FLOAT, 
    phone_num   CHAR(10), 
    work_hour   INT,
    gmail       VARCHAR(40),
    degree      VARCHAR(40),
    position    VARCHAR(20))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = new_emp_id);
    SET @br_count = 0;
    SET @br_count = (SELECT COUNT(*) FROM BRANCH WHERE br_id = cur_br_id);
    IF @e_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Employee ID must be unique.';
    ELSEIF sex <> 'M' AND sex <> 'F' AND
    gmail NOT REGEXP '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$' AND
    length(phone_num) != 10 AND 
    phone_num NOT REGEXP '0[0-9]+'
    THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid value! Please recheck your input';
    ELSEIF bdate > CURDATE() THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSEIF @br_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input';
    ELSE        
        INSERT INTO EMPLOYEE
        VALUES (fname, lname, new_emp_id, cur_br_id, bdate, address, sex, startdate, ssn, 
                b_account, salary_rate, phone_num, work_hour, gmail, degree, position);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_shift;

DELIMITER //
CREATE PROCEDURE insert_shift (
    new_shift_num	INT,
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
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE
        INSERT INTO SHIFT
        VALUES (new_shift_num, start_time, end_time);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_emp_shift;

DELIMITER //
CREATE PROCEDURE insert_emp_shift (
    cur_shift_num	INT,
	cur_emp_id		INT,
    workdate	    DATE)
BEGIN
    SET @s_count = 0;
    SET @e_count = 0;
    SET @br_count = 0;
    SET @m_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = cur_shift_num);
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    SET @br_count = (SELECT br_id FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @s_count = 0 OR e_count = 0 OR br_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input';
    ELSE
        INSERT INTO EMP_SHIFT
        VALUES (cur_shift_num, emp_id, workdate, @br_count);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_product;

DELIMITER //
CREATE PROCEDURE insert_product (
    new_pr_id   CHAR(6),
	pr_name		VARCHAR(30),
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
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input';
    ELSEIF @price_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Product ID has already had its price';
    ELSE
        INSERT INTO PR_PRICE
        VALUES (cur_pr_id, cur_size, price);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_promotion;

DELIMITER //
CREATE PROCEDURE insert_promotion (
    new_promo_id	INT,
	start_date      DATE,
    end_date        DATE,
    promo_type	    BOOL)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PROMOTION WHERE promo_id = new_promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE
        INSERT INTO PROMOTION
        VALUES (new_promo_id, start_date, end_date, promo_type);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_perc_promo;

DELIMITER //
CREATE PROCEDURE insert_perc_promo (
    new_promo_id	INT,
    promo_per	    INT,
    start_date      INT,
    end_date        INT)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PERC_PROMOTION WHERE promo_id = new_promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE
        CALL insert_promotion(new_promo_id, start_date, end_date, 0);
        INSERT INTO PERC_PROMOTION
        VALUES (new_promo_id, promo_per);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_gift_promo;

DELIMITER //
CREATE PROCEDURE insert_gift_promo (
    new_promo_id	INT,
    buy_num	        INT,
	gift_num		INT,
    start_date      INT,
    end_date        INT)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM GIFT_PROMOTION WHERE promo_id = new_promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE
        CALL insert_promotion(new_promo_id, start_date, end_date, 1);
        INSERT INTO GIFT_PROMOTION
        VALUES (new_promo_id, buy_num, gift_num);
	END IF;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS insert_pr_apply_promo;

DELIMITER //
CREATE PROCEDURE insert_pr_apply_promo (
    cur_promo_id	INT,
    cur_pr_id	    CHAR(6))
BEGIN
    SET @promo_count = 0;
    SET @pr_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM GIFT_PROMOTION WHERE promo_id = cur_promo_id);
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE pr_id = cur_pr_id);
    IF @promo_count = 0 OR pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
    ELSE
        INSERT INTO PR_APPLY_PROMO
        VALUES (cur_promo_id, cur_pr_id);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_pr_gift;

DELIMITER //
CREATE PROCEDURE insert_pr_gift (
    cur_promo_id	INT,
    cur_pr_id	    CHAR(6))
BEGIN
    SET @promo_count = 0;
    SET @pr_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM GIFT_PROMOTION WHERE promo_id = cur_promo_id);
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE pr_id = cur_pr_id);
    IF @promo_count = 0 OR pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
    ELSE
        INSERT INTO PRODUCT_GIFT
        VALUES (cur_promo_id, cur_pr_id);
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
    cur_emp_id      INT,    
    new_bank_acc    VARCHAR(16))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
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
    cur_emp_id          INT,    
    new_salary_rate     FLOAT)
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
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
    cur_emp_id          INT,    
    new_workhour        INT)
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
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
    cur_emp_id             INT,    
    new_position           VARCHAR(20))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
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
    cur_emp_id             INT,    
    new_br_id              VARCHAR(20))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    SET @br_count = 0;
    SET @br_count = (SELECT COUNT(*) FROM BRANCH WHERE br_id = new_br_id);
    IF @e_count = 0 OR @br_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
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
    cur_shift_num       INT,    
    new_start_time      TIME,
    new_end_time        TIME)
BEGIN
    SET @s_count = 0;
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = cur_shift_num);
    IF @s_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
    ELSEIF new_start_time > new_end_time THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
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
    cur_emp_id          INT,    
    new_shift_num       INT)
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMP_SHIFT WHERE emp_id = cur_emp_id);
    SET @s_count = 0;
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = new_shift_num);
    IF @s_count = 0 OR @e_count THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
    ELSE
        UPDATE EMP_SHIFT
        SET shift_num = new_shift_num
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;



