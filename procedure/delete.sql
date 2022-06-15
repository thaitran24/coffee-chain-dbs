USE coffee_db;

-- Product
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


-- Employee
DROP PROCEDURE IF EXISTS delete_employee;

DELIMITER //
CREATE PROCEDURE delete_employee(
    cur_emp_id      CHAR(6))
BEGIN
    SET @e_count = 0;
    SET @e_count = (SELECT COUNT(*) FROM EMPLOYEE WHERE emp_id = cur_emp_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee ID not available.';
    ELSE
        DELETE FROM EMPLOYEE
        WHERE emp_id = cur_emp_id;
    END IF;
END//
DELIMITER ;

-- emp_shift
DROP PROCEDURE IF EXISTS delete_emp_shift;

DELIMITER //
CREATE PROCEDURE delete_emp_shift(
    cur_shift_num      CHAR(6),
    cur_emp_id         CHAR(6),
    cur_workdate       DATE)
BEGIN
    SET @k_count = 0;
    SET @k_count = (SELECT COUNT(*) FROM EMP_SHIFT WHERE emp_id = cur_emp_id AND shift_num = cur_shift_num AND workdate = cur_workdate);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Employee Shift with this workdate not available.';
    ELSE
        DELETE FROM EMP_SHIFT
        WHERE emp_id = cur_emp_id AND shift_num = cur_shift_num AND workdate = cur_workdate;
    END IF;
END//
DELIMITER ;

-- promotion
DROP PROCEDURE IF EXISTS delete_promotion;

DELIMITER //
CREATE PROCEDURE delete_promotion(
    cur_promo_id    CHAR(6))
BEGIN
    SET @promo_count = 0;
    SET @promo_count = (SELECT COUNT(*) FROM PROMOTION WHERE promo_id = cur_promo_id);
    IF @e_count = 0 THEN
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Undeclared value! Promotion ID not available.';
    ELSE
        DELETE FROM PROMOTION
        WHERE promo_id = cur_promo_id;
    END IF;
END//
DELIMITER ;

-- procedure for deleting a product in an order
DROP PROCEDURE IF EXISTS proc_delete_product_order;
DELIMITER //
CREATE PROCEDURE proc_delete_product_order (
	del_order_id	CHAR(6),
    del_pr_id		CHAR(6),
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
    
	DELETE FROM PRODUCT_ORDER_DETAIL
    WHERE 	PRODUCT_ORDER_DETAIL.pr_id = del_order_id 
			AND PRODUCT_ORDER_DETAIL.order_id = del_order_id
			AND	PRODUCT_ORDER_DETAIL.size = del_size;
    
	IF (SELECT pr_id FROM PRODUCT_ORDER_DETAIL WHERE PRODUCT_ORDER_DETAIL.pr_id = del_order_id) THEN
		DELETE FROM PRODUCT_ORDER
		WHERE 	PRODUCT_ORDER.pr_id = del_order_id 
				AND PRODUCT_ORDER.order_id = del_order_id;
	END IF;
    
END //
DELIMITER ;

-- delete a receipt
DROP PROCEDURE IF EXISTS proc_del_receipt;
DELIMITER //
CREATE PROCEDURE proc_del_receipt (
	del_rec_id		CHAR(6)
)
BEGIN
	IF (SELECT rec_id FROM RECEIPT WHERE rec_id = del_rec_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing receipt ID: ', CAST(del_rec_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    DELETE FROM RECEIPT WHERE rec_id = del_rec_id;
END //
DELIMITER ;


-- delete an order, also delete corresponding receipt
DROP PROCEDURE IF EXISTS proc_del_order;
DELIMITER //
CREATE PROCEDURE proc_del_order (
	del_order_id		CHAR(6)
)
BEGIN
	IF (SELECT order_id FROM PR_ORDER WHERE order_id = del_order_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing order ID: ', CAST(del_order_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    DELETE FROM RECEIPT WHERE RECEIPT.order_id = del_order_id;
    DELETE FROM PR_ORDER WHERE order_id = del_order_id;
END //
DELIMITER ;

-- branch
DROP PROCEDURE IF EXISTS delete_branch;

DELIMITER //
CREATE PROCEDURE delete_branch(
	ibr_id		CHAR(6)
)
BEGIN
	DECLARE br_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_exs FROM BRANCH WHERE br_id = ibr_id;
    
	IF br_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find branch';
	END IF;
    
    CALL delete_all_furniture(ibr_id);
    
	DELETE FROM BRANCH 
    WHERE br_id = ibr_id;
END //
DELIMITER ;

-- one_furniture
DROP PROCEDURE IF EXISTS delete_one_furniture;

DELIMITER //
CREATE PROCEDURE delete_one_furniture(
	ifur_id 	CHAR(6), 
    ibr_id		CHAR(6)
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
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing furniture';
	END IF;

	DELETE FROM FURNITURE 
    WHERE fur_id = ifur_id AND br_id = ibr_id;
END //
DELIMITER ;

-- all_furniture
DROP PROCEDURE IF EXISTS delete_all_furniture;

DELIMITER //
CREATE PROCEDURE delete_all_furniture(
	ibr_id		CHAR(6)
)
BEGIN
	DECLARE br_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_exs FROM BRANCH WHERE br_id = ibr_id;
    
	IF br_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    DELETE FROM FURNITURE
    WHERE br_id = ibr_id;
END //
DELIMITER ;

-- Delivery
DROP PROCEDURE IF EXISTS delete_deliservice;

DELIMITER //
CREATE PROCEDURE delete_deliservice(
	ideli_ser_id	CHAR(6)
)
BEGIN
	DECLARE deli_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO deli_exs FROM DELI_SERVICE WHERE deli_ser_id = ideli_ser_id;
    
	IF deli_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing delivery service';
	END IF;
    
	DELETE FROM DELI_SERVICE 
    WHERE deli_ser_id = ideli_ser_id;
END //
DELIMITER ;

-- Batch
DROP PROCEDURE IF EXISTS Delete_Batch;
delimiter //
CREATE PROCEDURE Delete_Batch
(d_id CHAR(6))
BEGIN
	DECLARE b_count INT DEFAULT 0;
    
	SELECT COUNT(*) INTO b_count FROM M_BATCH WHERE ba_id = d_id;
    
	-- lo hang khong ton tai
    IF b_count = 0 THEN
		SET @error_msg = CONCAT('Batch with ID: ',CAST(d_id AS CHAR), ' unavailable.');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	DELETE FROM M_BATCH
    WHERE ba_id = d_id;
END //
delimiter ;

-- Customer
DROP PROCEDURE IF EXISTS Delete_Customer;
delimiter //
CREATE PROCEDURE Delete_Customer
(id CHAR(6))
BEGIN
	DECLARE c_count INT DEFAULT 0;

	SELECT COUNT(*) INTO c_count FROM CUSTOMER WHERE cus_id = id;
    
	-- khach hang khong ton tai
    IF c_count = 0 THEN
		SET @error_msg = CONCAT('Custom with ID: ',CAST(id AS CHAR), ' unavailable.');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
	DELETE FROM CUSTOMER
    WHERE cus_id = id;
END//
delimiter ;

-- material
DROP PROCEDURE IF EXISTS Delete_Material;
delimiter //
CREATE PROCEDURE Delete_Material (d_id CHAR(6))
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
END//
delimiter ;
