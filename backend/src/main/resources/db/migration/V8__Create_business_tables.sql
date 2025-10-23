-- Бригады
CREATE TABLE IF NOT EXISTS brigade (
                                       id BIGSERIAL PRIMARY KEY,
                                       number VARCHAR(50) UNIQUE NOT NULL,
    brigadier_id BIGINT NOT NULL REFERENCES users(id)
    );

CREATE TABLE IF NOT EXISTS brigade_masters (
                                               brigade_id BIGINT NOT NULL REFERENCES brigade(id),
    master_id BIGINT NOT NULL REFERENCES users(id),
    PRIMARY KEY (brigade_id, master_id)
    );

-- Заказы (если ещё не созданы)
CREATE TABLE IF NOT EXISTS orders (
                                      id BIGSERIAL PRIMARY KEY,
                                      client_id BIGINT NOT NULL REFERENCES users(id),
    brigadier_id BIGINT REFERENCES users(id),
    address_id BIGINT NOT NULL REFERENCES addresses(id),
    order_details TEXT NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'NEW',
    price NUMERIC(15,2),
    start_date DATE,
    end_date DATE
    );

-- Связь заказов с бригадой (если колонка ещё не добавлена)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS brigade_id BIGINT REFERENCES brigade(id);

-- Связь заказов с мастерами
CREATE TABLE IF NOT EXISTS order_masters (
                                             order_id BIGINT NOT NULL REFERENCES orders(id),
    master_id BIGINT NOT NULL REFERENCES users(id),
    PRIMARY KEY (order_id, master_id)
    );

-- Отзывы
CREATE TABLE IF NOT EXISTS reviews (
                                       id BIGSERIAL PRIMARY KEY,
                                       order_id BIGINT NOT NULL REFERENCES orders(id),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- Индексы
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);