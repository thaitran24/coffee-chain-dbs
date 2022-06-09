USE coffee_db;

# BRANCH
DELIMITER //
DROP PROCEDURE IF EXISTS insert_branch;
CREATE PROCEDURE insert_branch(
	ibr_id		INT, 
    imng_id 	INT, 
    iaddress 	VARCHAR(100)
)
BEGIN
	DECLARE br_num INT DEFAULT 0;
    DECLARE mng_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_num FROM BRANCH WHERE br_id = ibr_id;
    SELECT COUNT(*) INTO mng_exs FROM EMPLOYEE WHERE emp_id = imng_id;
    
	IF br_num > 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The branch ID has already registered';
	END IF;
    
    IF mng_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'The manager ID does not exist';
	END IF;
    
    IF (SELECT br_id FROM EMPLOYEE WHERE emp_id = imng_id) <> ibr_id THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'This employee works at another branch';
	END IF;
    
	INSERT INTO BRANCH 
    VALUES (ibr_id, imng_id, iaddress);
END //

DELIMITER //
DROP PROCEDURE IF EXISTS update_mng_branch;
CREATE PROCEDURE update_mng_branch(
	ibr_id		INT, 
    imng_id 	INT
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

DELIMITER //
DROP PROCEDURE IF EXISTS delete_branch;
CREATE PROCEDURE delete_branch(
	ibr_id		INT
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


# FURNITURE
DELIMITER //
DROP PROCEDURE IF EXISTS insert_furniture;
CREATE PROCEDURE insert_furniture(
	ifur_id		INT, 
    ibr_id 		INT, 
    ifurname 	VARCHAR(20), 
    iquantity 	INT
)
BEGIN
	DECLARE count INT DEFAULT 0;
	DECLARE br_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_exs FROM BRANCH WHERE br_id = ibr_id;
    
	IF br_exs = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    SELECT COUNT(*) INTO count FROM FURNITURE WHERE fur_id = ifur_id AND br_id = ibr_id;
    
    IF count > 0 THEN
		UPDATE FURNITURE 
		SET quantity = quantity + iquantity 
		WHERE fur_id = ifur_id AND br_id = ibr_id;
	ELSE
		INSERT INTO FURNITURE
        VALUES(ifur_id, ibr_id, ifurname, iquantity);
	END IF;
END //

DELIMITER //
DROP PROCEDURE IF EXISTS update_fur_quantity;
CREATE PROCEDURE update_fur_quantity(
	ifur_id		INT, 
    ibr_id 		INT, 
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

DELIMITER //
DROP PROCEDURE IF EXISTS delete_one_furniture;
CREATE PROCEDURE delete_one_furniture(
	ifur_id 	INT, 
    ibr_id		INT
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

DELIMITER //
DROP PROCEDURE IF EXISTS delete_all_furniture;
CREATE PROCEDURE delete_all_furniture(
	ibr_id		INT
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


# DELI_SERVICE
DELIMITER //
DROP PROCEDURE IF EXISTS insert_deliservice;
CREATE PROCEDURE insert_deliservice(
	ideli_ser_id 	INT, 
    ideli_ser_name VARCHAR(20)
)
BEGIN 
	DECLARE deli_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO deli_exs FROM DELI_SERVICE WHERE deli_ser_id = ideli_ser_id;

	IF deli_exs <> 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Delivery service existed';
	END IF;
            
	INSERT INTO DELI_SERVICE 
    VALUES(ideli_ser_id, ideli_ser_name);
END //

DELIMITER //
DROP PROCEDURE IF EXISTS update_ser_name;
CREATE PROCEDURE update_ser_name(
	ideli_ser_id	INT,
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


DELIMITER //
DROP PROCEDURE IF EXISTS delete_deliservice;
CREATE PROCEDURE delete_deliservice(
	ideli_ser_id	INT
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

DELIMITER //
DROP PROCEDURE IF EXISTS revenue_stat;
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

DELIMITER //
DROP PROCEDURE IF EXISTS pr_apply_promotion;
CREATE PROCEDURE pr_apply_promotion(
	ipromo_id 		INT
)
BEGIN
	DECLARE pro_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO pro_exs FROM PROMOTION WHERE promo_id = ipromo_id;
    
	IF pro_exs = 0 THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing promotion';
	END IF;
    
    SELECT PRODUCT.pr_id AS `ID`, pr_name AS `PRODUCT`, size AS `SIZE`, price  AS `PRICE`
	FROM (PRODUCT INNER JOIN PR_APPLY_PROMO 
		  ON PRODUCT.pr_id = PR_APPLY_PROMO.pr_id) INNER JOIN PR_PRICE 
          ON PRODUCT.pr_id = PR_PRICE.pr_id
    WHERE promo_id = ipromo_id;
END //


DELIMITER //
DROP FUNCTION IF EXISTS one_branch_revenue;
CREATE FUNCTION one_branch_revenue(
	ibr_id		INT, 
    bdate 		DATETIME, 
    edate 		DATETIME
) 
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE revenue INT DEFAULT 0;
    DECLARE br_exs INT DEFAULT 0;
    
    SELECT COUNT(*) INTO br_exs FROM BRANCH WHERE br_id = ibr_id;
    
    IF br_exs = 0 THEN 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
     
    IF (bdate > edate) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Start day cannot be after the end one';
	END IF;
        
	SELECT COALESCE(SUM(total) , 0)
	INTO revenue
	FROM RECEIPT
	WHERE br_id = ibr_id AND
		  (pay_day > DATE(bdate) OR (pay_day = DATE(bdate) AND pay_time >= TIME(bdate))) AND
		  (pay_day < DATE(edate) OR (pay_day = DATE(edate) AND pay_time <= TIME(edate)));
    
	RETURN revenue;
END //
