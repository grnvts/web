# Структура Flutter проекта - Руководство

## 📁 Общая структура проекта

```
admin_flutter/
├── lib/                    # Основной код приложения (ВСЯ ЛОГИКА ЗДЕСЬ)
│   ├── main.dart          # Точка входа в приложение
│   ├── screens/           # Все экраны (UI)
│   └── services/          # Сервисы для работы с API
├── pubspec.yaml           # Зависимости проекта (как package.json)
├── android/               # Настройки для Android (не трогаем)
├── web/                   # Настройки для веб-версии
└── windows/               # Настройки для Windows
```

---

## 🎯 Основные файлы и их назначение

### 1. **`lib/main.dart`** - Точка входа
**Что делает:** Запускает приложение, настраивает тему, проверяет авторизацию

**Ключевые части:**
- `MyApp` - главный виджет приложения (настройка темы)
- `AuthWrapper` - проверяет, залогинен ли пользователь
- Если залогинен → показывает `MainScreen`
- Если нет → показывает `LoginScreen`

**Когда менять:** 
- Изменение темы приложения
- Изменение логики проверки авторизации
- Глобальные настройки приложения

---

### 2. **`lib/services/`** - Работа с API

#### **`auth_service.dart`** - Авторизация
**Что делает:** Отправляет запросы на `/api/login`, сохраняет токен

**Основные методы:**
- `login(username, password)` - вход в систему
- `logout()` - выход
- `getToken()` - получить сохраненный токен
- `isAdmin()` / `isBrigadier()` - проверка роли

**Где используется:** `login_screen.dart`, `main_screen.dart`

#### **`user_service.dart`** - Работа с пользователями
**Что делает:** CRUD операции для пользователей

**Основные методы:**
- `getUsers(page, size)` - получить список пользователей
- `getUserByUsername(username)` - получить одного пользователя
- `createUser(data)` - создать пользователя
- `updateUser(username, data)` - обновить пользователя
- `deleteUser(userId)` - удалить пользователя
- `restoreUser(userId)` - восстановить пользователя

**Где используется:** `users_list_screen.dart`, `user_detail_screen.dart`, `create_user_screen.dart`

#### **`order_service.dart`** - Работа с заказами
**Что делает:** Работа с заказами

**Основные методы:**
- `getAllOrders()` - все заказы
- `getOrderById(orderId)` - один заказ
- `updateOrder(orderId, data)` - обновить заказ
- `getActiveOrdersForBrigadier()` - активные заказы для бригадира

**Где используется:** `orders_list_screen.dart`, `order_detail_screen.dart`, `order_edit_screen.dart`

#### **`brigade_service.dart`** - Работа с бригадами
**Что делает:** Работа с бригадами

**Основные методы:**
- `getAllBrigades()` - все бригады
- `getBrigadeById(brigadeId)` - одна бригада
- `getMyBrigadeMasters()` - мастера моей бригады (для бригадира)
- `addMasterToMyBrigade(userId)` - добавить мастера
- `removeMasterFromMyBrigade(userId)` - удалить мастера

**Где используется:** `brigades_list_screen.dart`, `brigade_detail_screen.dart`

**Важно:** Все сервисы используют `baseUrl = 'http://10.70.188.87:8501/api'` - это адрес вашего бэкенда!

---

### 3. **`lib/screens/`** - Все экраны (UI)

#### **`login_screen.dart`** - Экран входа
**Что делает:** Форма входа (логин + пароль)

**Ключевые элементы:**
- `TextFormField` для логина и пароля
- Кнопка "Войти"
- Вызов `AuthService.login()`
- При успехе → переход на `MainScreen`

**Когда менять:** Изменение дизайна формы входа

---

#### **`main_screen.dart`** - Главный экран (навигация)
**Что делает:** Показывает нижнюю навигацию и переключает экраны

**Ключевые элементы:**
- `BottomNavigationBar` - нижняя панель навигации
- Для админа: Пользователи, Заказы, Бригады
- Для бригадира: Мои Заказы, Моя Бригада
- Кнопка выхода

**Когда менять:** Добавление новых разделов, изменение навигации

---

#### **Экраны для Администратора:**

**`users_list_screen.dart`** - Список пользователей
- Grid/List пользователей
- Поиск, фильтрация по ролям
- Кнопка "Создать пользователя"
- Переход на `user_detail_screen.dart` при клике

**`user_detail_screen.dart`** - Детали/редактирование пользователя
- Форма редактирования всех полей пользователя
- Сохранение через `UserService.updateUser()`

**`create_user_screen.dart`** - Создание пользователя
- Форма создания нового пользователя
- Выбор роли
- Сохранение через `UserService.createUser()`

**`orders_list_screen.dart`** - Список заказов (GRID)
- Grid из 3 колонок
- Фильтрация по статусу
- Переход на `order_detail_screen.dart` при клике

