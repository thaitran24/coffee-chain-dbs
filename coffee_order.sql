USE coffee_db;

# insert new order
DROP PROCEDURE IF EXISTS proc_insert_order;
DELIMITER $$
CREATE PROCEDURE proc_insert_order (
	order_id	INT,
    order_date	DATE,
    order_time	TIME,
    promo_red	INT,	# khuyen mai quy doi
    total		INT,
    order_type	BOOL,	# 0: offline, 1: online
    rec_address	VARCHAR(100),		# noi nhan hang
    promo_id	INT,
    br_id		INT,
    cus_id		INT,
    emp_id		INT,
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
END $$
DELIMITER ;


# ??? trigger for creating new receipt when an ordern has been paid 
DROP TRIGGER IF EXISTS trig_create_receipt;
DELIMITER $$
CREATE TRIGGER trig_create_receipt AFTER UPDATE ON PR_ORDER 
FOR EACH ROW
BEGIN
	IF PR_ORDER.stat = TRUE THEN
		INSERT INTO RECEIPT VALUES(NEW.order_id, NEW.order_id, CURDATE(), CURTIME(), DEFAULT,
									NEW.promo_red, NEW.br_id, NEW.cus_id, NEW.total);
	END IF;
END $$
DELIMITER ;



# insert/update product to an order: if product exist, then add
DROP PROCEDURE IF EXISTS proc_update_prod_order;
DELIMITER $$
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
    
    SET @prod_order = (SELECT * FROM PRODUCT_ORDER WHERE pr_id = add_prod_id AND order_id = add_order_id AND add_size = size);
    IF @prod_order = NULL THEN
		INSERT INTO PRODUCT_ORDER VALUES(add_order_id, add_order_id, add_size, add_price, add_quantity);
	ELSE 
		UPDATE 	PRODUCT_ORDER
        SET	   	PRODUCT_ORDER.price = add_price,
                PRODUCT_ORDER.quantity = add_quantity
		WHERE	PRODUCT_ORDER.pr_id = add_order_id 
				AND PRODUCT_ORDER.order_id = add_order_id
				AND	PRODUCT_ORDER.size = add_size;
	END IF;
END $$
DELIMITER ;


# update promotion redemption 
DROP PROCEDURE IF EXISTS proc_update_order_promo_red;
DELIMITER $$
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
			SET MESSAGE_TEXT = 'Redemption promotion cannot greater than 70% of Order\'s total money!';
	END IF;
    
    UPDATE PR_ORDER
    SET PR_ORDER.promo_red = redem_point
    WHERE PR_ORDER.order_id = mod_order_id;
END $$
DELIMITER ;

# change receive address 
DROP PROCEDURE IF EXISTS proc_update_receive_address;
DELIMITER $$
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
END $$
DELIMITER ;


# update customer id in order (before paying)
DROP PROCEDURE IF EXISTS proc_update_cus_id;
DELIMITER $$
CREATE PROCEDURE proc_update_cus_id (
	mod_order_id	INT,
    mod_cus_id		INT
)
BEGIN
    IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(mod_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
	UPDATE PR_ORDER
    SET PR_ORDER.cus_id = mod_cus_id
    WHERE PR_ORDER.order_id = mod_order_id;
    # 
END $$
DELIMITER ;


# change status flag (false -> true: paid)
DROP PROCEDURE IF EXISTS proc_set_order_status;
DELIMITER $$
CREATE PROCEDURE proc_set_order_status(
	mod_order_id 	INT
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
END $$
DELIMITER ;


# update promotion
DROP PROCEDURE IF EXISTS proc_update_order_promo_id; 
DELIMITER $$
CREATE PROCEDURE proc_update_order_promo_id (
	mod_order_id 	INT,
	new_promo_id 	INT
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
    # NEED TRIGGER FOR 
END $$
DELIMITER ;


# calculate cus promotion: 1 point = 1,000 VND
DROP FUNCTION IF EXISTS func_cal_cus_promo;
DELIMITER $$
CREATE FUNCTION func_cal_cus_promo (
	mem_id		INT,
    redem_point	INT
) RETURNS INT DETERMINISTIC
BEGIN
	DECLARE cus_point INT DEFAULT 0;
    DECLARE promo_money INT DEFAULT 0;
    SET cus_point = (SELECT acc_point FROM CUSTOMER WHERE mem_id = CUSTOMER.cus_id);
    IF cus_point = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing customer ID: ', CAST(mem_id as CHAR));
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
            RETURN 0;
	ELSE 
		SET @error_msg = CONCAT('Customer ID: ', CAST(mem_id as CHAR), ' do not have enough points');
		IF cus_point < redem_point THEN
			SIGNAL SQLSTATE '01000'
				SET MESSAGE_TEXT = @error_msg;
				RETURN 0;
		END IF;

		SET promo_money = cus_point * 1000;
    END IF;
    UPDATE CUSTOMER
    SET CUSTOMER.promo_point = CUSTOMER.promo_point - redem_point;
    RETURN promo_money;
END $$
DELIMITER ;

# trigger for update new total money after insert promotion redemption
DROP TRIGGER IF EXISTS trig_update_total_money_ins;
DELIMITER $$
CREATE TRIGGER trig_update_total_money_ins AFTER UPDATE ON PR_ORDER
FOR EACH ROW
BEGIN
	CALL proc_update_total_money(NEW.order_id);
END$$
DELIMITER ;

# precedure for update new total money after updatepromotion redemption
DROP PROCEDURE IF EXISTS proc_update_total_money;
DELIMITER $$
CREATE PROCEDURE proc_update_total_money(
	mod_order_id	INT
)
BEGIN
	DECLARE cus_id	INT DEFAULT 0;
    DECLARE redem_point INT DEFAULT 0;
    DECLARE promo_money INT DEFAULT 0;
	SET cus_id = (SELECT cus_id FROM PR_ORDER WHERE mod_order_id = PR_ORDER.order_id);
    SET redem_point = (SELECT promo_red FROM PR_ORDER WHERE mod_order_id = PR_ORDER.order_id);
	SET promo_money = func_cal_cus_promo(cus_id, redem_point);
    UPDATE PR_ORDER
    SET PR_ORDER.total = PR_ORDER.total - promo_money
    WHERE PR_ORDER.order_id = mod_order_id;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS proc_delete_product_order;
DELIMITER $$
CREATE PROCEDURE proc_delete_product_order (
	del_order_id	INT,
    del_pr_id		INT,
    del_size		CHAR(1)
)
BEGIN
	IF (SELECT order_id FROM PR_ORDER WHERE del_order_id = order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(del_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    IF (SELECT pr_id FROM PRODUCT_ORDER WHERE del_pr_id = pr_id AND order_id = del_order_id AND del_size = size) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing product ID: ', CAST(del_order_id as CHAR), ' with size ', del_size);
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
	DELETE FROM PRODUCT_ORDER
    WHERE 	PRODUCT_ORDER.pr_id = del_order_id 
			AND PRODUCT_ORDER.order_id = del_order_id
			AND	PRODUCT_ORDER.size = del_size;
    
END $$
DELIMITER ;

# delete a receipt
DROP PROCEDURE IF EXISTS proc_del_receipt;
DELIMITER $$
CREATE PROCEDURE proc_del_receipt (
	del_rec_id		INT
)
BEGIN
	IF (SELECT rec_id FROM RECEIPT WHERE rec_id = del_rec_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing receipt ID: ', CAST(del_rec_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    DELETE FROM RECEIPT WHERE rec_id = del_rec_id;
END $$
DELIMITER ;


# delete a receipt
DROP PROCEDURE IF EXISTS proc_del_order;
DELIMITER $$
CREATE PROCEDURE proc_del_order (
	del_order_id		INT
)
BEGIN
	IF (SELECT order_id FROM PR_ORDER WHERE order_id = del_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(del_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    DELETE FROM PR_ORDER WHERE order_id = del_order_id;
END $$
DELIMITER ;

