drop database if exists coffee_db;
create database coffee_db;
USE coffee_db;

DROP TABLE IF EXISTS BRANCH;
CREATE TABLE BRANCH (
	br_id		INT 			PRIMARY KEY,
    mng_id		INT				NOT NULL,
    address		VARCHAR(100)	NOT NULL	DEFAULT ''
);

DROP TABLE IF EXISTS FURNITURE;
CREATE TABLE FURNITURE (
    fur_id		INT,
    br_id		INT,
    PRIMARY KEY (fur_id, br_id),
    furname		VARCHAR(20),
    quantity	INT,
    CONSTRAINT 	fk_branch_furniture
				FOREIGN KEY (br_id) 
				REFERENCES BRANCH(br_id)
                ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS EMPLOYEE;
CREATE TABLE EMPLOYEE (
	fname		VARCHAR(10)	NOT NULL,
    lname		VARCHAR(20)	NOT NULL,
    emp_id		INT			PRIMARY KEY,
    br_id		INT			NOT NULL,
    bdate		DATE		NOT NULL,
    address		VARCHAR(100)NOT NULL	DEFAULT '',
    sex			CHAR(1)		NOT NULL,
    startdate	DATE		NOT NULL,
    ssn			CHAR(10)	NOT NULL,
    b_account	VARCHAR(16),
    salary_rate FLOAT		NOT NULL,	# need DEFAULT
    phone_num	CHAR(10)	NOT NULL,
    work_hour	INT			NOT NULL,	# reset after a month
    gmail		VARCHAR(40)	NOT NULL,
    degree		VARCHAR(40),
    position	VARCHAR(20),
    CONSTRAINT 	fk_emp_branch
				FOREIGN KEY (br_id) 
				REFERENCES BRANCH(br_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

ALTER TABLE BRANCH 
	ADD CONSTRAINT fk_branch_mng
	FOREIGN KEY (mng_id) 
	REFERENCES EMPLOYEE(emp_id)
    ON DELETE RESTRICT ON UPDATE CASCADE;

DROP TABLE IF EXISTS SHIFT;
CREATE TABLE SHIFT (	# ca lam viec
	shift_num	INT 	PRIMARY KEY,
    start_time	TIME 	NOT NULL,
    end_time	TIME	NOT NULL
);


DROP TABLE IF EXISTS EMP_SHIFT;
CREATE TABLE EMP_SHIFT (
	shift_num	INT		NOT NULL,
	emp_id		INT		NOT NULL,
    workdate	DATE	NOT NULL,
    PRIMARY KEY (shift_num, emp_id, workdate),
    br_id		INT 	NOT NULL,
    CONSTRAINT 	fk_emp_shift
				FOREIGN KEY (emp_id) 
				REFERENCES EMPLOYEE(emp_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_shift
				FOREIGN KEY (shift_num) 
				REFERENCES SHIFT(shift_num) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PRODUCT;
CREATE TABLE PRODUCT (
	pr_id		INT			PRIMARY KEY,
	pr_name		VARCHAR(30)	NOT NULL
);

DROP TABLE IF EXISTS PR_PRICE;
CREATE TABLE PR_PRICE (
	pr_id		INT			PRIMARY KEY,
    size		CHAR(1)		NOT NULL,
    price		INT			NOT NULL,
    CONSTRAINT 	fk_product_price
				FOREIGN KEY (pr_id) 
				REFERENCES PRODUCT(pr_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS MATERIAL;
CREATE TABLE MATERIAL (
	m_id		INT			PRIMARY KEY,
    m_name		VARCHAR(20)	NOT NULL
);

DROP TABLE IF EXISTS M_BATCH;
CREATE TABLE M_BATCH (	# lo nguyen lieu
	ba_id		INT		PRIMARY KEY,
    m_id		INT		NOT NULL,
    mng_id		INT		NOT NULL,
    imp_date	DATE	NOT NULL,
    exp_date	DATE	NOT NULL,
    quantity	FLOAT	NOT NULL,
    CONSTRAINT 	fk_material_batch
				FOREIGN KEY (m_id) 
				REFERENCES MATERIAL(m_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_emp_import_batch
				FOREIGN KEY (mng_id) 
				REFERENCES EMPLOYEE(emp_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PR_MATERIAL;
CREATE TABLE PR_MATERIAL (
	m_id		INT,
    pr_id		INT,
    PRIMARY KEY (m_id, pr_id),
    CONSTRAINT 	fk_material_pr
				FOREIGN KEY (m_id) 
				REFERENCES MATERIAL(m_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_pr_material
				FOREIGN KEY (pr_id) 
				REFERENCES PRODUCT(pr_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS CUSTOMER;
CREATE TABLE CUSTOMER (
	fname		VARCHAR(10)	NOT NULL,
    lname		VARCHAR(20)	NOT NULL,
    cus_id		INT			PRIMARY KEY,
    phone_num	CHAR(10)	NOT NULL,
    sex			CHAR(1)		NOT NULL,
    address		VARCHAR(100)NOT NULL	DEFAULT '',
    gmail		VARCHAR(40) NOT NULL,
    res_date	DATE		NOT NULL,
    acc_point	INT			NOT NULL 	DEFAULT 0
);

DROP TABLE IF EXISTS PROMOTION;
CREATE TABLE PROMOTION (
	promo_id	INT		PRIMARY KEY,
    start_date	DATE	NOT NULL,
    end_date	DATE	NOT NULL
);

DROP TABLE IF EXISTS PERC_PROMOTION;
CREATE TABLE PERC_PROMOTION (
	promo_id	INT		PRIMARY KEY,
    promo_per	INT,	# phan tram khuyen mai
	min_num		INT,	# so luong toi thieu
    CONSTRAINT 	fk_perc_promo
				FOREIGN KEY (promo_id) 
				REFERENCES PROMOTION(promo_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS GIFT_PROMOTION;
CREATE TABLE GIFT_PROMOTION (
	promo_id	INT		PRIMARY KEY,
    buy_num		INT,	# so luong mua
	gift_num	INT,	# so luong tang
    CONSTRAINT 	fk_num_promo
				FOREIGN KEY (promo_id) 
				REFERENCES PROMOTION(promo_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PR_APPLY_PROMO;
CREATE TABLE PR_APPLY_PROMO (	# san pham duoc ap dung khuyen mai
	promo_id	INT,
    pr_id		INT,
    PRIMARY KEY (promo_id, pr_id),
    CONSTRAINT 	fk_apply_promo
				FOREIGN KEY (promo_id) 
				REFERENCES PROMOTION(promo_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_apply_product
				FOREIGN KEY (pr_id) 
				REFERENCES PRODUCT(pr_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PRODUCT_GIFT;
CREATE TABLE PRODUCT_GIFT (		# san pham duoc dung de tang
	promo_id	INT,
    pr_id		INT,
    PRIMARY KEY (promo_id, pr_id),
    CONSTRAINT 	fk_gift_promo
				FOREIGN KEY (promo_id) 
				REFERENCES GIFT_PROMOTION(promo_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_gift_product
				FOREIGN KEY (pr_id) 
				REFERENCES PRODUCT(pr_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PR_ORDER;
CREATE TABLE PR_ORDER (	# don hang
	order_id	INT 	PRIMARY KEY,
    order_date	DATE	NOT NULL,
    order_time	TIME	NOT NULL,
    promo_red	INT					DEFAULT 0,	# khuyen mai quy doi
    total		INT		NOT NULL	DEFAULT 0,
    order_type	BOOL 	NOT NULL,	# 0: offline, 1: online
    rec_address	VARCHAR(100)		DEFAULT '',		# noi nhan hang
    promo_id	INT					DEFAULT 0,
    br_id		INT		NOT NULL,
    cus_id		INT		NOT NULL,
    emp_id		INT		NOT NULL,
    stat		BOOL	NOT NULL,	# 0: chua thanh toan, 1: da thanh toan
	CONSTRAINT 	fk_promotion_order
				FOREIGN KEY (promo_id) 
				REFERENCES PROMOTION(promo_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_customer_order
				FOREIGN KEY (cus_id) 
				REFERENCES CUSTOMER(cus_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_employee_order
				FOREIGN KEY (emp_id) 
				REFERENCES EMPLOYEE(emp_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_branch_order
				FOREIGN KEY (br_id) 
				REFERENCES BRANCH(br_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS RECEIPT;
CREATE TABLE RECEIPT (
	rec_id		INT		PRIMARY KEY,
    order_id	INT		NOT NULL,
    pay_day		DATE	NOT NULL,
    pay_time	TIME	NOT NULL,
    pay_med		CHAR(1)	NOT NULL	DEFAULT 'M',	# phuong thuc thanh toan: tien mat, momo, chuyen khoan
    promo_red	INT, 	# khuyen mai quy doi
    br_id		INT		NOT NULL,
    cus_id		INT		NOT NULL,
    total		INT		NOT NULL,
    CONSTRAINT 	fk_branch_receipt
				FOREIGN KEY (br_id) 
				REFERENCES BRANCH(br_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_customer_receipt
				FOREIGN KEY (cus_id) 
				REFERENCES CUSTOMER(cus_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_order_receipt
				FOREIGN KEY (order_id) 
				REFERENCES PR_ORDER(order_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PRODUCT_ORDER;
CREATE TABLE  PRODUCT_ORDER (
	pr_id		INT 	NOT NULL,
    order_id	INT		NOT NULL,
    PRIMARY KEY (pr_id, order_id),
    size		CHAR(1)	NOT NULL,
    price		INT		NOT NULL,
    quantity 	INT		NOT NULL,
    CONSTRAINT	fk_product_order
				FOREIGN KEY (pr_id)
                REFERENCES PRODUCT(pr_id)
                ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT	fk_order_product
				FOREIGN KEY (pr_id)
                REFERENCES PR_ORDER(order_id)
                ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS DELI_SERVICE;
CREATE TABLE DELI_SERVICE (	#
	deli_ser_id		INT		PRIMARY KEY,
    deli_ser_name	VARCHAR(20)
);

DROP TABLE IF EXISTS DELIVERY;
CREATE TABLE DELIVERY (
	order_id		INT,
    deli_ser_id		INT,
    PRIMARY KEY (order_id, deli_ser_id),
    vehicle		VARCHAR(20),
    driver		VARCHAR(20),
    deli_date	DATE,
    deli_time	TIME,
    charge		INT,
    CONSTRAINT 	fk_deli_order
				FOREIGN KEY (order_id) 
				REFERENCES PR_ORDER(order_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_deli_service
				FOREIGN KEY (deli_ser_id) 
				REFERENCES DELI_SERVICE(deli_ser_id)
				ON DELETE RESTRICT ON UPDATE CASCADE
);

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
	IF (promo_red <> 0 AND promo_id <> 0) THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Only apply one type of promotion at a time!';
    END IF;
	INSERT INTO PR_ORDER VALUES(order_id, order_date, order_time, promo_red, total, order_type,
								red_address, promo_id, br_id, cus_id, emp_id, stat);
END $$
DELIMITER ;


# insert product to an order
DROP PROCEDURE IF EXISTS proc_insert_prod_order;
DELIMITER $$
CREATE PROCEDURE proc_insert_prod_order (
	mod_order_id	INT,
    prod_id			INT,
    quantity		INT
)
BEGIN
	# SOMETHING HERE
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
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing order!';
	END IF;
    UPDATE PR_ORDER
    SET PR_ORDER.rec_address = mod_address
    WHERE PR_ORDER.order_id = mod_order_id; 
END $$
DELIMITER ;


# update customer id in order
DROP PROCEDURE IF EXISTS proc_update_cus_id;
DELIMITER $$
CREATE PROCEDURE proc_update_cus_id (
	mod_order_id	INT,
    mod_cus_id		INT
)
BEGIN
	IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing order!';
	END IF;
	UPDATE PR_ORDER
    SET PR_ORDER.cus_id = mod_cus_id
    WHERE PR_ORDER.order_id = mod_order_id;
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
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing order!';
	END IF;
    UPDATE PR_ORDER
    SET PR_ORDER.stat = TRUE
    WHERE PR_ORDER.order_id = mod_order_id;
END $$
DELIMITER ;


# modify promotion
DROP PROCEDURE IF EXISTS proc_modify_order_promo_id; 
DELIMITER $$
CREATE PROCEDURE proc_modify_order_promo_id (
	mod_order_id 	INT,
	new_promo_id 	INT
)
BEGIN
	DECLARE promo_red INT DEFAULT 0;
	IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing order!';
	END IF;
    SET promo_red = (SELECT promo_red FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id);
    IF promo_red <> 0 AND new_promo_id <> 0 THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Only apply one type of promotion at a time!';
	END IF;
    UPDATE PR_ORDER 
    SET PR_ORDER.promo_id = new_promo_id
    WHERE PR_ORDER.order_id = mod_order_id;
    # NEED TRIGGER
END $$
DELIMITER ;


# modify promotion redemption 
DROP PROCEDURE IF EXISTS proc_modify_order_promo_red;
DELIMITER $$
CREATE PROCEDURE proc_modify_order_promo_red (
	mod_order_id	INT,
    redem_point		INT
)
BEGIN
	DECLARE total_money INT DEFAULT 0;
    DECLARE limit_point INT DEFAULT 0;
    DECLARE promo_id 	INT	DEFAULT 0;
	IF (SELECT order_id FROM PR_ORDER WHERE PR_ORDER.order_id = mod_order_id) = NULL THEN
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find existing order!';
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
			SET MESSAGE_TEXT = 'Redemption promotion cannot greater than 70% of order total money!';
	END IF;
    
    UPDATE PR_ORDER
    SET PR_ORDER.promo_red = redem_point
    WHERE PR_ORDER.order_id = mod_order_id;
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
		SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = 'Cannot find cus!';
            RETURN 0;
	ELSE 
		IF cus_point < redem_point THEN
			SIGNAL SQLSTATE '01000'
				SET MESSAGE_TEXT = 'Not enough point';
				RETURN 0;
		END IF;

		SET promo_money = cus_point * 1000;
    END IF;
    UPDATE CUSTOMER
    SET CUSTOMER.promo_point = CUSTOMER.promo_point - redem_point;
    RETURN promo_money;
END $$
DELIMITER ;


# trigger for creating new receipt when an ordern has been paid
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