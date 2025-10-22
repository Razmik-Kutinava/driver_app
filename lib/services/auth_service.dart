import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver.dart';
import '../config/supabase_config.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  Driver? _currentDriver;
  bool _isLoading = false;
  String? _error;

  Driver? get currentDriver => _currentDriver;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentDriver != null;

  AuthService() {
    _loadStoredDriver();
  }

  Future<void> _loadStoredDriver() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final driverId = prefs.getString('driver_id');

      if (driverId != null) {
        await _loadDriverById(driverId);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки сохраненного водителя: $e');
    }
  }

  Future<bool> loginWithPhone(String phone) async {
    _setLoading(true);
    _clearError();

    try {
      // Проверяем, существует ли водитель с таким номером
      debugPrint('Попытка входа с номером: $phone');
      debugPrint('Supabase URL: ${SupabaseConfig.url}');
      debugPrint(
          'Используемый ключ: ${SupabaseConfig.serviceKey.substring(0, 20)}...');

      // Попробуем использовать Supabase клиент с правильными настройками
      final response = await _supabase
          .from(SupabaseConfig.driversTable)
          .select('*')
          .eq('phone', phone)
          .maybeSingle();

      debugPrint('Ответ от Supabase: $response');

      if (response == null) {
        // Попробуем получить всех водителей для отладки
        final allDrivers = await _supabase
            .from(SupabaseConfig.driversTable)
            .select('id, first_name, last_name, phone')
            .limit(5);
        debugPrint('Все водители в базе: $allDrivers');

        _setError('Водитель с таким номером телефона не найден');
        _setLoading(false);
        return false;
      }

      _currentDriver = Driver.fromJson(response);
      await _saveDriverId(_currentDriver!.id);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка входа: $e');
      _setError('Ошибка входа: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateDriverProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    if (_currentDriver == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (avatar != null) updates['avatar'] = avatar;

      final response = await _supabase
          .from(SupabaseConfig.driversTable)
          .update(updates)
          .eq('id', _currentDriver!.id)
          .select()
          .single();

      _currentDriver = Driver.fromJson(response);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка обновления профиля: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateLocation(double lat, double lng) async {
    if (_currentDriver == null) return false;

    try {
      await _supabase.from(SupabaseConfig.driversTable).update({
        'current_lat': lat,
        'current_lng': lng,
        'last_location_update': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentDriver!.id);

      _currentDriver = _currentDriver!.copyWith(
        currentLat: lat,
        currentLng: lng,
        lastLocationUpdate: DateTime.now(),
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка обновления локации: $e');
      return false;
    }
  }

  Future<bool> updateFcmToken(String token) async {
    if (_currentDriver == null) return false;

    try {
      await _supabase.from(SupabaseConfig.driversTable).update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentDriver!.id);

      _currentDriver = _currentDriver!.copyWith(fcmToken: token);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Ошибка обновления FCM токена: $e');
      return false;
    }
  }

  Future<bool> updateStatus(String status) async {
    if (_currentDriver == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await _supabase
          .from(SupabaseConfig.driversTable)
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentDriver!.id)
          .select()
          .single();

      _currentDriver = Driver.fromJson(response);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка обновления статуса: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> _loadDriverById(String driverId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.driversTable)
          .select()
          .eq('id', driverId)
          .single();

      _currentDriver = Driver.fromJson(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки водителя: $e');
    }
  }

  Future<void> _saveDriverId(String driverId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_id', driverId);
  }

  Future<void> logout() async {
    _currentDriver = null;
    _clearError();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_id');

    notifyListeners();
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
