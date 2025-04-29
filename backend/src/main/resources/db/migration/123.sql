-- Create roles table
CREATE TABLE roles (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       name VARCHAR(60) UNIQUE
);

-- Create users table
CREATE TABLE users (
                       id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       username VARCHAR(200) NOT NULL UNIQUE,
                       email VARCHAR(255) UNIQUE,
                       patronymic VARCHAR(255),
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       status INT DEFAULT 1,
                       phone VARCHAR(20),
                       password VARCHAR(255),
                       name VARCHAR(255),
                       image VARCHAR(255),
                       born_date TIMESTAMP,
                       surname VARCHAR(255)
);

-- Create indexes for users table
CREATE INDEX idx_users_email ON users(email);

-- Create user_roles junction table
CREATE TABLE user_roles (
                            user_id BIGINT NOT NULL,
                            role_id BIGINT NOT NULL,
                            PRIMARY KEY (user_id, role_id),
                            FOREIGN KEY (user_id) REFERENCES users(id),
                            FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Create addresses table
CREATE TABLE addresses (
                           id BIGINT AUTO_INCREMENT PRIMARY KEY,
                           user_id BIGINT NOT NULL,
                           street VARCHAR(255) NOT NULL,
                           city VARCHAR(100) NOT NULL,
                           postal_code VARCHAR(20),
                           country VARCHAR(100) DEFAULT 'Беларусь',
                           is_primary BOOLEAN DEFAULT FALSE,
                           apartment_no VARCHAR(255),
                           building_no VARCHAR(255) NOT NULL,
                           FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create index for addresses
CREATE INDEX idx_addresses_user ON addresses(user_id);

-- Create brigade table
CREATE TABLE brigade (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         number VARCHAR(50) NOT NULL UNIQUE,
                         brigadier_id BIGINT NOT NULL,
                         FOREIGN KEY (brigadier_id) REFERENCES users(id)
);

-- Create orders table
CREATE TABLE orders (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                        client_id BIGINT NOT NULL,
                        brigadier_id BIGINT,
                        address_id BIGINT NOT NULL,
                        order_details TEXT NOT NULL,
                        created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        status VARCHAR(50) DEFAULT 'NEW',
                        price DECIMAL(15, 2),
                        start_date DATE,
                        end_date DATE,
                        service_type VARCHAR(255) NOT NULL,
                        brigade_id BIGINT,
                        FOREIGN KEY (client_id) REFERENCES users(id),
                        FOREIGN KEY (brigadier_id) REFERENCES users(id),
                        FOREIGN KEY (address_id) REFERENCES addresses(id),
                        FOREIGN KEY (brigade_id) REFERENCES brigade(id)
);

-- Create index for orders status
CREATE INDEX idx_orders_status ON orders(status);

-- Create reviews table

-- Create notifications table
CREATE TABLE notifications (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
                               created_at DATE NOT NULL,
                               message VARCHAR(255) NOT NULL,
                               order_id BIGINT NOT NULL,
                               user_id BIGINT NOT NULL,
                               FOREIGN KEY (order_id) REFERENCES orders(id),
                               FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create message table
CREATE TABLE message (
                         id BIGINT AUTO_INCREMENT PRIMARY KEY,
                         content VARCHAR(255),
                         is_read BOOLEAN NOT NULL,
                         timestamp TIMESTAMP,
                         order_id BIGINT,
                         recipient_id BIGINT,
                         sender_id BIGINT,
                         FOREIGN KEY (order_id) REFERENCES orders(id),
                         FOREIGN KEY (recipient_id) REFERENCES users(id),
                         FOREIGN KEY (sender_id) REFERENCES users(id)
);

-- Create brigade_masters junction table
CREATE TABLE brigade_masters (
                                 brigade_id BIGINT NOT NULL,
                                 master_id BIGINT NOT NULL,
                                 PRIMARY KEY (brigade_id, master_id),
                                 FOREIGN KEY (brigade_id) REFERENCES brigade(id),
                                 FOREIGN KEY (master_id) REFERENCES users(id)
);

-- Create order_masters junction table
CREATE TABLE order_masters (
                               order_id BIGINT NOT NULL,
                               master_id BIGINT NOT NULL,
                               PRIMARY KEY (order_id, master_id),
                               FOREIGN KEY (order_id) REFERENCES orders(id),
                               FOREIGN KEY (master_id) REFERENCES users(id)
);

-- Create qualification table
CREATE TABLE qualification (
                               id BIGINT PRIMARY KEY,
                               name VARCHAR(255)
);

-- Create master_qualification junction table
CREATE TABLE master_qualification (
                                      user_id BIGINT NOT NULL,
                                      qualification_id BIGINT NOT NULL,
                                      FOREIGN KEY (user_id) REFERENCES users(id),
                                      FOREIGN KEY (qualification_id) REFERENCES qualification(id)
);

