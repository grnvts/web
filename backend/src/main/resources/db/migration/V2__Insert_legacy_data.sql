-- Вставка тестового пользователя (как в вашем примере)
INSERT INTO users (id, born_date, created_date, email, image, name, password, real_password, status, surname, uname)
VALUES (
           1,
           '1990-01-01 00:00:00',
           CURRENT_TIMESTAMP,
           'user@example.com',
           NULL,
           'John',
           '$2a$10$somehashedpassword',
           'plaintextpassword',
           1,
           'Doe',
           'johndoe'
       );