**`order_detail_screen.dart`** - Детали заказа
- Просмотр всех данных заказа
- Кнопка редактирования → `order_edit_screen.dart`

**`order_edit_screen.dart`** - Редактирование заказа
- Форма редактирования заказа
- Сохранение через `OrderService.updateOrder()`

**`brigades_list_screen.dart`** - Список бригад (GRID)
- Grid из 3 колонок
- Переход на `brigade_detail_screen.dart` при клике

**`brigade_detail_screen.dart`** - Детали бригады
- Просмотр информации о бригаде
- Список мастеров
- Управление мастерами

---

#### **Экраны для Бригадира:**

**`brigadier_orders_screen.dart`** - Активные заказы бригадира
- Список активных заказов
- Группировка по датам
- Переход на `order_detail_screen.dart`

**`brigadier_brigade_manage_screen.dart`** - Управление бригадой
- Список мастеров в бригаде
- Добавление/удаление мастеров
- Использует `BrigadeService.getMyBrigadeMasters()`

---

## 🔄 Как работает навигация

```dart
// Переход на другой экран
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => UserDetailScreen(username: 'user123'),
  ),
).then((_) => _loadUsers()); // Обновить список после возврата
```

**Где используется:** Во всех экранах со списками при клике на элемент

---

## 🎨 Где находится дизайн

### **Тема приложения:**
`lib/main.dart` → `MyApp` → `ThemeData`
- Цвета, шрифты, стили кнопок, полей ввода

### **Стили карточек:**
- `orders_list_screen.dart` - карточки заказов
- `users_list_screen.dart` - карточки пользователей  
- `brigades_list_screen.dart` - карточки бригад

### **Стили форм:**
- `login_screen.dart` - форма входа
- `create_user_screen.dart` - форма создания
- `user_detail_screen.dart` - форма редактирования

---

## 📝 Где что искать

### Хочу изменить дизайн карточек заказов:
→ `lib/screens/orders_list_screen.dart` (строки 350-500)

### Хочу изменить форму входа:
→ `lib/screens/login_screen.dart`

### Хочу изменить API адрес:
→ `lib/services/auth_service.dart` (строка 6)
→ `lib/services/user_service.dart` (строка 6)
→ `lib/services/order_service.dart` (строка 6)
→ `lib/services/brigade_service.dart` (строка 6)

### Хочу добавить новый экран:
1. Создать файл в `lib/screens/new_screen.dart`
2. Добавить навигацию в `main_screen.dart` или другой экран

### Хочу изменить навигацию:
→ `lib/screens/main_screen.dart` (строки 30-80)

### Хочу изменить тему приложения:
→ `lib/main.dart` (строки 18-44)

### Хочу добавить новый API метод:
→ Соответствующий файл в `lib/services/`

---

## 🔑 Ключевые концепции Flutter

### **StatefulWidget vs StatelessWidget:**
- `StatefulWidget` - виджет с состоянием (может изменяться)
- `StatelessWidget` - статичный виджет (не изменяется)

**Пример:** `UsersListScreen` - StatefulWidget (загружает данные, обновляет список)

### **setState():**
Используется для обновления UI после изменения данных:
```dart
setState(() {
  _isLoading = false;
  _users = newUsers;
});
```

### **async/await:**
Для асинхронных операций (запросы к API):
```dart
Future<void> _loadUsers() async {
  final users = await _userService.getUsers(0, 10);
  setState(() {
    _users = users;
  });
}
```

---

## 🛠️ Полезные команды

```bash
# Запуск на веб
flutter run -d chrome

# Запуск на Windows
flutter run -d windows

# Обновить зависимости
flutter pub get

# Очистить кэш
flutter clean
```

---

## 📌 Важные моменты

1. **Все UI код** находится в `lib/screens/`
2. **Вся работа с API** находится в `lib/services/`
3. **Точка входа** - `lib/main.dart`
4. **Зависимости** - `pubspec.yaml`
5. **IP адрес бэкенда** - во всех сервисах (строка 6)

---

## 🎯 Быстрая навигация по файлам

| Что нужно изменить | Файл |
|-------------------|------|
| Дизайн карточек заказов | `screens/orders_list_screen.dart` |
| Дизайн карточек пользователей | `screens/users_list_screen.dart` |
| Дизайн карточек бригад | `screens/brigades_list_screen.dart` |
| Форма входа | `screens/login_screen.dart` |
| Навигация | `screens/main_screen.dart` |
| Тема приложения | `main.dart` |
| API адрес | Все файлы в `services/` |
| Логика авторизации | `services/auth_service.dart` |
| Работа с пользователями | `services/user_service.dart` |
| Работа с заказами | `services/order_service.dart` |
| Работа с бригадами | `services/brigade_service.dart` |

