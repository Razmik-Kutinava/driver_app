import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/driver_stats.dart';

class OrderService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Order> _orders = [];
  DriverStats? _driverStats;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  List<Order> get pendingOrders => _orders.where((o) => o.isPending).toList();
  List<Order> get inProgressOrders =>
      _orders.where((o) => o.isInProgress).toList();
  List<Order> get completedOrders =>
      _orders.where((o) => o.isCompleted).toList();
  List<Order> get returnedOrders => _orders.where((o) => o.isReturned).toList();

  DriverStats? get driverStats => _driverStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrdersForDriver(String driverId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase
          .from('orders')
          .select('*')
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      _orders = (response as List).map((json) => Order.fromJson(json)).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки заказов: $e');
      _setError('Ошибка загрузки заказов: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> loadDriverStats(String driverId) async {
    try {
      final response = await _supabase
          .from('driver_stats')
          .select('*')
          .eq('driver_id', driverId)
          .maybeSingle();

      if (response != null) {
        _driverStats = DriverStats.fromJson(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки статистики: $e');
    }
  }

  Future<bool> takeOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': 'in_progress'}).eq('id', orderId);

      // Обновляем локальный список
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: 'in_progress');
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Ошибка взятия заказа: $e');
      _setError('Ошибка взятия заказа: ${e.toString()}');
      return false;
    }
  }

  Future<bool> completeOrder(String orderId, String pinCode) async {
    try {
      await _supabase.from('orders').update({
        'status': 'completed',
        'pin_code': pinCode,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Обновляем локальный список
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: 'completed',
          pinCode: pinCode,
          completedAt: DateTime.now(),
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Ошибка завершения заказа: $e');
      _setError('Ошибка завершения заказа: ${e.toString()}');
      return false;
    }
  }

  Future<bool> returnOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': 'returned'}).eq('id', orderId);

      // Обновляем локальный список
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: 'returned');
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Ошибка возврата заказа: $e');
      _setError('Ошибка возврата заказа: ${e.toString()}');
      return false;
    }
  }

  Future<bool> addOrderFromQR(String qrCode, String driverId) async {
    try {
      // Здесь должна быть логика создания заказа из QR кода
      // Пока что создаем тестовый заказ
      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        driverId: driverId,
        customerName: 'Клиент из QR',
        customerPhone: '+7-999-000-0000',
        address: 'Адрес из QR кода',
        productName: 'Товар из QR кода',
        productPrice: 1000.0,
        status: 'pending',
        createdAt: DateTime.now(),
        qrCode: qrCode,
      );

      await _supabase.from('orders').insert(newOrder.toJson());

      _orders.insert(0, newOrder);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Ошибка добавления заказа из QR: $e');
      _setError('Ошибка добавления заказа из QR: ${e.toString()}');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
