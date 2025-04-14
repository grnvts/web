
DROP TABLE IF EXISTS users_buildings CASCADE;
DROP TABLE IF EXISTS flat CASCADE;
DROP TABLE IF EXISTS building_adress CASCADE;
DROP TABLE IF EXISTS apartment CASCADE;
DROP TABLE IF EXISTS building CASCADE;
DROP TABLE IF EXISTS owner CASCADE;

-- 1. Обновленная таблица пользователей
CREATE TABLE users (
                       id BIGSERIAL PRIMARY KEY,
                       username VARCHAR(200) NOT NULL UNIQUE,
                       email VARCHAR(255) UNIQUE NOT NULL,
                       password_hash VARCHAR(255) NOT NULL,
                       first_name VARCHAR(255),
                       last_name VARCHAR(255),
                       born_date DATE,
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       status INTEGER DEFAULT 1,
                       phone VARCHAR(20),
                       profile_image VARCHAR(255)
);

-- 2. Таблица ролей (3 основные роли)
CREATE TABLE roles (
                       id BIGSERIAL PRIMARY KEY,
                       name VARCHAR(60) UNIQUE NOT NULL
);

-- 3. Связь пользователь-роль (многие-ко-многим)
CREATE TABLE user_roles (
                            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                            role_id BIGINT NOT NULL REFERENCES roles(id),
                            PRIMARY KEY (user_id, role_id)
);

-- 4. Таблица адресов (много адресов для пользователя)
CREATE TABLE addresses (
                           id BIGSERIAL PRIMARY KEY,
                           user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                           address_type VARCHAR(50) NOT NULL,
                           street VARCHAR(255) NOT NULL,
                           city VARCHAR(100) NOT NULL,
                           postal_code VARCHAR(20),
                           country VARCHAR(100) DEFAULT 'Беларусь',
                           is_primary BOOLEAN DEFAULT false
);


-- 6. Таблица заказов
CREATE TABLE orders (
                        id BIGSERIAL PRIMARY KEY,
                        client_id BIGINT NOT NULL REFERENCES users(id),
                        brigadier_id BIGINT REFERENCES users(id),
                        building_id BIGINT NOT NULL REFERENCES buildings(id),
                        order_details TEXT NOT NULL,
                        created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        status VARCHAR(50) DEFAULT 'NEW',
                        price NUMERIC(15,2),
                        start_date DATE,
                        end_date DATE
);

-- 7. Таблица отзывов
CREATE TABLE reviews (
                         id BIGSERIAL PRIMARY KEY,
                         order_id BIGINT NOT NULL REFERENCES orders(id),
                         rating INTEGER CHECK (rating BETWEEN 1 AND 5),
                         comment TEXT,
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_addresses_user ON addresses(user_id);

ALTER TABLE roles DROP COLUMN IF EXISTS user_id;

-- 2. Исправляем таблицу user_roles (если она неправильно создана)
DROP TABLE IF EXISTS user_roles;

-- 3. Создаем правильную таблицу связей многие-ко-многим
CREATE TABLE user_roles (
                            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                            role_id BIGINT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
                            PRIMARY KEY (user_id, role_id)
);

-- 4. Обновляем данные (если нужно)
INSERT INTO roles (name) VALUES
                             ('ROLE_ADMIN'),
                             ('ROLE_USER'),
                             ('ROLE_BRIGADIER')
    ON CONFLICT (name) DO NOTHING;