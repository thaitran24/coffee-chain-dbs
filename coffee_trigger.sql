delimiter ;
DROP TRIGGER IF EXISTS Check_inserted_batch;
delimiter $$        
CREATE TRIGGER Check_inserted_batch AFTER INSERT ON M_BATCH FOR EACH ROW
BEGIN 
	DECLARE b_count INT DEFAULT 0;
	SELECT COUNT(*) INTO b_count
    FROM M_BATCH
    WHERE ba_id != new.ba_id AND m_id = new.m_id;
    
    IF b_count = 0 THEN
		INSERT INTO MATERIAL
        VALUES(new.m_id, new.m_name);
    END IF;
    
END 
$$

delimiter ;
DROP TRIGGER IF EXISTS Check_updated_batch;
delimiter $$
CREATE TRIGGER Check_updated_batch AFTER UPDATE ON M_BATCH FOR EACH ROW
BEGIN 
	IF old.m_id != new.m_id || old.m_name != new.m_name THEN 
		UPDATE MATERIAL M
		SET M.m_name = new.m_name
		WHERE M.m_name = old.m_name;
	END IF;
END
$$

delimiter ;
DROP TRIGGER IF EXISTS Check_deleted_batch;
delimiter $$
CREATE TRIGGER Check_deleted_batch AFTER DELETE ON M_BATCH FOR EACH ROW
BEGIN 
	DECLARE b_count INT DEFAULT 0;
	SELECT COUNT(*) INTO b_count
	FROM M_BATCH M
    WHERE M.ba_id != old.ba_id AND M.m_id = old.m_id;
    
    IF b_count = 0 THEN
		DELETE FROM MATERIAL M
        WHERE M.m_id = old.m_id;
    END IF;
END
$$

delimiter ;


-- SET SQL_SAFE_UPDATES=0;
-- SET foreign_key_checks = 0;


