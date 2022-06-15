USE coffee_db;
-- Update_bank_employee
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

-- Update_salary
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

-- employee_workhour 
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

-- employee_salary_rate
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

-- update_employee_branch
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

-- shift
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

-- emp_shift
DROP PROCEDURE IF EXISTS update_emp_shift;

DELIMITER //
CREATE PROCEDURE update_emp_shift(
    cur_emp_id          CHAR(6),    
    new_shift_num       CHAR(6),
    cur_workdate        DATE)
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMP_SHIFT WHERE emp_id = cur_emp_id AND workdate = cur_workdate);
    SET @s_count = 0;
    SET @s_count = (SELECT COUNT(*) FROM SHIFT WHERE shift_num = new_shift_num);
    IF @s_count = 0 OR @e_count THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        UPDATE EMP_SHIFT
        SET shift_num = new_shift_num
        WHERE emp_id = cur_emp_id AND workdate = cur_workdate;
    END IF;
END//
DELIMITER ;

-- product_name
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

-- product_type
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

-- product_img
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

-- product_price
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
    ELSEIF price < 0 THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid value! Price must be a positive value.';
    ELSE
        UPDATE PRODUCT
        SET price = new_pr_price 
        WHERE pr_id = cur_pr_id AND size = cur_size;
    END IF;
END//
DELIMITER ;

-- update_promotion_perc
DROP PROCEDURE IF EXISTS update_promotion_perc;

DELIMITER //
CREATE PROCEDURE update_promotion_perc(
    cur_promo_id	CHAR(6),
	new_perc_val    INT)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PROMOTION WHERE promo_id = cur_promo_id);
    IF @promo_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Promotion ID not available.';
    ELSEIF new_perc_val < 0 THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid value! Promotion percent value must be a positive value.';
    ELSE
        UPDATE PROMOTION
        SET promo_per = new_perc_val 
        WHERE promo_id = cur_promo_id;
    END IF;
END//
DELIMITER ;

-- update_promotion_date
DROP PROCEDURE IF EXISTS update_promotion_perc;

DELIMITER //
CREATE PROCEDURE update_promotion_perc(
    cur_promo_id	CHAR(6),
	new_start_day    DATE,
    new_end_day     DATE)
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PROMOTION WHERE promo_id = cur_promo_id);
    IF @promo_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Promotion ID not available.';
    ELSEIF new_start_day < new_end_day THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Invalid daytime! Start day can not be after end day.';
    ELSE
        UPDATE PROMOTION
        SET promo_per = new_perc_val 
        WHERE promo_id = cur_promo_id;
    END IF;
END//
DELIMITER ;

