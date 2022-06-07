USE coffee_db;

DROP PROCEDURE IF EXISTS insert_employee;

DELIMITER //
CREATE PROCEDURE insert_employee (
    fname       VARCHAR(10), 
    lname       VARCHAR(20), 
    new_emp_id  INT, 
    br_id       INT,
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
    IF @e_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Employee ID must be unique.';
    ELSEIF sex <> 'M' AND sex <> 'F' THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid value! Please recheck your input';
    ELSEIF bdate > CURDATE() THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE        
        INSERT INTO EMPLOYEE
        VALUES (fname, lname, new_emp_id, br_id, bdate, address, sex, startdate, ssn, 
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
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE new_shift_num = shift_num);
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
    workdate	    DATE,
    cur_br_id		INT)
BEGIN
    SET @s_count = 0;
    SET @e_count = 0;
    SET @br_count = 0;
    SET @m_count = (SELECT COUNT(*) FROM SHIFT WHERE cur_shift_num = shift_num);
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE cur_emp_id = emp_id);
    SET @br_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE cur_br_id = emp_id);
    IF @s_count = 0 OR e_count = 0 OR br_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input';
    ELSE
        INSERT INTO EMP_SHIFT
        VALUES (cur_shift_num, emp_id, workdate, br_id);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_product;

DELIMITER //
CREATE PROCEDURE insert_product (
    new_pr_id		INT,
	pr_name		VARCHAR(30))
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE new_pr_id = pr_id);
    IF @pr_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Product ID must be unique';
    ELSE
        INSERT INTO PRODUCT
        VALUES (new_pr_id, pr_name);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_prod_price;

DELIMITER //
CREATE PROCEDURE insert_prod_price (
    cur_pr_id	INT,
	size		VARCHAR(30),
    price       INT)
BEGIN
    SET @pr_count = 0;
    SET @pr_count = (SELECT COUNT(*) FROM PR_PRICE WHERE cur_pr_id = pr_id);
    IF @pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input';
    ELSE
        INSERT INTO PR_PRICE
        VALUES (cur_pr_id, size, price);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_promotion;

DELIMITER //
CREATE PROCEDURE insert_promotion (
    new_promo_id	INT,
	start_date      DATE,
    end_date        DATE)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PROMOTION WHERE new_promo_id = promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE
        INSERT INTO PROMOTION
        VALUES (new_promo_id, start_date, end_date);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_perc_promo;

DELIMITER //
CREATE PROCEDURE insert_perc_promo (
    new_promo_id	INT,
    promo_per	    INT,
	min_num		    INT,
    start_date      INT,
    end_date        INT)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PERC_PROMOTION WHERE new_promo_id = promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE
        CALL insert_promotion(new_promo_id, start_date, end_date);
        INSERT INTO PERC_PROMOTION
        VALUES (new_promo_id, promo_per, min_num);
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
    SET @promo_count = (SELECT COUNT(*) FROM GIFT_PROMOTION WHERE new_promo_id = promo_id);
    IF @promo_count <> 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Duplicate found! Promotion ID must be unique';
    ELSEIF start_date > end_date THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Invalid Daytime! Please recheck your input';
    ELSE
        CALL insert_promotion(new_promo_id, start_date, end_date);
        INSERT INTO GIFT_PROMOTION
        VALUES (new_promo_id, buy_num, gift_num);
	END IF;
END//
DELIMITER ;


DROP PROCEDURE IF EXISTS insert_pr_apply_promo;

DELIMITER //
CREATE PROCEDURE insert_pr_apply_promo (
    cur_promo_id	INT,
    cur_pr_id	    INT)
BEGIN
    SET @promo_count = 0;
    SET @pr_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM GIFT_PROMOTION WHERE cur_promo_id = promo_id);
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE cur_pr_id = pr_id);
    IF @promo_count = 0 OR pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
    ELSE
        CALL insert_promotion(new_promo_id, start_date, end_date);
        INSERT INTO PR_APPLY_PROMO
        VALUES (cur_promo_id, cur_pr_id);
	END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS insert_pr_gift;

DELIMITER //
CREATE PROCEDURE insert_pr_gift (
    cur_promo_id	INT,
    cur_pr_id	    INT)
BEGIN
    SET @promo_count = 0;
    SET @pr_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM GIFT_PROMOTION WHERE cur_promo_id = promo_id);
    SET @pr_count = (SELECT COUNT(*) FROM PRODUCT WHERE cur_pr_id = pr_id);
    IF @promo_count = 0 OR pr_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Please recheck your input.';
    ELSE
        CALL insert_promotion(new_promo_id, start_date, end_date);
        INSERT INTO PRODUCT_GIFT
        VALUES (cur_promo_id, cur_pr_id);
	END IF;
END//
DELIMITER ;

