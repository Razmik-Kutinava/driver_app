import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isInitialized = false;
  bool _hasPermission = false;

  bool get isInitialized => _isInitialized;
  bool get hasPermission => _hasPermission;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        // Notifications not supported on web
        _isInitialized = true;
        _hasPermission = false;
        return;
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      _isInitialized = await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      ) ?? false;

      if (_isInitialized) {
        await _requestPermissions();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка инициализации уведомлений: $e');
      _isInitialized = false;
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (kIsWeb) return;

      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        _hasPermission = await androidPlugin.requestNotificationsPermission() ?? false;
      }

      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        _hasPermission = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ?? false;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка запроса разрешений на уведомления: $e');
      _hasPermission = false;
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to appropriate screen
    // This would typically use a navigation service or global navigator key
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized || !_hasPermission || kIsWeb) {
      debugPrint('Notifications not available');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default',
        channelDescription: 'Default notification channel',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Ошибка показа уведомления: $e');
    }
  }

  Future<void> showRouteAssignedNotification(String routeId) async {
    await showNotification(
      id: routeId.hashCode,
      title: 'Новый маршрут',
      body: 'Вам назначен новый маршрут',
      payload: 'route:$routeId',
    );
  }

  Future<void> showDeliveryReminderNotification(String deliveryAddress) async {
    await showNotification(
      id: deliveryAddress.hashCode,
      title: 'Напоминание о доставке',
      body: 'Доставка по адресу: $deliveryAddress',
      payload: 'delivery:$deliveryAddress',
    );
  }

  Future<void> showMessageNotification(String from, String message) async {
    await showNotification(
      id: from.hashCode,
      title: 'Новое сообщение от $from',
      body: message,
      payload: 'message:$from',
    );
  }

  // Subscribe to Supabase realtime notifications
  Future<void> subscribeToNotifications(String driverId) async {
    try {
      _supabase
          .from(SupabaseConfig.notificationsTable)
          .stream(primaryKey: ['id'])
          .eq('driver_id', driverId)
          .listen((data) {
            for (var notification in data) {
              _handleRealtimeNotification(notification);
            }
          });
    } catch (e) {
      debugPrint('Ошибка подписки на уведомления: $e');
    }
  }

  void _handleRealtimeNotification(Map<String, dynamic> notification) {
    final type = notification['type'] as String?;
    final title = notification['title'] as String? ?? 'Уведомление';
    final body = notification['body'] as String? ?? '';

    switch (type) {
      case 'route_assigned':
        showRouteAssignedNotification(notification['route_id'] ?? '');
        break;
      case 'delivery_reminder':
        showDeliveryReminderNotification(body);
        break;
      case 'message':
        showMessageNotification(notification['from'] ?? 'Диспетчер', body);
        break;
      default:
        showNotification(
          id: notification['id'].hashCode,
          title: title,
          body: body,
        );
    }
  }

  Future<void> cancelNotification(int id) async {
    if (!_isInitialized || kIsWeb) return;

    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('Ошибка отмены уведомления: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized || kIsWeb) return;

    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Ошибка отмены всех уведомлений: $e');
    }
  }
}
