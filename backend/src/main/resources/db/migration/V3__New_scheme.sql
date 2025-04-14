-- 1. Создание новых таблиц (без удаления старых, чтобы не потерять данные)
CREATE TABLE IF NOT EXISTS new_users (
                                         id BIGSERIAL PRIMARY KEY,
                                         username VARCHAR(200) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    patronymic VARCHAR(255),
    born_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status INTEGER DEFAULT 1,
    profile_image VARCHAR(255),
    phone VARCHAR(20)
    );

CREATE TABLE IF NOT EXISTS roles (
                                     id BIGSERIAL PRIMARY KEY,
                                     name VARCHAR(60) UNIQUE NOT NULL
    );

CREATE TABLE IF NOT EXISTS user_roles (
                                          user_id BIGINT NOT NULL REFERENCES new_users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
    );

CREATE TABLE IF NOT EXISTS addresses (
                                         id BIGSERIAL PRIMARY KEY,
                                         user_id BIGINT NOT NULL REFERENCES new_users(id) ON DELETE CASCADE,
    address_type VARCHAR(50) NOT NULL,
    street VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    is_primary BOOLEAN DEFAULT FALSE
    );

-- 2. Перенос данных из текущей таблицы `users` в `new_users`
INSERT INTO new_users (
    id, username, email, password_hash,
    first_name, last_name, status, created_at
)
SELECT
    id,
    uname,
    email,
    -- Если пароль уже хэширован (например, bcrypt), оставляем как есть
    CASE
        WHEN password LIKE '$2a$%' THEN password
        ELSE CONCAT('$2a$10$', SUBSTRING(MD5(RANDOM()::TEXT) FOR 22)) -- Временный хэш
        END,
    name,
    surname,
    COALESCE(status, 1),
    COALESCE(created_date, CURRENT_TIMESTAMP)
FROM users;  -- Ваша текущая таблица пользователей


-- 4. Перенос связей пользователь-роль (если есть старая таблица `user_roles`)
INSERT INTO user_roles (user_id, role_id)
SELECT
    ur.user_id,
    (SELECT id FROM roles WHERE name =
                                CASE
                                    WHEN r.name = 'admin' THEN 'ROLE_ADMIN'
                                    WHEN r.name = 'manager' THEN 'ROLE_BRIGADIR'
                                    ELSE 'ROLE_CLIENT'
                                    END)
FROM user_roles ur
         JOIN roles r ON ur.role_id = r.id;

-- 5. Перенос адресов из `owner` (если есть)
INSERT INTO addresses (user_id, address_type, street, city, is_primary)
SELECT
    o.id,
    'home',
    COALESCE(ba.street, 'Не указано'),
    COALESCE(ba.city, 'Не указано'),
    TRUE
FROM owner o
         LEFT JOIN building_adress ba ON o.id = ba.building_id;

-- 6. Индексы
CREATE INDEX IF NOT EXISTS idx_new_users_email ON new_users(email);
CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);