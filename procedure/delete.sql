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