-- Insert a new user into the users table
INSERT INTO users (id, born_date, created_date, email, image, name, password, real_password, status, surname, uname)
VALUES (
    1, -- id (you might want to use a sequence or auto-increment in production)
    '1990-01-01 00:00:00', -- born_date
    CURRENT_TIMESTAMP, -- created_date (current timestamp)
    'user@example.com', -- email
    NULL, -- image (can be a path if you have images)
    'John', -- name
    '$2a$10$somehashedpassword', -- password (should be properly hashed)
    'plaintextpassword', -- real_password (not recommended for production)
    1, -- status (1 typically means active)
    'Doe', -- surname
    'johndoe' -- uname (username)
);
