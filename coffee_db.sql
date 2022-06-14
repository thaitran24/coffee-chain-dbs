DROP DATABASE IF EXISTS coffee_db;
CREATE DATABASE coffee_db;
USE coffee_db;

DROP TABLE IF EXISTS BRANCH;
CREATE TABLE BRANCH (
	br_id		CHAR(6) 			PRIMARY KEY,
    mng_id		CHAR(6)				NOT NULL 	DEFAULT 'E00000',
    address		VARCHAR(100)		NOT NULL	DEFAULT ''
);

DROP TABLE IF EXISTS FURNITURE;
CREATE TABLE FURNITURE (
    fur_id		CHAR(6),
    br_id		CHAR(6),
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
    emp_id		CHAR(6)		PRIMARY KEY,
    br_id		CHAR(6)		NOT NULL DEFAULT 'B00000', 
    bdate		DATE		NOT NULL,
    address		VARCHAR(100)NOT NULL	DEFAULT '',
    sex			CHAR(1)		NOT NULL,
    startdate	DATE		NOT NULL,
    ssn			CHAR(11)	NOT NULL,
    b_account	VARCHAR(19),
    salary_rate FLOAT		NOT NULL,	# need DEFAULT
    phone_num	CHAR(10)	NOT NULL,
    work_hour	INT			NOT NULL	DEFAULT 0, # reset after a month
    email		VARCHAR(40)	NOT NULL,
    degree		VARCHAR(40),
    position	VARCHAR(20),
	mng_id		CHAR(6)		DEFAULT	'E00000',
	CONSTRAINT 	fk_emp_mng
				FOREIGN KEY (mng_id) 
				REFERENCES EMPLOYEE(emp_id) 
				ON DELETE SET DEFAULT ON UPDATE CASCADE,
    CONSTRAINT 	fk_emp_branch
				FOREIGN KEY (br_id) 
				REFERENCES BRANCH(br_id) 
				ON DELETE SET DEFAULT ON UPDATE CASCADE
);

ALTER TABLE BRANCH 
	ADD CONSTRAINT fk_branch_mng
	FOREIGN KEY (mng_id) 
	REFERENCES EMPLOYEE(emp_id)
    ON DELETE SET DEFAULT ON UPDATE CASCADE;

DROP TABLE IF EXISTS SHIFT;
CREATE TABLE SHIFT (	# ca lam viec
	shift_num	CHAR(6)	PRIMARY KEY,
    start_time	TIME 	NOT NULL,
    end_time	TIME	NOT NULL
);

DROP TABLE IF EXISTS WORKDATE;
CREATE TABLE WORKDATE (	# ca lam viec
	workdate	DATE	PRIMARY KEY
);

