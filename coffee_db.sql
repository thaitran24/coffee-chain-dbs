drop database if exists coffee_db;
create database coffee_db;
USE coffee_db;

DROP TABLE IF EXISTS BRANCH;
CREATE TABLE BRANCH (
	br_id		INT 			PRIMARY KEY,
    mng_id		INT				NOT NULL,
    address		VARCHAR(100)	NOT NULL
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
    address		VARCHAR(100)NOT NULL,
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
    m_name		VARCHAR(20)	NOT NULL,
    quantity	FLOAT		NOT NULL
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
    address		VARCHAR(100)NOT NULL,
    gmail		VARCHAR(40) NOT NULL,
    res_date	DATE		NOT NULL
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
    rec_address	VARCHAR(100),		# noi nhan hang
    promo_id	INT,
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
    pay_med		CHAR(1)	NOT NULL,	# phuong thuc thanh toan: tien mat, momo, chuyen khoan
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