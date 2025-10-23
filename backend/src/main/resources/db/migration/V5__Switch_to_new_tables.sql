-- 1. Удаляем ВСЕ таблицы, которые ссылаются на старые таблицы (в обратном порядке зависимостей)
DROP TABLE IF EXISTS user_roles CASCADE;          -- старая связь пользователь-роли
DROP TABLE IF EXISTS old_user_roles CASCADE;
DROP TABLE IF EXISTS users_buildings CASCADE;

-- 2. Удаляем таблицы, ссылающиеся на 'roles' или 'users'
-- (в вашем случае — только user_roles, уже удалена выше)

-- 3. Теперь удаляем СТАРЫЕ основные таблицы
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS roles CASCADE;               -- ← вот эта строка решает проблему!

-- 4. Переименовываем НОВЫЕ таблицы в финальные имена
ALTER TABLE new_users RENAME TO users;
ALTER TABLE new_roles RENAME TO roles;
ALTER TABLE new_user_roles RENAME TO user_roles;

-- 5. Удаляем остальные старые таблицы (owner, building и т.д.)
DROP TABLE IF EXISTS flat CASCADE;
DROP TABLE IF EXISTS apartment CASCADE;
DROP TABLE IF EXISTS building_adress CASCADE;
DROP TABLE IF EXISTS building CASCADE;
DROP TABLE IF EXISTS owner CASCADE;