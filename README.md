# Logistic Driver App

Мобильное приложение для водителей логистической компании, интегрированное с веб-админкой через Supabase.

## 🚀 Возможности

### Для водителей:
- ✅ Аутентификация по номеру телефона
- ✅ Просмотр назначенных маршрутов
- ✅ Детальная информация о доставках
- ✅ GPS трекинг в реальном времени
- ✅ Отметка статусов доставок
- ✅ Фотографирование доставок
- ✅ Чат с диспетчером
- ✅ Push-уведомления
- ✅ Профиль водителя

### Для админки:
- ✅ Отправка сообщений водителям
- ✅ Мониторинг GPS в реальном времени
- ✅ Управление маршрутами
- ✅ Push-уведомления

## 🏗️ Архитектура

```
📱 Flutter App (Водители)
    ↕️
🗄️ Supabase Database
    ↕️
💻 Web Admin (Диспетчеры)
```

## 📋 Требования

- Flutter 3.0+
- Dart 3.0+
- Android SDK 21+
- iOS 11.0+
- Supabase проект

## 🛠️ Установка

### 1. Клонирование проекта
```bash
git clone <repository-url>
cd logistic_driver_app
```

### 2. Установка зависимостей
```bash
flutter pub get
```

### 3. Настройка Supabase

#### 3.1 Обновите конфигурацию
Откройте `lib/config/supabase_config.dart` и замените:
```dart
static const String url = 'https://your-project.supabase.co';
static const String anonKey = 'your-anon-key-here';
```

#### 3.2 Выполните SQL скрипты
В Supabase Dashboard > SQL Editor выполните:
```sql
-- Выполните содержимое файла database/mobile_app_tables.sql
```

