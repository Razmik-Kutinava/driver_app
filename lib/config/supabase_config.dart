class SupabaseConfig {
  // ✅ ВАШИ РЕАЛЬНЫЕ ДАННЫЕ ИЗ SUPABASE
  static const String url = 'https://fhfrjaxujwgcsdtrvmtq.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoZnJqYXh1andnY3NkdHJ2bXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3NTc0OTcsImV4cCI6MjA3NjMzMzQ5N30.J0pmmx3RvGqDbczb0zZdH_GKfG2jzTM1ayRfHMAXz1c';
  static const String serviceKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZoZnJqYXh1andnY3NkdHJ2bXRxIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDc1NzQ5NywiZXhwIjoyMDc2MzMzNDk3fQ.crcKzh41Z7uUCvAMEbdCBGEv6dG9N7fZapC1oaXEJ-Q';

  // Настройки для разработки
  static const bool isDebug = true;

  // Настройки для уведомлений
  static const String fcmServerKey = 'your-fcm-server-key';

  // Настройки для карт (замените на ваш ключ)
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Настройки приложения
  static const String appName = 'Logistic Driver';
  static const String appVersion = '1.0.0';

  // Интервалы обновления
  static const Duration locationUpdateInterval = Duration(seconds: 30);
  static const Duration routeRefreshInterval = Duration(minutes: 5);
  static const Duration chatRefreshInterval = Duration(seconds: 10);

  // Настройки базы данных
  static const String driversTable = 'drivers';
  static const String routesTable = 'routes';
  static const String stopsTable = 'stops';
  static const String messagesTable = 'messages';
  static const String notificationsTable = 'notifications';
  static const String driverSettingsTable = 'driver_settings';
  static const String deliveryPhotosTable = 'delivery_photos';
  static const String driverStatusLogTable = 'driver_status_log';
}
