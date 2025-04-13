-- Для Flyway 6.x+
UPDATE flyway_schema_history
SET checksum = 911337636
WHERE version = '2';
UPDATE flyway_schema_history
SET description = 'Scheme'
WHERE version = '2';