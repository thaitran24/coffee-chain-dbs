USE coffee_db;

-- trigger for creating new receipt when an ordern has been paid 
DROP TRIGGER IF EXISTS trig_create_receipt;
DELIMITER //
CREATE TRIGGER trig_create_receipt AFTER INSERT ON PR_ORDER 
FOR EACH ROW
BEGIN
	IF NEW.order_id = (SELECT rec_id FROM RECEIPT WHERE RECEIPT.order_id = NEW.order_id) THEN
		SET @error_msg = CONCAT('Receipt ID: ', CAST(mod_order_id as CHAR), ' has already existed');
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
	INSERT INTO RECEIPT VALUES(NEW.order_id, NEW.order_id, CURDATE(), CURTIME(),
								NEW.promo_red, NEW.br_id, NEW.cus_id, NEW.total);
END //
DELIMITER ;

-- update receipt after update on order
DROP TRIGGER IF EXISTS trig_update_receipt;
DELIMITER //
CREATE TRIGGER trig_update_receipt AFTER UPDATE ON PR_ORDER
FOR EACH ROW
BEGIN
	UPDATE RECEIPT
    SET RECEIPT.total = NEW.total,
		RECEIPT.promo_red = NEW.promo_red,
        RECEIPT.pay_day = CURDATE(),
        RECEIPT.pay_time = CURTIME()
	WHERE RECEIPT.order_id = NEW.order_id;
END //
DELIMITER ;

-- upadte total money
DROP TRIGGER IF EXISTS trig_update_total_money;
DELIMITER //
CREATE TRIGGER trig_update_total_money AFTER INSERT ON PRODUCT_ORDER_DETAIL
FOR EACH ROW
BEGIN
	DECLARE up_promo_id INT DEFAULT 0;
    UPDATE PR_ORDER 
    SET PR_ORDER.total = (SELECT SUM(PRODUCT_ORDER_DETAIL.price * PRODUCT_ORDER_DETAIL.quantity)
						  WHERE PRODUCT_ORDER_DETAIL.order_id = NEW.order_id)
	WHERE PR_ORDER.order_id = NEW.order_id;
    
    SET up_promo_id = (SELECT promo_id FROM PR_ORDER WHERE PR_ORDER.promo_id = up_promo_id);
    
    IF up_promo_id > 0 THEN
		CALL proc_update_total_money_perc_promo(NEW.order_id);
	ELSE
		CALL proc_update_total_money_perc_promo(NEW.order_id);
	END IF;

END //
DELIMITER ;

DROP TRIGGER IF EXISTS Check_deleted_batch;
delimiter //
CREATE TRIGGER Check_deleted_batch AFTER DELETE ON M_BATCH FOR EACH ROW
BEGIN 
	DECLARE b_count INT DEFAULT 0;
	SELECT COUNT(*) INTO b_count
	FROM M_BATCH M
    WHERE M.ba_id != old.ba_id AND M.m_id = old.m_id;
    
    IF b_count = 0 THEN
		DELETE FROM MATERIAL M
        WHERE M.m_id = old.m_id;
    END IF;
END//
delimiter ;

DROP TRIGGER IF EXISTS change_workhour;
delimiter //
CREATE TRIGGER change_workhour AFTER INSERT ON EMP_SHIFT FOR EACH ROW
BEGIN 
	SET @new_workhour = 0;
	SELECT work_hour INTO @new_workhour
	FROM EMPLOYEE
    WHERE EMPLOYEE.emp_id = new.emp_id;
    SET @end_time = (SELECT end_time FROM SHIFT WHERE SHIFT.shift_num = new.shift_num);
    SET @start_time = (SELECT start_time FROM SHIFT WHERE SHIFT.shift_num = new.shift_num);
    IF @end_time IS NULL OR @start_time IS NULL OR @new_workhour IS NULL THEN
        SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "NULL!";
    END IF;
    IF DAY(new.workdate) = 1 THEN
        SET @new_workhour = 0;
    END IF;
    SET @new_workhour = (@new_workhour + (HOUR(@end_date) - HOUR(@start_time)));
    UPDATE EMPLOYEE
    SET work_hour = @new_workhour
    WHERE EMPLOYEE.emp_id = new.emp_id;  
END//
delimiter ;