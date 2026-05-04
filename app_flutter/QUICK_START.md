# Быстрый старт

## Проблема с симлинками в Windows

Если вы видите ошибку "Building with plugins requires symlink support", выполните следующие шаги:

### Решение 1: Включить Developer Mode (Рекомендуется)

1. Откройте настройки Windows:
   ```bash
   start ms-settings:developers
   ```
   Или вручную: Настройки → Обновление и безопасность → Для разработчиков

2. Включите "Режим разработчика" (Developer Mode)

3. Перезапустите терминал и попробуйте снова:
   ```bash
   flutter clean
   flutter pub get
   flutter run -d windows
   ```

### Решение 2: Использовать Web версию

Если не хотите включать Developer Mode, используйте web версию:

```bash
# С HTML рендерером (быстрее)
flutter run -d chrome --web-renderer html

# Или с CanvasKit (лучше производительность)
flutter run -d chrome --web-renderer canvaskit
```

### Решение 3: Запуск от имени администратора

Альтернатива - запустите PowerShell или командную строку от имени администратора, но это менее безопасно.

## После включения Developer Mode

После включения Developer Mode вы сможете запускать:
- Windows desktop: `flutter run -d windows`
- Web: `flutter run -d chrome`
- Web Edge: `flutter run -d edge`

