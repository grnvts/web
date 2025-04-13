
INSERT INTO users (id, username, email, password_hash, first_name, last_name, status)
SELECT
    id,
    uname,
    email,
    password,
    name,
    surname,
    COALESCE(status, 1)
FROM old_users;

-- Перенос адресов
INSERT INTO addresses (user_id, address_type, street, city, is_primary)
SELECT
    o.id,
    'home',
    COALESCE(ba.street, 'Не указано'),
    COALESCE(ba.city, 'Не указано'),
    TRUE
FROM old_owner o
         LEFT JOIN building_adress ba ON o.id = ba.building_id;