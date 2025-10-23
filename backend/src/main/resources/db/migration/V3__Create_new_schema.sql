-- Новые таблицы (финальная модель)

CREATE TABLE new_users (
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

-- Обновляем roles: убираем user_id
CREATE TABLE new_roles (
                           id BIGSERIAL PRIMARY KEY,
                           name VARCHAR(60) UNIQUE NOT NULL
);

-- Новая связь пользователь-роли
CREATE TABLE new_user_roles (
                                user_id BIGINT NOT NULL REFERENCES new_users(id) ON DELETE CASCADE,
                                role_id BIGINT NOT NULL REFERENCES new_roles(id),
                                PRIMARY KEY (user_id, role_id)
);

-- Адреса
CREATE TABLE addresses (
                           id BIGSERIAL PRIMARY KEY,
                           user_id BIGINT NOT NULL REFERENCES new_users(id) ON DELETE CASCADE,
                           address_type VARCHAR(50) NOT NULL,
                           street VARCHAR(255),
                           city VARCHAR(100),
                           country VARCHAR(100),
                           postal_code VARCHAR(20),
                           is_primary BOOLEAN DEFAULT FALSE
);