USE coffee_db;
-- Check income
DROP FUNCTION IF EXISTS Check_monthly_income;
delimiter //
CREATE FUNCTION Check_monthly_income(b_id CHAR(6), target INT, o_month INT, o_year INT)
	   RETURNS VARCHAR(60) DETERMINISTIC
BEGIN
	DECLARE b_count INT DEFAULT 0;
	DECLARE income INT DEFAULT 0;
	DECLARE result VARCHAR(60);

	SELECT COUNT(*) INTO b_count FROM BRANCH WHERE br_id = b_id;
    
    -- chi nhanh khong ton tai
	IF b_count = 0 THEN
		SET @error_msg = CONCAT('Chi nhanh voi ID: ',CAST(b_id AS CHAR), ' khong ton tai');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;
    
    IF NOT(o_month >= 1 AND o_month <= 12) THEN
		SET @error_msg = CONCAT('Thang muon tinh thu nhap khong hop le');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
    END IF;

	IF target <= 0 THEN
		SET @error_msg = CONCAT('Chi tieu thu nhap phai la mot so duong');
		SIGNAL SQLSTATE '45000' SET 
		MESSAGE_TEXT = @error_msg; 
	END IF;

	SELECT SUM(total) INTO income
	FROM  PR_ORDER O, EMPLOYEE E
	WHERE O.emp_id = E.emp_id AND stat = 1 AND br_id = b_id AND MONTH(order_date) = o_month AND YEAR(order_date) = o_year;
    
    IF income >= target THEN
		SET result = CONCAT('Branch: ', CAST(b_id AS CHAR), '. Month: ', CAST(o_month AS CHAR),'. Year: ', CAST(o_year AS CHAR),
                        '. Income = ', CAST(income AS CHAR), ' passed Target = ', CAST(target AS CHAR), '.'
                        );
	ELSE
		SET result = CONCAT('Branch: ', CAST(b_id AS CHAR), '. Month: ', CAST(o_month AS CHAR),'. Year: ', CAST(o_year AS CHAR),
                        '. Income = ', CAST(income AS CHAR),' did not pass Target = ', CAST(target AS CHAR), '.'
		);
	END IF;
    
	RETURN result; 
END//
DELIMITER ;

-- revenue_stat
DROP PROCEDURE IF EXISTS revenue_stat;
DELIMITER //
CREATE PROCEDURE revenue_stat(
	bdate 		DATETIME, 
    edate 		DATETIME
)
BEGIN
	DECLARE rec_exs INT DEFAULT 0;

	IF (bdate > edate) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Start day cannot be after the end one';
	END IF;
    
    SELECT COUNT(*)
    INTO rec_exs
	FROM RECEIPT 
	WHERE (pay_day > DATE(bdate) OR (pay_day = DATE(bdate) AND pay_time >= TIME(bdate))) AND
		  (pay_day < DATE(edate) OR (pay_day = DATE(edate) AND pay_time <= TIME(edate)));

	IF rec_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing receipt in this period of time';
	END IF;
    
    SELECT br_id AS `BRANCH ID`, SUM(total) AS `TOTAL REVENUE`
    FROM RECEIPT
	WHERE (pay_day > DATE(bdate) OR (pay_day = DATE(bdate) AND pay_time >= TIME(bdate))) AND
		  (pay_day < DATE(edate) OR (pay_day = DATE(edate) AND pay_time <= TIME(edate))) AND
		   br_id IN (SELECT br_id FROM BRANCH)
	GROUP BY br_id;
END //
DELIMITER ;

-- calculate customer redemption promotion: 1 point = 1,000 VND
DROP FUNCTION IF EXISTS func_cal_red_money;
DELIMITER //
CREATE FUNCTION func_cal_red_money (
	mem_id		CHAR(6),
    redem_point	INT
) RETURNS INT DETERMINISTIC
BEGIN
	DECLARE cus_point INT DEFAULT 0;
    DECLARE promo_money INT DEFAULT 0;
    SET cus_point = (SELECT acc_point FROM CUSTOMER WHERE mem_id = CUSTOMER.cus_id);
    
    IF cus_point = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing customer ID: ', CAST(mem_id as CHAR));
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = @error_msg;
            RETURN 0;
	ELSE 
		SET @error_msg = CONCAT('Customer ID: ', CAST(mem_id as CHAR), ' do not have enough points');
		IF cus_point < redem_point THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = @error_msg;
				RETURN 0;
		END IF;

		SET promo_money = redem_point * 1000;
    END IF;
    
    RETURN promo_money;
END //
DELIMITER ;