# Preview And Inspector

This project now supports two separate presentation workflows:

1. Screen screenshots from the real application.
2. Layout previews and mockups from a separate preview catalog.

## 1. Run the real application

Use the standard entrypoint:

```bash
flutter run -d chrome lib/main.dart
```

This mode is used for:
- full user flows;
- authentication checks;
- screenshots of working screens;
- live debugging with backend access.

## 2. Run the preview catalog

Use the preview entrypoint:

```bash
flutter run -d chrome lib/main_storybook.dart
```

This opens a separate catalog with:
- login screen;
- signup screen;
- home screen for user, brigadier and admin roles;
- admin create-user screen;
- static layout mockups for orders, ratings, reviews and notifications.

This mode is convenient for:
- screenshots of isolated screens;
- diploma illustrations;
- quick UI review without navigating through the whole app;
- showing alternative layouts and mockups.

## 3. Open Widget Inspector

Widget Inspector is built into Flutter DevTools. No package installation is required.

In Android Studio or IntelliJ IDEA:

1. Run the application in debug mode.
2. Open `View` -> `Tool Windows` -> `Flutter Inspector`.
3. Use `Select Widget Mode` to click any UI element on the running app.
4. Open `Layout Explorer` to inspect padding, constraints and flex layout.

In terminal workflow:

```bash
flutter run -d chrome lib/main.dart
flutter pub global run devtools
```

Then open DevTools in the browser and choose `Inspector`.

## What to show in the diploma

Recommended set:

1. Screenshots of the main application screens from `lib/main.dart`.
2. Screenshots of the preview catalog from `lib/main_storybook.dart`.
3. One or two screenshots from Widget Inspector with the widget tree and layout explorer.
