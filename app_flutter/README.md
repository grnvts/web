# Flutter Admin Panel (Web)

Веб-приложение для администраторов и бригадиров.

## Запуск

### 1. Убедитесь, что бэкенд запущен:
```bash
cd backend
mvn spring-boot:run
```

Бэкенд должен быть доступен на `http://172.20.10.2:8501`

### 2. Установите зависимости:
```bash
cd admin_flutter
flutter pub get
```

### 3. Запустите приложение:

**На Web (Chrome):**
```bash
flutter run -d chrome
```

**На Web (Edge):**
```bash
flutter run -d edge
```

**На Windows:**
```bash
flutter run -d windows
```

## Доступ

- **Администратор**: логин с ролью `ROLE_ADMIN` - видит все функции (Пользователи, Заказы, Бригады)
- **Бригадир**: логин с ролью `ROLE_BRIGADIER` - видит только свои функции (Заказы, Бригада)

## Изменение IP адреса

Если IP адрес компьютера изменился, обновите в файлах:
- `lib/services/auth_service.dart`
- `lib/services/user_service.dart`
- `lib/services/order_service.dart`
- `lib/services/brigade_service.dart`

Замените `http://172.20.10.2:8501/api` на ваш текущий IP.