### 4. Настройка Google Maps
1. Получите API ключ в [Google Cloud Console](https://console.cloud.google.com/)
2. Обновите `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### 5. Настройка разрешений

#### Android
Разрешения уже настроены в `android/app/src/main/AndroidManifest.xml`

#### iOS
Разрешения уже настроены в `ios/Runner/Info.plist`

## 🚀 Запуск

### Development (без Sentry)
```bash
flutter run
```

### С Sentry error tracking
```bash
flutter run --dart-define=SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

### Android
```bash
flutter run
```

### iOS
```bash
flutter run
```

## 📱 Основные экраны

### 1. Экран входа
- Вход по номеру телефона
- Валидация данных

### 2. Главный экран
- Статус водителя
- Текущий маршрут
- Список всех маршрутов
- Индикатор GPS

### 3. Экран маршрутов
- Детальная информация о маршруте
- Список доставок
- Прогресс выполнения
- Кнопки управления

### 4. Экран доставки
- Адрес доставки
- Информация о получателе
- Фотографирование
- Отметка статуса

### 5. Чат
- Общение с диспетчером
- Realtime сообщения
- Индикаторы прочтения

### 6. Профиль
- Информация о водителе
- Статистика
- Настройки
- Выход из системы

## 🗄️ База данных

### Новые таблицы:
- `messages` - Сообщения между водителями и диспетчерами
- `notifications` - Уведомления для водителей
- `driver_settings` - Настройки водителей
- `delivery_photos` - Фотографии доставок
- `driver_status_log` - Лог статусов и локаций

### Интеграция с существующими таблицами:
- `drivers` - Водители
- `routes` - Маршруты
- `stops` - Остановки/доставки

## 🔧 Конфигурация

### Supabase
```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String url = 'https://fhfrjaxujwgcsdtrvmtq.supabase.co';
  static const String anonKey = 'your-anon-key';
  // ... другие настройки
}
```

### Интервалы обновления
```dart
static const Duration locationUpdateInterval = Duration(seconds: 30);
static const Duration routeRefreshInterval = Duration(minutes: 5);
static const Duration chatRefreshInterval = Duration(seconds: 10);
```

## 📦 Зависимости

### Основные:
- `supabase_flutter` - Интеграция с Supabase
- `provider` - State management
- `go_router` - Навигация
- `geolocator` - GPS трекинг
- `google_maps_flutter` - Карты
- `flutter_local_notifications` - Уведомления
- `sentry_flutter` - Error tracking

### UI:
- `cached_network_image` - Кэширование изображений
- `image_picker` - Выбор изображений
- `permission_handler` - Управление разрешениями

### Dev:
- `mockito` - Тестирование
- `sqflite` - Локальная база данных для оффлайн режима

## 🔐 Безопасность

### Row Level Security (RLS)
Все новые таблицы защищены RLS политиками:
- Водители видят только свои данные
- Админы могут создавать уведомления
- Безопасный доступ к сообщениям

### Аутентификация
- Вход по номеру телефона
- Проверка существования водителя в БД
- Сохранение сессии

### ✅ Исправленные уязвимости (v1.0.1)
- **CRITICAL**: Заменено использование service_role key на anon key
- Добавлена защита секретов через .env файлы
- Настроен .gitignore для предотвращения утечки credentials
- Добавлен Sentry для production error tracking

Подробнее см. [SECURITY.md](SECURITY.md)

## 📊 Мониторинг

### Логирование
- Ошибки отправляются в Supabase
- Отслеживание производительности
- Мониторинг использования

### Метрики
- Время загрузки экранов
- Количество доставок
- Статистика водителей

## 🚨 Уведомления

### Типы уведомлений:
- `route_assigned` - Назначен новый маршрут
- `delivery_reminder` - Напоминание о доставке
- `message` - Новое сообщение
- `system` - Системные уведомления

### Каналы:
- Локальные уведомления
- Push-уведомления (FCM)
- In-app уведомления

## 🔄 Realtime

### Подписки:
- Новые сообщения
- Обновления маршрутов
- Уведомления
- Статусы водителей

## 🧪 Тестирование

### Запуск тестов
```bash
flutter test
```

### Запуск тестов с покрытием
```bash
flutter test --coverage
```

### Тестирование на устройстве
```bash
flutter run --debug
```

### Доступные тесты
- `test/services/auth_service_test.dart` - Тесты аутентификации
- `test/services/order_service_test.dart` - Тесты работы с заказами
- `test/services/cache_service_test.dart` - Тесты кэширования

## 📱 Сборка

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Отладка

### Логи
```bash
flutter logs
```

### Проверка подключения к Supabase
```dart
// В консоли разработчика
print('Supabase URL: ${SupabaseConfig.url}');
```

## 🚀 CI/CD

### GitHub Actions
Проект настроен с автоматическими workflow:
- **CI**: Автоматическое тестирование и линтинг при каждом push
- **Release**: Автоматическая сборка при создании тега версии

### Запуск CI локально
```bash
# Форматирование
dart format .

# Анализ кода
flutter analyze

# Тесты
flutter test
```

## 📈 Новые возможности (v1.0.1)

### Добавлено:
- ✅ Сервис уведомлений с поддержкой локальных уведомлений
- ✅ Сервис кэширования для оффлайн режима
- ✅ Интеграция с Sentry для отслеживания ошибок
- ✅ Unit тесты для основных сервисов
- ✅ CI/CD pipeline с GitHub Actions
- ✅ Документация по безопасности (SECURITY.md)
- ✅ Changelog для отслеживания изменений

### Исправлено:
- 🔒 **КРИТИЧЕСКАЯ УЯЗВИМОСТЬ**: Использование service_role ключа вместо anon ключа

## 📞 Поддержка

При возникновении проблем:
1. Проверьте подключение к интернету
2. Убедитесь в правильности конфигурации Supabase
3. Проверьте разрешения приложения
4. Посмотрите [CHANGELOG.md](CHANGELOG.md) для последних изменений
5. Ознакомьтесь с [SECURITY.md](SECURITY.md) для вопросов безопасности
6. Обратитесь к разработчику

## 📄 Лицензия

Этот проект разработан для внутреннего использования логистической компании.

---

**Версия:** 1.0.0  
**Дата:** 2024  
**Разработчик:** Logistic Company
