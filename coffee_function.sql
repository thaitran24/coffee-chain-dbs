
delimiter $$

DROP FUNCTION IF EXISTS Check_monthly_income;
CREATE FUNCTION Check_monthly_income(b_id INT, target INT, o_month INT, o_year INT)
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
END
$$
