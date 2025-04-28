CREATE TABLE brigade (
                         id BIGSERIAL PRIMARY KEY,
                         number VARCHAR(50) UNIQUE NOT NULL,
                         brigadier_id BIGINT NOT NULL REFERENCES users(id)
);

CREATE TABLE brigade_masters (
                                 brigade_id BIGINT NOT NULL REFERENCES brigade(id),
                                 master_id BIGINT NOT NULL REFERENCES users(id),
                                 PRIMARY KEY (brigade_id, master_id)
);

ALTER TABLE orders ADD COLUMN brigade_id BIGINT REFERENCES brigade(id);

CREATE TABLE order_masters (
                               order_id BIGINT NOT NULL REFERENCES orders(id),
                               master_id BIGINT NOT NULL REFERENCES users(id),
                               PRIMARY KEY (order_id, master_id)
);