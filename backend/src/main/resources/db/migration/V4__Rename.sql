-- 1. Переименование старых таблиц (чтобы сохранить как backup)
ALTER TABLE users RENAME TO old_users;
ALTER TABLE user_roles RENAME TO old_user_roles;
ALTER TABLE owner RENAME TO old_owner;

-- 2. Переименование новых таблиц в рабочие
ALTER TABLE new_users RENAME TO users;