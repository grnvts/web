# Запуск бэкенда для Flutter приложения

## Проблема: ERR_CONNECTION_REFUSED

Если вы видите ошибку `ERR_CONNECTION_REFUSED`, это означает, что бэкенд сервер не запущен.

## Требования

1. **Java 17** (проверьте: `java -version`)
2. **Maven** (проверьте: `mvn -version`)
3. **PostgreSQL** должен быть запущен и доступен на `localhost:5432`
4. База данных `repair_service_db` должна существовать

## Запуск бэкенда

### Вариант 1: Через Maven (из папки backend)

```bash
cd backend
mvn spring-boot:run
```

### Вариант 2: Через IDE

1. Откройте проект в IntelliJ IDEA или Eclipse
2. Найдите класс `BuildingManagementSystemApplication.java`
3. Запустите его (Run/Debug)

### Вариант 3: Через скомпилированный JAR

```bash
cd backend
mvn clean package
java -jar target/Building-Management-System-0.0.1-SNAPSHOT.jar
```

## Проверка запуска

После запуска бэкенд должен быть доступен на:
- **API**: http://localhost:8501/api
- **Swagger UI**: http://localhost:8501/swagger-ui.html

Проверьте в браузере: http://localhost:8501/api/login (должна быть ошибка метода, но не connection refused)

## Настройки базы данных

Убедитесь, что в `backend/src/main/resources/application.properties` правильные настройки:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/repair_service_db
spring.datasource.username=postgres
spring.datasource.password=admin
```

## После запуска бэкенда

1. Дождитесь сообщения "Started BuildingManagementSystemApplication"
2. Запустите Flutter приложение:
   ```bash
   flutter run -d chrome --web-renderer html
   ```
   или
   ```bash
   flutter run -d windows
   ```

## Устранение проблем

### Порт 8501 занят
Если порт занят, либо:
- Остановите процесс, использующий порт 8501
- Или измените порт в `application.properties`: `server.port=8502`
- И обновите URL в Flutter приложении

### База данных не доступна
- Убедитесь, что PostgreSQL запущен
- Проверьте, что база данных `repair_service_db` существует
- Проверьте логин и пароль в `application.properties`