-- insert/update product to an order: if product exist, then add new quantity
DROP PROCEDURE IF EXISTS proc_update_prod_order;
DELIMITER //
CREATE PROCEDURE proc_update_prod_order (
	add_order_id	INT,
    add_prod_id		INT,
	add_size		CHAR(1),
    add_price		INT,
    add_quantity 	INT	
)
BEGIN
    IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = add_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(add_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    IF (SELECT pr_id FROM PRODUCT WHERE PRODUCT.pr_id = add_prod_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing product ID: ', CAST(add_prod_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    IF (SELECT * FROM PRODUCT_ORDER WHERE pr_id = add_prod_id AND order_id = add_order_id) = NULL THEN
		INSERT INTO PRODUCT_ORDER VALUES(add_prod_id, add_order_id);
		INSERT INTO PRODUCT_ORDER_DETAIL VALUES(add_prod_id, add_order_id, add_size, add_price, add_quantity);
	ELSE 
		UPDATE 	PRODUCT_ORDER_DETAIL
        SET	   	PRODUCT_ORDER_DETAIL.price = add_price,
                PRODUCT_ORDER_DETAIL.quantity = add_quantity
		WHERE	PRODUCT_ORDER_DETAIL.pr_id = add_prod_id 
				AND PRODUCT_ORDER_DETAIL.order_id = add_order_id
				AND	PRODUCT_ORDER_DETAIL.size = add_size;
	END IF;
END //
DELIMITER ;


# update promotion redemption 
DROP PROCEDURE IF EXISTS proc_update_order_promo_red;
DELIMITER //
CREATE PROCEDURE proc_update_order_promo_red (
	mod_order_id	INT,
    redem_point		INT
)
BEGIN
	DECLARE total_money INT DEFAULT 0;
    DECLARE limit_point INT DEFAULT 0;
    DECLARE promo_id 	INT	DEFAULT 0;
	IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(mod_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    SET promo_id = (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id);
    IF promo_id <> 0 AND redem_point <> 0 THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Only apply one type of promotion at a time!';
    END IF;
    
    SET total_money = mod_order.total;
    SET limit_point = total_money * 0.7 / 1000;
    IF limit_point < redem_point THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = "Redemption promotion cannot greater than 70% of Order\'s total money!";
	END IF;
    
    UPDATE PR_ORDER
    SET PR_ORDER.promo_red = redem_point
    WHERE PR_ORDER.order_id = mod_order_id;
END //
DELIMITER ;


# change receive address 
DROP PROCEDURE IF EXISTS proc_update_receive_address;
DELIMITER //
CREATE PROCEDURE proc_update_receive_address (
	mod_order_id	INT,
    mod_address		VARCHAR(100)
)
BEGIN
    IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(mod_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    UPDATE PR_ORDER
    SET PR_ORDER.rec_address = mod_address
    WHERE PR_ORDER.order_id = mod_order_id; 
END //
DELIMITER ;


# update customer id in order (before paying)
DROP PROCEDURE IF EXISTS proc_update_cus_id;
DELIMITER //
CREATE PROCEDURE proc_update_cus_id (
	mod_order_id	CHAR(6),
    mod_cus_id		CHAR(6)
)
BEGIN	
    DECLARE order_status BOOL DEFAULT FALSE;
    SET order_status = (SELECT stat FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id);
    IF order_status = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(mod_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    IF order_status = TRUE THEN
		SET @error_msg = CONCAT('Order ID: ', CAST(mod_order_id as CHAR), ' had been paid. Cannot change customer ID.');
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
	UPDATE PR_ORDER
    SET PR_ORDER.cus_id = mod_cus_id
    WHERE PR_ORDER.order_id = mod_order_id; 
END //
DELIMITER ;


# change status flag (false -> true: paid)
DROP PROCEDURE IF EXISTS proc_set_order_status;
DELIMITER //
CREATE PROCEDURE proc_set_order_status(
	mod_order_id 	CHAR(6)
)
BEGIN
	IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(mod_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    UPDATE PR_ORDER
    SET PR_ORDER.stat = TRUE
    WHERE PR_ORDER.order_id = mod_order_id;
END //
DELIMITER ;


# update promotion
DROP PROCEDURE IF EXISTS proc_update_order_promo_id; 
DELIMITER //
CREATE PROCEDURE proc_update_order_promo_id (
	mod_order_id 	CHAR(6),
	new_promo_id 	CHAR(6)
)
BEGIN
	DECLARE promo_red INT DEFAULT 0;
	IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(mod_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    SET promo_red = (SELECT promo_red FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id);
    IF promo_red <> 0 AND new_promo_id <> 0 THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Only apply one type of promotion at a time.';
	END IF;
    
    UPDATE PR_ORDER 
    SET PR_ORDER.promo_id = new_promo_id
    WHERE PR_ORDER.order_id = mod_order_id;
END //
DELIMITER ;

-- Branch
DROP PROCEDURE IF EXISTS update_mng_branch;

DELIMITER //
CREATE PROCEDURE update_mng_branch(
	ibr_id		CHAR(6), 
    imng_id 	CHAR(6)
)
BEGIN
	DECLARE br_exs INT DEFAULT 0;
    DECLARE mng_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_exs FROM BRANCH WHERE br_id = ibr_id;
    SELECT COUNT(*) INTO mng_exs FROM EMPLOYEE WHERE emp_id = imng_id;

	IF (br_exs = 0) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    IF (mng_exs = 0) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing manager';
	END IF;
    
    IF (SELECT br_id FROM EMPLOYEE WHERE emp_id = imng_id) <> ibr_id THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This employee works at another branch';
	END IF;
    
	UPDATE BRANCH
    SET mng_id = imng_id
    WHERE br_id = ibr_id;
END //
DELIMITER ;

-- Furniture
DROP PROCEDURE IF EXISTS update_fur_quantity;

DELIMITER //
CREATE PROCEDURE update_fur_quantity(
	ifur_id		CHAR(6), 
    ibr_id 		CHAR(6), 
    iquantity 	INT
)
BEGIN 
	DECLARE br_exs INT DEFAULT 0;
    DECLARE fur_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_exs FROM BRANCH WHERE br_id = ibr_id;
    SELECT COUNT(*) INTO fur_exs FROM FURNITURE WHERE br_id = ibr_id AND fur_id = ifur_id;
    
	IF br_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    IF fur_exs = 0 THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing furniture';
	END IF;
    
	UPDATE FURNITURE 
    SET quantity = iquantity
    WHERE fur_id = ifur_id AND br_id = ibr_id;
END //
DELIMITER ;

-- Delivery service
DROP PROCEDURE IF EXISTS update_ser_name;

DELIMITER //
CREATE PROCEDURE update_ser_name(
	ideli_ser_id	CHAR(6),
    new_ser_name	VARCHAR(20)
)
BEGIN
	DECLARE deli_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO deli_exs FROM DELI_SERVICE WHERE deli_ser_id = ideli_ser_id;
    
	IF deli_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing delivery service';
	END IF;
    
    UPDATE DELI_SERVICE
	SET deli_ser_name = new_ser_name
	WHERE deli_ser_id = ideli_ser_id;
END //
DELIMITER ;


