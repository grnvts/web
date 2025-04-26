-- Для Flyway 6.x+
UPDATE flyway_schema_history
SET checksum = 911337636
WHERE version = '2';
UPDATE flyway_schema_history
SET description = 'Scheme'
WHERE version = '2';
UPDATE flyway_schema_history
SET checksum = 1553400358
WHERE version = '3';
UPDATE flyway_schema_history
SET checksum = -15706828
WHERE version = '6';

SELECT * FROM orders
WHERE brigadier_id = 12;

SELECT * FROM orders WHERE brigadier_id = (SELECT id FROM users WHERE username = 'BrigadiercreatedByAdmin');