USE coffee_db;

DROP PROCEDURE IF EXISTS proc_get_prods_info;
DELIMITER //
CREATE PROCEDURE proc_get_prods_info()
BEGIN
	SELECT 	PRODUCT.pr_id, PRODUCT.pr_name, PRODUCT.pr_type, 
			PRODUCT.pr_img, PR_PRICE.size, PR_PRICE.price
	FROM PRODUCT, PR_PRICE
	WHERE 	PRODUCT.pr_id = PR_PRICE.pr_id;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS proc_get_employ_info;
DELIMITER //
CREATE PROCEDURE proc_get_prods_info()
BEGIN
	SELECT 	*
	FROM EMPLOYEE;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS proc_get_shift_info;
DELIMITER //
CREATE PROCEDURE proc_get_shift_info()
BEGIN
	SELECT 	EMPLOYEE.emp_id, EMPLOYEE.fname, EMPLOYEE.lname, SHIFT.shift_num, 
            SHIFT.start_time, SHIFT.end_time, EMP_SHIFT.workdate, EMP_SHIFT.br_id
	FROM SHIFT, EMP_SHIFT, EMPLOYEE
    WHERE SHIFT.shift_num = EMP_SHIFT.shift_num AND EMP_SHIFT.emp_id = EMPLOYEE.emp_id;
END //
DELIMITER ;