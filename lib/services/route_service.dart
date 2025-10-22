import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/route.dart';
import '../models/delivery.dart';
import '../config/supabase_config.dart';

class RouteService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Route> _routes = [];
  Route? _currentRoute;
  bool _isLoading = false;
  String? _error;

  List<Route> get routes => _routes;
  Route? get currentRoute => _currentRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRoutesForDriver(String driverId) async {
    _setLoading(true);
    _clearError();

    try {
      final response =
          await _supabase.from(SupabaseConfig.routesTable).select('''
            *,
            ${SupabaseConfig.stopsTable} (*)
          ''').eq('driver_id', driverId).order('date', ascending: false);

      _routes = (response as List).map((json) => Route.fromJson(json)).toList();

      // Находим текущий маршрут (сегодняшний и не завершенный)
      _currentRoute = _routes.cast<Route?>().firstWhere(
            (route) => route != null && route.isToday && !route.isCompleted,
            orElse: () => _routes.isNotEmpty ? _routes.first : null,
          );

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки маршрутов: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> loadRouteDetails(String routeId) async {
    _setLoading(true);
    _clearError();

    try {
      final response =
          await _supabase.from(SupabaseConfig.routesTable).select('''
            *,
            ${SupabaseConfig.stopsTable} (*)
          ''').eq('id', routeId).single();

      _currentRoute = Route.fromJson(response);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Ошибка загрузки деталей маршрута: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<bool> startRoute(String routeId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase
          .from(SupabaseConfig.routesTable)
          .update({
            'status': 'in_progress',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', routeId)
          .select()
          .single();

      final updatedRoute = Route.fromJson(response);

      // Обновляем в списке маршрутов
      final index = _routes.indexWhere((r) => r.id == routeId);
      if (index != -1) {
        _routes[index] = updatedRoute;
      }

      _currentRoute = updatedRoute;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка начала маршрута: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> completeRoute(String routeId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase
          .from(SupabaseConfig.routesTable)
          .update({
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', routeId)
          .select()
          .single();

      final updatedRoute = Route.fromJson(response);

      // Обновляем в списке маршрутов
      final index = _routes.indexWhere((r) => r.id == routeId);
      if (index != -1) {
        _routes[index] = updatedRoute;
      }

      _currentRoute = updatedRoute;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка завершения маршрута: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateDeliveryStatus(
    String deliveryId,
    String status, {
    String? photoUrl,
    String? signatureUrl,
    String? failureReason,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == 'completed') {
        updates['completed_at'] = DateTime.now().toIso8601String();
        if (photoUrl != null) updates['photo_url'] = photoUrl;
        if (signatureUrl != null) updates['signature_url'] = signatureUrl;
      }

      if (status == 'failed' && failureReason != null) {
        updates['failure_reason'] = failureReason;
      }

      final response = await _supabase
          .from(SupabaseConfig.stopsTable)
          .update(updates)
          .eq('id', deliveryId)
          .select()
          .single();

      final updatedDelivery = Delivery.fromJson(response);

      // Обновляем доставку в текущем маршруте
      if (_currentRoute != null) {
        final deliveries = _currentRoute!.deliveries.map((d) {
          return d.id == deliveryId ? updatedDelivery : d;
        }).toList();

        final completedCount = deliveries.where((d) => d.isCompleted).length;

        _currentRoute = _currentRoute!.copyWith(
          deliveries: deliveries,
          completedDeliveries: completedCount,
        );

        // Обновляем в списке маршрутов
        final routeIndex = _routes.indexWhere((r) => r.id == _currentRoute!.id);
        if (routeIndex != -1) {
          _routes[routeIndex] = _currentRoute!;
        }
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка обновления статуса доставки: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<List<Delivery>> getDeliveriesForRoute(String routeId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.stopsTable)
          .select()
          .eq('route_id', routeId)
          .order('sequence_number', ascending: true);

      return (response as List).map((json) => Delivery.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Ошибка загрузки доставок: $e');
      return [];
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
