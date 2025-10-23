-- Вставляем администратора, если его нет
INSERT INTO users (username, email, password_hash, first_name, last_name, status)
SELECT 'admin', 'admin@example.com', '$2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KsnmG', 'Admin', 'User', 1
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin');