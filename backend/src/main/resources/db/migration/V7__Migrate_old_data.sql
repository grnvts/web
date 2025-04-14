-- 1. Перенос пользователей (без ID, чтобы избежать конфликтов)
INSERT INTO users (username, email, password_hash, first_name, last_name, status)
SELECT
    u.uname,
    u.email,
    u.password,
    u.name,
    u.surname,
    COALESCE(u.status, 1)
FROM old_users u
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE username = u.uname
);


ALTER TABLE roles DROP COLUMN IF EXISTS user_id;

-- 4. Перенос адресов (если данные доступны)
INSERT INTO addresses (user_id, address_type, street, city, is_primary)
SELECT
    u.id,
    'home',
    COALESCE(ba.street, 'Не указано'),
    COALESCE(ba.city, 'Не указано'),
    TRUE
FROM old_owner o
         LEFT JOIN building_adress ba ON o.id = ba.building_id
         JOIN users u ON u.username = o.name  -- или другой способ сопоставления
WHERE NOT EXISTS (
    SELECT 1 FROM addresses
    WHERE user_id = u.id AND street = COALESCE(ba.street, 'Не указано')
);
