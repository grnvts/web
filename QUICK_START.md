# Быстрый старт

## Порядок запуска

### 1. Запустите бэкенд (обязательно!)

```bash
cd backend
mvn spring-boot:run
```

Дождитесь сообщения: `Started BuildingManagementSystemApplication`

Бэкенд будет доступен на `http://172.20.10.2:8501`

### 2. Откройте порт в файрволе (для мобильного приложения)

**Запустите PowerShell или CMD от имени администратора** и выполните:
```bash
netsh advfirewall firewall add rule name="Flutter Backend Port 8501" dir=in action=allow protocol=TCP localport=8501
```

### 3. Выберите приложение для запуска:

#### Вариант A: Веб-приложение (admin_flutter)
Подходит для админов и бригадиров, работает в браузере.

```bash
cd admin_flutter
flutter pub get
flutter run -d chrome
```

**Логин:**
- Администратор: любой пользователь с ролью `ROLE_ADMIN`
- Бригадир: любой пользователь с ролью `ROLE_BRIGADIER`

#### Вариант B: Мобильное приложение (brigadier_flutter)
Только для бригадиров, работает на Android телефоне.

```bash
cd brigadier_flutter
flutter pub get
flutter run
```

**Требования:**
- Android телефон подключен по USB
- Включена отладка по USB
- Телефон и компьютер в одной Wi-Fi сети

**Логин:** любой пользователь с ролью `ROLE_BRIGADIER`

## Проверка IP адреса

Если подключение не работает, проверьте IP адрес:

```bash
ipconfig | findstr /i "IPv4"
```

Если IP изменился, обновите его во всех сервисах:
- `admin_flutter/lib/services/*.dart`
- `brigadier_flutter/lib/services/*.dart`

Замените `172.20.10.2` на ваш текущий IP.

## Структура проектов

```
web/
├── backend/              # Java Spring Boot бэкенд
├── admin_flutter/        # Веб-приложение (админ + бригадир)
└── brigadier_flutter/    # Мобильное приложение (только бригадир)
```

## Полезные команды

**Проверить подключенные устройства:**
```bash
flutter devices
```

**Hot reload (обновление без перезапуска):**
- Нажмите `r` в терминале где запущен `flutter run`

**Hot restart (перезапуск):**
- Нажмите `R` (заглавная) в терминале

**Остановить приложение:**
- Нажмите `q` в терминале

## Решение проблем

См. файлы:
- `admin_flutter/README.md`
- `brigadier_flutter/ANDROID_SETUP.md`
- `brigadier_flutter/TROUBLESHOOTING.md`

