ALTER TABLE users DROP COLUMN IF EXISTS real_password;
ALTER TABLE users DROP COLUMN IF EXISTS first_name;
ALTER TABLE users DROP COLUMN IF EXISTS last_name;
ALTER TABLE users DROP COLUMN IF EXISTS born_date;
ALTER TABLE users DROP COLUMN IF EXISTS created_date;
ALTER TABLE users DROP COLUMN IF EXISTS profile_image;
ALTER TABLE users DROP COLUMN IF EXISTS surname;
ALTER TABLE users DROP COLUMN IF EXISTS password_hash;



ALTER TABLE roles DROP COLUMN IF EXISTS user_id;




DROP TABLE IF EXISTS users_buildings CASCADE;
DROP TABLE IF EXISTS flat CASCADE;
DROP TABLE IF EXISTS building_adress CASCADE;
DROP TABLE IF EXISTS apartment CASCADE;
DROP TABLE IF EXISTS building CASCADE;
DROP TABLE IF EXISTS owner CASCADE;





--
-- -- 4. Таблица адресов (много адресов для пользователя)
-- CREATE TABLE addresses (
--                            id BIGSERIAL PRIMARY KEY,
--                            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
--                            address_type VARCHAR(50) NOT NULL,
--                            street VARCHAR(255) NOT NULL,
--                            city VARCHAR(100) NOT NULL,
--                            postal_code VARCHAR(20),
--                            country VARCHAR(100) DEFAULT 'Беларусь',
--                            is_primary BOOLEAN DEFAULT false
-- );


-- -- 6. Таблица заказов
-- CREATE TABLE orders (
--                         id BIGSERIAL PRIMARY KEY,
--                         client_id BIGINT NOT NULL REFERENCES users(id),
--                         brigadier_id BIGINT REFERENCES users(id),
--                         address_id BIGINT NOT NULL REFERENCES addresses(id),
--                         order_details TEXT NOT NULL,
--                         created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--                         status VARCHAR(50) DEFAULT 'NEW',
--                         price NUMERIC(15,2),
--                         start_date DATE,
--                         end_date DATE
-- );

-- -- 7. Таблица отзывов
-- CREATE TABLE reviews (
--                          id BIGSERIAL PRIMARY KEY,
--                          order_id BIGINT NOT NULL REFERENCES orders(id),
--                          rating INTEGER CHECK (rating BETWEEN 1 AND 5),
--                          comment TEXT,
--                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- -- Индексы
-- CREATE INDEX idx_users_email ON users(email);
-- CREATE INDEX idx_orders_status ON orders(status);
-- CREATE INDEX idx_addresses_user ON addresses(user_id);



