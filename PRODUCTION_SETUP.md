# Production Setup Guide

Инструкция по подготовке приложения к production-развертыванию.

## 🔐 Шаг 1: Настройка переменных окружения

1. Скопируйте `.env.example` в `.env`:
```bash
cp .env.example .env
```

2. Заполните реальные значения в `.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-real-anon-key
GOOGLE_MAPS_API_KEY=your-google-maps-key
SENTRY_DSN=your-sentry-dsn
FCM_SERVER_KEY=your-fcm-key
DEBUG_MODE=false
```

## 🛡️ Шаг 2: Безопасность

### Обновите Supabase Config
Откройте `lib/config/supabase_config.dart` и:
1. ✅ Убедитесь что используется `anonKey` (НЕ serviceKey!)
2. Установите `isDebug = false` для production

### Настройте Sentry
Sentry теперь настраивается через environment variable:

```bash
# Для production build с Sentry:
flutter run --dart-define=SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id

# Или в release build:
flutter build apk --dart-define=SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

Для локальной разработки Sentry автоматически отключен.

## 🗺️ Шаг 3: Google Maps

### Android
1. Получите API ключ в [Google Cloud Console](https://console.cloud.google.com/)
2. Откройте `android/app/src/main/AndroidManifest.xml`
3. Замените:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_GOOGLE_MAPS_API_KEY"/>
```

### iOS
1. Откройте `ios/Runner/AppDelegate.swift`
2. Добавьте API ключ (если еще не добавлен)

## 🔔 Шаг 4: Push-уведомления (FCM)

### Android
1. Скачайте `google-services.json` из Firebase Console
2. Поместите в `android/app/google-services.json`
3. Файл уже в .gitignore - не коммитьте его!

### iOS
1. Скачайте `GoogleService-Info.plist` из Firebase Console
2. Поместите в `ios/Runner/GoogleService-Info.plist`

## 🗄️ Шаг 5: Supabase RLS Policies

Убедитесь что все RLS политики настроены:

```sql
-- Проверьте в Supabase Dashboard > Authentication > Policies

-- Пример политики для drivers table:
CREATE POLICY "Drivers can view own data"
ON drivers FOR SELECT
USING (auth.uid() = id);

-- Повторите для всех таблиц
```

## 📱 Шаг 6: Сборка

### Android Release
```bash
# Генерация keystore (первый раз)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Настройте android/key.properties:
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<location of the key store file>

# Соберите release APK
flutter build apk --release

# Или App Bundle для Google Play
flutter build appbundle --release
```

### iOS Release
```bash
# Требуется macOS и Xcode
flutter build ios --release
```

## ✅ Чеклист перед релизом

- [ ] Все API ключи заменены на реальные
- [ ] `isDebug = false` в конфигурации
- [ ] Sentry DSN настроен
- [ ] Google Maps ключи добавлены для Android/iOS
- [ ] Firebase конфигурационные файлы добавлены
- [ ] Supabase RLS политики проверены
- [ ] Тесты проходят: `flutter test`
- [ ] Код отформатирован: `dart format .`
- [ ] Анализ кода без ошибок: `flutter analyze`
- [ ] Version bump в `pubspec.yaml`
- [ ] CHANGELOG.md обновлен
- [ ] Приложение протестировано на реальных устройствах

## 🚀 Деплой

### Google Play Store
1. Создайте App Bundle: `flutter build appbundle --release`
2. Загрузите в Google Play Console
3. Заполните описание приложения
4. Настройте скриншоты
5. Отправьте на ревью

### Apple App Store
1. Соберите iOS: `flutter build ios --release`
2. Откройте Xcode: `open ios/Runner.xcworkspace`
3. Archive и Upload to App Store
4. В App Store Connect заполните информацию
5. Отправьте на ревью

## 📊 Мониторинг Production

После деплоя проверяйте:
1. **Sentry Dashboard** - ошибки в production
2. **Supabase Dashboard** - использование API, логи
3. **Firebase Console** - статистика push-уведомлений
4. **Google Play Console** - крэш-репорты, отзывы

## 🔄 Обновления

При выпуске новой версии:
1. Обновите версию в `pubspec.yaml`
2. Обновите `CHANGELOG.md`
3. Создайте git tag: `git tag v1.0.2`
4. Push с тегами: `git push --tags`
5. GitHub Actions автоматически создаст release build

## 📞 Поддержка

При проблемах с production:
1. Проверьте логи в Sentry
2. Проверьте Supabase logs
3. Проверьте Firebase Console
4. Свяжитесь с командой разработки