DROP TABLE IF EXISTS EMP_SHIFT;
CREATE TABLE EMP_SHIFT (
	shift_num	CHAR(6)	NOT NULL	DEFAULT 'S00000',
	emp_id		CHAR(6)	NOT NULL,
    workdate	DATE	NOT NULL,
    PRIMARY KEY (shift_num, emp_id, workdate),
    br_id		CHAR(6)	NOT NULL,
    CONSTRAINT 	fk_emp_shift
				FOREIGN KEY (emp_id) 
				REFERENCES EMPLOYEE(emp_id) 
				ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT 	fk_shift
				FOREIGN KEY (shift_num) 
				REFERENCES SHIFT(shift_num) 
				ON DELETE SET DEFAULT ON UPDATE CASCADE,
	
	CONSTRAINT	fk_workdate
				FOREIGN KEY (workdate)
				REFERENCES WORKDATE(workdate)
				ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PRODUCT;
CREATE TABLE PRODUCT (
	pr_id		CHAR(6)			PRIMARY KEY,
	pr_name		VARCHAR(100)	NOT NULL,
	pr_type		VARCHAR(30) 	NOT NULL,
    pr_img		VARCHAR(150)	NOT NULL
);

DROP TABLE IF EXISTS PR_PRICE;
CREATE TABLE PR_PRICE (
	pr_id		CHAR(6)		NOT NULL,
    size		CHAR(1)		NOT NULL,
    price		INT			NOT NULL,
	PRIMARY KEY(pr_id, size, price),
    CONSTRAINT 	fk_product_price
				FOREIGN KEY (pr_id) 
				REFERENCES PRODUCT(pr_id) 
				ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS MATERIAL;
CREATE TABLE MATERIAL (
	m_id		CHAR(6)		PRIMARY KEY,
    m_name		VARCHAR(20)	NOT NULL
);

DROP TABLE IF EXISTS M_BATCH;
CREATE TABLE M_BATCH (	# lo nguyen lieu
	ba_id		CHAR(6)	PRIMARY KEY,
    m_id		CHAR(6)	NOT NULL,	
    mng_id		CHAR(6)	NOT NULL	DEFAULT 'E00000',
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
				ON DELETE SET DEFAULT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PR_MATERIAL;
CREATE TABLE PR_MATERIAL (
	m_id		CHAR(6),
    pr_id		CHAR(6),
    PRIMARY KEY (m_id, pr_id),
    CONSTRAINT 	fk_material_pr
				FOREIGN KEY (m_id) 
				REFERENCES MATERIAL(m_id) 
				ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT 	fk_pr_material
				FOREIGN KEY (pr_id) 
				REFERENCES PRODUCT(pr_id) 
				ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS CUSTOMER;
CREATE TABLE CUSTOMER (
	fname		VARCHAR(10)	NOT NULL,
    lname		VARCHAR(20)	NOT NULL,
    cus_id		CHAR(6)		PRIMARY KEY,
    phone_num	CHAR(10)	NOT NULL,
    sex			CHAR(1)		NOT NULL,
    address		VARCHAR(100)NOT NULL	DEFAULT '',
    email		VARCHAR(40) NOT NULL,
    res_date	DATE		NOT NULL,
    acc_point	INT			NOT NULL 	DEFAULT 0
);

DROP TABLE IF EXISTS ACCOUNT_INF;
CREATE TABLE ACCOUNT_INF (
	acc_id		CHAR(6)		PRIMARY KEY,
    acc_type	BOOL		NOT NULL,
    acc_name	VARCHAR(24)	NOT NULL	UNIQUE,	# tai khoan
    acc_pass	VARCHAR(24)	NOT NULL,			# mat khau
    cus_id		CHAR(6)		NOT NULL	UNIQUE,
	emp_id		CHAR(6)		NOT NULL	UNIQUE,
    CONSTRAINT 	fk_cus_account
				FOREIGN KEY (cus_id) 
				REFERENCES CUSTOMER(cus_id) 
				ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT 	fk_em_account
				FOREIGN KEY (emp_id) 
				REFERENCES EMPLOYEE(emp_id) 
				ON DELETE CASCADE ON UPDATE CASCADE
);


DROP TABLE IF EXISTS PROMOTION;
CREATE TABLE PROMOTION (
	promo_id	CHAR(6)	PRIMARY KEY,
	promo_per	INT,	# phan tram khuyen mai (40% luu 40),
    start_date	DATE	NOT NULL,
    end_date	DATE	NOT NULL
);

DROP TABLE IF EXISTS PR_ORDER;
CREATE TABLE PR_ORDER (	# don hang
	order_id	CHAR(10)PRIMARY KEY,
    order_date	DATE	NOT NULL,
    order_time	TIME	NOT NULL,
    promo_red	INT					DEFAULT 0,	# khuyen mai quy doi
    total		INT		NOT NULL	DEFAULT 0,
    order_type	BOOL 	NOT NULL,	# 0: offline, 1: online
    rec_address	VARCHAR(100)		DEFAULT '',		# noi nhan hang
    promo_id	CHAR(6)					DEFAULT 0,
    br_id		CHAR(6)	NOT NULL,
    cus_id		CHAR(6)	NOT NULL,
    emp_id		CHAR(6)	NOT NULL,
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
	rec_id		CHAR(10)PRIMARY KEY,
    order_id	CHAR(10)NOT NULL,
    pay_day		DATE	NOT NULL,
    pay_time	TIME	NOT NULL,
    promo_red	INT, 	# khuyen mai quy doi
    br_id		CHAR(6)	NOT NULL,
    cus_id		CHAR(6)	NOT NULL,
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
	pr_id		CHAR(6) NOT NULL,
    order_id	CHAR(10)NOT NULL,
	PRIMARY KEY (pr_id, order_id),
    CONSTRAINT	fk_product_order
				FOREIGN KEY (pr_id)
                REFERENCES PRODUCT(pr_id)
                ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT	fk_order_product
				FOREIGN KEY (order_id)
                REFERENCES PR_ORDER(order_id)
                ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS PRODUCT_ORDER_DETAIL; # so luong san pham thuoc cac co khac nhau tuong ung voi mot san pham
CREATE TABLE  PRODUCT_ORDER_DETAIL (
	pr_id		CHAR(6) NOT NULL,
    order_id	CHAR(10)NOT NULL,
    size		CHAR(1)	NOT NULL,
    price		INT		NOT NULL,
    quantity 	INT		NOT NULL,
	PRIMARY KEY (pr_id, order_id, size, price, quantity),
    CONSTRAINT	fk_product_order_detail
				FOREIGN KEY (pr_id)
                REFERENCES PRODUCT_ORDER(pr_id)
                ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT	fk_order_product_detail
				FOREIGN KEY (order_id)
                REFERENCES PRODUCT_ORDER(order_id)
                ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP TABLE IF EXISTS DELI_SERVICE;
CREATE TABLE DELI_SERVICE (	#
	deli_ser_id		CHAR(6)	PRIMARY KEY,
    deli_ser_name	VARCHAR(20)
);

DROP TABLE IF EXISTS DELIVERY;
CREATE TABLE DELIVERY (
	order_id		CHAR(10),
    deli_ser_id		CHAR(6),
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