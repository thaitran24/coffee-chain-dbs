USE coffee_db;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO BRANCH VALUES("B00000", "E00000", "");
INSERT INTO EMPLOYEE VALUES("","","E00000","B00000","2000-12-31","","F","2022-01-01","11111111111","",10000,0123456789,0,"","","","E00000");
INSERT INTO PRODUCT VALUES("P00000", "", "", "");
INSERT INTO SHIFT VALUES("S00000", "00:00:00", "00:00:00");
INSERT INTO SHIFT VALUES("S00000", "00:00:00", "00:00:00");
INSERT INTO CUSTOMER VALUES("","","C00000","0123456789","F","","2022-01-01",0)

SET FOREIGN_KEY_CHECKS = 1;