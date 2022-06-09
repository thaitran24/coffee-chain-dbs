USE coffee_db;

DROP PROCEDURE IF EXISTS proc_view_order_products;
DELIMITER $$
CREATE PROCEDURE proc_view_order_products (
	view_order_id	INT
)
BEGIN
	SELECT 	PRODUCT.pr_id, PRODUCT.pr_name, PRODUCT_ORDER.size, PRODUCT_ORDER.quantity, PRODUCT_ORDER.price,
			PRODUCT_ORDER.price * PRODUCT_ORDER.quantity AS sum_price
	FROM PRODUCT, PRODUCT_ORDER
    WHERE 	PRODUCT_ORDER.order_id = view_order_id
			AND PRODUCT_ORDER.pr_id = PRODUCT.pr_id;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS proc_selling_prods;
DELIMITER $$
CREATE PROCEDURE proc_selling_prods (
	branch_id	INT,
    start_date	DATE,
    end_date	DATE
)
BEGIN
	IF (SELECT br_id FROM BRANCH WHERE BRANCH.br_id = branch_id) = NULL THEN
		SET @error_msg = CONCAT('Cannot find existing branch ID: ', CAST(branch_id as CHAR));
        SIGNAL SQLSTATE '01000'
			SET MESSAGE_TEXT = @error_msg;
	END IF;
    
    SELECT PRODUCT.pr_id, PRODUCT.pr_name, SUM(PRODUCT_ORDER.quantity * PRODUCT_ORDER.price) AS income
    FROM PRODUCT, PRODUCT_ORDER, PR_ORDER
    WHERE 	branch_id = PR_ORDER.br_id
			AND PRODUCT.pr_id = PRODUCT_ORDER.pr_id
            AND PR_ORDER.order_id = PRODUCT_ORDER.order_id
            AND (PR_ORDER.order_date BETWEEN start_date AND end_date)
	GROUP BY PRODUCT.pr_id
    ORDER BY income;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS proc_promo_sales;
DELIMITER $$
CREATE PROCEDURE proc_promo_sales ()
BEGIN
	SELECT 	PROMOTION.promo_id, PROMOTION.start_date, PROMOTION.end_date, SUM(total)
	FROM 	PR_ORDER, PROMOTION
	WHERE 	PR_ORDER.promo_id = PROMOTION.promo_id
	GROUP BY promo_id
	ORDER BY promo_id;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS proc_branch_revenue;
DELIMITER $$
CREATE PROCEDURE proc_branch_revenue(
    start_date	DATE,
    end_date	DATE
)
BEGIN
	SELECT 	BRANCH.br_id, SUM(RECEIPT.total)
	FROM 	RECEIPT
    WHERE 	branch_id = RECEIPT.br_id
			AND (RECEIPT.pay_day BETWEEN start_date AND end_date)
	GROUP BY branch_id
    ORDER BY branch_id;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS proc_cus_money_spent;
DELIMITER $$
CREATE PROCEDURE proc_cus_money_spent (
)
BEGIN
	SELECT CUSTOMER.cus_id, CUSTOMER.cus_name, SUM(RECEIPT.total) AS total_spent
    FROM 	RECEIPT, CUSTOMER
    WHERE 	RECEIPT.cus_id = CUSTOMER.cus_id
    GROUP BY cus_id
    ORDER BY total_spent;
END $$
DELIMITER ;
 




