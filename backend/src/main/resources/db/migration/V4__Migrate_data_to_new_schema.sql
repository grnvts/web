-- 1. Миграция ролей
INSERT INTO new_roles (name)
SELECT DISTINCT
    CASE
        WHEN name = 'admin' THEN 'ROLE_ADMIN'
        WHEN name = 'manager' THEN 'ROLE_BRIGADIR'
        ELSE 'ROLE_CLIENT'
        END
FROM roles
WHERE name IN ('admin', 'manager');

-- Добавляем ROLE_MASTER отдельно
INSERT INTO new_roles (name)
SELECT 'ROLE_MASTER'
    WHERE NOT EXISTS (SELECT 1 FROM new_roles WHERE name = 'ROLE_MASTER');

-- 2. Миграция пользователей
INSERT INTO new_users (
    id, username, email, password_hash, first_name, last_name, status, created_at
)
SELECT
    id,
    uname,
    email,
    CASE
        WHEN password LIKE '$2a$%' THEN password
        ELSE '$2a$10$dummyhashforlegacyusers' -- временный хэш
        END,
    name,
    surname,
    COALESCE(status, 1),
    COALESCE(created_date, CURRENT_TIMESTAMP)
FROM users;

-- 3. Миграция связей пользователь-роль
INSERT INTO new_user_roles (user_id, role_id)
SELECT
    ur.user_id,
    nr.id
FROM user_roles ur
         JOIN roles r ON ur.role_id = r.id
         JOIN new_roles nr ON nr.name =
                              CASE
                                  WHEN r.name = 'admin' THEN 'ROLE_ADMIN'
                                  WHEN r.name = 'manager' THEN 'ROLE_BRIGADIR'
                                  ELSE 'ROLE_CLIENT'
                                  END;

-- 4. Миграция адресов (из owner + building_adress)
INSERT INTO addresses (user_id, address_type, street, city, is_primary)
SELECT
    o.id,
    'home',
    COALESCE(ba.street, 'Не указано'),
    COALESCE(ba.city, 'Не указано'),
    TRUE
FROM owner o
         LEFT JOIN building_adress ba ON o.id = ba.building_id;