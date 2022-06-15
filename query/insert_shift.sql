USE coffee_db;

CALL insert_shift("S00001", "08:00:00", "12:00:00");
CALL insert_shift("S00002", "12:00:00", "16:00:00");
CALL insert_shift("S00003", "16:00:00", "20:00:00");
CALL insert_shift("S00004", "20:00:00", "23:00:00");

