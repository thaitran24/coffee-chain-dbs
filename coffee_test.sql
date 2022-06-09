USE coffee_db;

SET FOREIGN_KEY_CHECKS = 0;

# Data - Check INSERT
-- Employee
INSERT INTO EMPLOYEE VALUES ('Huy', 'Tran', 2011291, 100, '2002-04-13', '41 NTMK', 'M', '2015-06-12', '1010', '000111020', 0.5, '0885533243', 12, 'nhathuytk1@gmail.com', 3, '');
INSERT INTO EMPLOYEE VALUES ('Huy1', 'Tran', 2011290, 101, '2002-04-13', '41 NTMK', 'M', '2015-06-12', '1010', '000111020', 0.5, '0885533243', 12, 'nhathuytk1@gmail.com', 3, '');
INSERT INTO EMPLOYEE VALUES ('Huy2', 'Tran', 1234567, 102, '2002-04-13', '41 NTMK', 'M', '2015-06-12', '1010', '000111020', 0.5, '0885533243', 12, 'nhathuytk1@gmail.com', 3, '');
INSERT INTO EMPLOYEE VALUES ('Huy3', 'Tran', 1232411, 103, '2002-04-13', '41 NTMK', 'M', '2015-06-12', '1010', '000111020', 0.5, '0885533243', 12, 'nhathuytk1@gmail.com', 3, '');

-- Branch
CALL insert_branch(100, 2011291, '41 Nguyen Thi Minh Khai');
CALL insert_branch(101, 2011290, '45 Tan Lap');
CALL insert_branch(102, 1234567, '69 Tan Lap');
CALL insert_branch(103, 1232411, '22 Mai Thi Luu');

CALL update_mng_branch(100, 2011290);
CALL delete_branch(100);

SELECT * FROM BRANCH;

-- Furniture
CALL insert_furniture(500, 100, 'Chair', 20);
CALL insert_furniture(501, 100, 'Table', 10);
CALL insert_furniture(502, 100, 'Cup', 30);
CALL insert_furniture(500, 101, 'Chair', 10);
CALL insert_furniture(501, 101, 'Table', 5);
CALL insert_furniture(501, 101, 'Table', 10);
CALL insert_furniture(502, 102, 'Cup', 30);
CALL insert_furniture(502, 103, 'Cup', 30);

CALL insert_furniture(502, 104, 'Cup', 30);
CALL update_fur_quantity(500, 100, 10);
CALL delete_one_furniture(500, 100);

CALL delete_branch(100);
SELECT * FROM BRANCH;
SELECT * FROM FURNITURE;

-- Delivery service
CALL insert_deliservice(900, 'Grab');
CALL insert_deliservice(901, 'Baemin');

CALL update_ser_name(902, 'Baemin');
CALL delete_deliservice(901);

# Add some records from other table
-- Receipt
INSERT INTO RECEIPT
VALUES (333, 200, '2020-06-21', '06:00:00', 'M', 0, 100, 700202, 23000);

INSERT INTO RECEIPT
VALUES (332, 2011, '2020-06-06', '17:30:00', 'M', 0, 100, 700112, 10000);

INSERT INTO RECEIPT
VALUES (334, 202, '2020-06-14', '17:30:00', 'M', 0, 101, 700212, 50000);

INSERT INTO RECEIPT
VALUES (335, 203, '2020-06-28', '14:00:00', 'M', 0, 102, 711223, 40000);

-- Product
INSERT INTO PRODUCT VALUES (600, 'Milk Tea');
INSERT INTO PRODUCT VALUES (601, 'Latte');
INSERT INTO PRODUCT VALUES (602, 'Capuchino');
INSERT INTO PRODUCT VALUES (603, 'Vanilla Sweet Cream Cold Brew');
INSERT INTO PRODUCT VALUES (604, 'Muffin');
INSERT INTO PRODUCT VALUES (605, 'Donut');

-- Pr_Price
INSERT INTO PR_PRICE VALUES (600, 'M', 25000);
INSERT INTO PR_PRICE VALUES (601, 'L', 30000);
INSERT INTO PR_PRICE VALUES (602, 'M', 30000);
INSERT INTO PR_PRICE VALUES (603, 'L', 50000);
INSERT INTO PR_PRICE VALUES (604, ' ', 30000);
INSERT INTO PR_PRICE VALUES (605, ' ', 30000);

-- Pr_apply_promo
INSERT INTO PR_APPLY_PROMO VALUES (200, 600);
INSERT INTO PR_APPLY_PROMO VALUES (200, 601);
INSERT INTO PR_APPLY_PROMO VALUES (200, 604);
INSERT INTO PR_APPLY_PROMO VALUES (201, 605);
INSERT INTO PR_APPLY_PROMO VALUES (202, 604);
INSERT INTO PR_APPLY_PROMO VALUES (202, 605);


# Show revenue in the period of time
CALL revenue_stat('2020-06-01 00:00:00', '2020-07-01 00:00:00');


# List of products that applied the promotion
CALL pr_apply_promotion(200);

# Calculate the revenue of a branch in the specific period of time
SET @rev = one_branch_revenue(101, '2020-06-01 00:00:00', '2020-07-13 00:00:00');
SELECT @rev AS REVENUE;

SET FOREIGN_KEY_CHECKS = 1;