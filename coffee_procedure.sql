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
	IF (SELECT br_id FROM BRANCH WHERE br_id = ibr_id) <> NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'The branch ID has already registered';
	END IF;
    
    IF (SELECT emp_id FROM EMPLOYEE WHERE emp_id = imng_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'The manager ID does not exist';
	END IF;
    
	INSERT INTO BRANCH 
    VALUES (ibr_id, imng_id, iadd_num);
END //

DELIMITER //
DROP PROCEDURE IF EXISTS update_mng_branch;
CREATE PROCEDURE update_mng_branch(
	ibr_id		INT, 
    imng_id 	INT
)
BEGIN
	IF (SELECT br_id FROM BRANCH WHERE br_id = ibr_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    IF (SELECT emp_id FROM EMPLOYEE WHERE emp_id = imng_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing manager';
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
	IF (SELECT br_id FROM BRANCH WHERE br_id = ibr_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find branch';
	END IF;
    
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
	IF (SELECT br_id FROM BRANCH WHERE br_id = ibr_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    IF (SELECT * FROM FURNITURE WHERE fur_id = ifur_id AND br_id = ibr_id) <> NULL THEN
		UPDATE FURNITURE SET quantity = quantity + iquantity WHERE fur_id = ifur_id AND br_id = ibr_id;
	ELSE
		INSERT INTO FURNITURE 
        VALUES (ifur_id, ibr_id, ifurname, iquantity);
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
	IF (SELECT br_id FROM BRANCH WHERE br_id = ibr_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    IF (SELECT fur_id FROM FURNITURE WHERE fur_id = ifur_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing furniture';
	END IF;
    
	UPDATE FURNITURE 
    SET quantity = iquantity
    WHERE fur_id = ifur_id AND br_id = ibr_id;
END //

DELIMITER //
DROP PROCEDURE IF EXISTS delete_furniture;
CREATE PROCEDURE delete_furniture(
	ifur_id 	INT, 
    ibr_id		INT
)
BEGIN
	IF (SELECT br_id FROM BRANCH WHERE br_id = ibr_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
    
    IF (SELECT fur_id FROM FURNITURE WHERE fur_id = ifur_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing furniture';
	END IF;

	DELETE FROM FURNITURE 
    WHERE fur_id = ifur_id AND br_id = ibr_id;
END //


# DELI_SERVICE
DELIMITER //
DROP PROCEDURE IF EXISTS insert_deliservice;
CREATE PROCEDURE insert_deliservice(
	ideli_ser_id 	INT, 
    i_deli_ser_name VARCHAR(20)
)
BEGIN 
	IF (SELECT deli_ser_id FROM DELI_SERVICE WHERE deli_ser_id = ideli_ser_id) <> NULL THEN
		SIGNAL SQLSTATE '01000'
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
	IF (SELECT deli_ser_id FROM DELI_SERVICE WHERE deli_ser_id = ideli_ser_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing delivery service';
	END IF;
    
    
END //


DELIMITER //
DROP PROCEDURE IF EXISTS delete_deliservice;
CREATE PROCEDURE delete_deliservice(
	ideli_ser_id	INT
)
BEGIN
	IF (SELECT deli_ser_id FROM DELI_SERVICE WHERE deli_ser_id = ideli_ser_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
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
	IF (bdate > edate) THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Start day cannot be after the end one';
	END IF;

	IF (SELECT rec_id 
		FROM RECEIPT 
        WHERE pay_day BETWEEN DATE(bdate) AND DATE(edate) AND 
			  pay_time BETWEEN TIME(bdate) AND TIME(edate)) THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing receipt in this period of time';
	END IF;
    
    SELECT SUM(total) AS rev_total
    FROM RECEIPT
	WHERE pay_day BETWEEN DATE(bdate) AND DATE(edate) AND 
		  pay_time BETWEEN TIME(bdate) AND TIME(edate)
	GROUP BY br_id;
END //

DELIMITER //
DROP PROCEDURE IF EXISTS pr_apply_promotion;
CREATE PROCEDURE pr_apply_promotion(
	ipromo_id 		INT
)
BEGIN
	IF (SELECT promo_id FROM PROMOTION WHERE promo_id = ipromo_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing promotion';
	END IF;
    
    SELECT pr_id, pr_name AS ID, PNAME
	FROM PRODUCT JOIN PR_APPLY_PROMO ON PRODUCT.pr_id = PR_APPLY_PROMO.pr_id
    WHERE promo_id = ipromo_id;
END; //


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
    
    IF (SELECT br_id FROM BRANCH WHERE br_id = ibr_id) = NULL THEN 
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing branch';
	END IF;
     
    IF (bdate > edate) THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Start day cannot be after the end one';
	END IF;
        
    IF (SELECT rec_id 
		FROM RECEIPT 
        WHERE br_id = ibr_id AND 
			  pay_day BETWEEN DATE(bdate) AND DATE(edate) AND 
			  pay_time BETWEEN TIME(bdate) AND TIME(edate)) <> NULL THEN
		SELECT SUM(total) 
		INTO revenue
		FROM RECEIPT
		WHERE br_id = ibr_id AND
			  pay_day BETWEEN DATE(bdate) AND DATE(edate) AND 
			  pay_time BETWEEN TIME(bdate) AND TIME(edate);
	END IF;
    
	RETURN revenue;
END; //