# Building Management System (Diploma Project)

Моно‑репозиторий для сервиса управления заявками на ремонт/обслуживание зданий. Содержит backend (Spring Boot), веб‑клиент (`frontend`) и две Flutter‑админки (`admin_flutter`, `brigadier_flutter`).

## Архитектура
- **Backend:** Java 17, Spring Boot 3.2, Spring Security (JWT), Spring Data JPA/Hibernate, Flyway, ModelMapper.
- **DB:** PostgreSQL.
- **API:** REST + OpenAPI (springdoc).
- **Сборка:** Maven (wrapper в проекте), Docker/Docker Compose.
- **Тесты:** JUnit5, Mockito, MockMvc, Testcontainers/H2.

### Домены и порты
- `domain/users` (модели/DTO/репо/сервисы) предоставляет порт `UserAccessPort`.
- `domain/orders` использует `UserAccessPort` и `NotificationPort` для связи с users/notifications.
- `domain/notifications` реализует `NotificationPort`.
- Общие компоненты в `domain/common` (config, security/JWT, error, util).

## Быстрый старт (backend)
1) Скопировать переменные окружения:  
`cp backend/.env.example backend/.env` и при необходимости отредактировать.
2) Запуск в Docker:  
`docker compose -f docker-compose.backend.yml up --build`
3) Локально без Docker:  
```
cd backend
./mvnw spring-boot:run
```
Требуется JDK 17+.

## База и миграции
- Схема управляется Flyway (`src/main/resources/db/migration`).
- `spring.jpa.hibernate.ddl-auto` выключен, изменения только через миграции.

## Клиенты
- `frontend` – React SPA (npm install && npm start).
- `admin_flutter`, `brigadier_flutter` – мобильные/desktop Flutter-клиенты (см. их README/документацию).

## Тестирование
- Юнит и интеграция backend: `./mvnw test`
- В интеграциях используется H2 (PostgreSQL mode) / Testcontainers.

## Полезные команды
- Собрать jar: `./mvnw -DskipTests package`
- Собрать Docker образ backend: `docker build -t bms-backend ./backend`

## Директории
- `backend/` – сервер.
- `frontend/` – веб-клиент.
- `admin_flutter/`, `brigadier_flutter/` – мобильные/desktop клиенты.
- `docker-compose.backend.yml` – поднять DB + backend.

## Документация API
Swagger UI (с JWT Bearer схемой) доступен в dev-профиле на `/swagger-ui.html`.
