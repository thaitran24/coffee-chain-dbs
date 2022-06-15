USE coffee_db;


DROP PROCEDURE IF EXISTS Get_Branch_Material;
delimiter //
CREATE PROCEDURE Get_Branch_Material
(branch_id INT)
BEGIN
	SELECT M.m_id, M.m_name, SUM(B.quantity) AS branch_quantity
	FROM  MATERIAL M, M_BATCH B, EMPLOYEE E
	WHERE M.m_id = B.m_id AND mng_id = emp_id AND br_id = branch_id
	GROUP BY M.m_id, M.m_name
	ORDER BY M.m_id;
END//


delimiter ;
DROP PROCEDURE IF EXISTS Get_Branch_Income;
delimiter //
CREATE PROCEDURE Get_Branch_Income
(o_month INT, o_year INT)
BEGIN
	SELECT br_id AS branch_id, SUM(total) AS monthly_income
	FROM  PR_ORDER O, EMPLOYEE E
	WHERE O.emp_id = E.emp_id AND stat = 1 AND MONTH(order_date) = o_month AND YEAR(order_date) = o_year
	GROUP BY br_id
	ORDER BY SUM(total) DESC;
END//
delimiter ;