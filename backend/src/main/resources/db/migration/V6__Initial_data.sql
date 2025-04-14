-- 1. Добавляем администратора (если его нет)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin') THEN
        INSERT INTO users (username, email, password_hash, first_name, last_name, status)
        VALUES (
            'admin',
            'admin@example.com',
            '$2a$10$xn3LI/AjqicFYZFruSwve.681477XaVNaUQbr1gioaWPn4t1KsnmG',
            'Admin',
            'User',
            1
        );
END IF;
END $$;

-- 2. Назначаем роль администратора (если еще не назначена)
DO $$
DECLARE
admin_id BIGINT;
    admin_role_id BIGINT;
BEGIN
SELECT id INTO admin_id FROM users WHERE username = 'admin';
SELECT id INTO admin_role_id FROM roles WHERE name = 'ROLE_ADMIN';

IF admin_id IS NOT NULL AND admin_role_id IS NOT NULL AND
       NOT EXISTS (SELECT 1 FROM user_roles WHERE user_id = admin_id AND role_id = admin_role_id) THEN
        INSERT INTO user_roles (user_id, role_id) VALUES (admin_id, admin_role_id);
END IF;
END $$;