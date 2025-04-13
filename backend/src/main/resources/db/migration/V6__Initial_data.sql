-- Заполнение ролей
INSERT INTO roles (name) VALUES
                             ('ROLE_ADMIN'),
                             ('ROLE_USER'),
                             ('ROLE_BRIGADIER')
    ON CONFLICT (name) DO NOTHING;

-- Пример администратора (пароль: admin123)
INSERT INTO users (username, email, password_hash, first_name, last_name, status) VALUES
    ('admin', 'admin@example.com',
     '$2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KsnmG',
     'Admin', 'User', 1);

-- Назначение ролей
INSERT INTO user_roles (user_id, role_id)
VALUES (
           (SELECT id FROM users WHERE username = 'admin'),
           (SELECT id FROM roles WHERE name = 'ROLE_ADMIN')
       );