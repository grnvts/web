-- Normalize role names and seed required roles

-- 1) Fix typos/incompatible names from earlier migrations
UPDATE roles SET name = 'ROLE_BRIGADIER' WHERE name = 'ROLE_BRIGADIR';
UPDATE roles SET name = 'ROLE_USER'      WHERE name = 'ROLE_CLIENT';

-- 2) Ensure required roles exist
INSERT INTO roles (name)
SELECT 'ROLE_USER'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_USER');

INSERT INTO roles (name)
SELECT 'ROLE_ADMIN'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_ADMIN');

INSERT INTO roles (name)
SELECT 'ROLE_BRIGADIER'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_BRIGADIER');

INSERT INTO roles (name)
SELECT 'ROLE_MASTER'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_MASTER');


