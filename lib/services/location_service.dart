import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

// Импорты для мобильных платформ
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isTracking = false;
  bool _isLoading = false;
  String? _error;
  Timer? _updateTimer;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> requestLocationPermission() async {
    _setLoading(true);
    _clearError();

    try {
      if (kIsWeb) {
        // Для веб-платформы всегда возвращаем true
        _setLoading(false);
        return true;
      }

      final status = kIsWeb
          ? PermissionStatus.granted
          : await Permission.location.request();

      if (status.isGranted) {
        _setLoading(false);
        return true;
      } else {
        _setError('Разрешение на доступ к геолокации не предоставлено');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Ошибка запроса разрешения: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> getCurrentLocation() async {
    _setLoading(true);
    _clearError();

    try {
      if (kIsWeb) {
        // Для веб-платформы создаем фиктивную позицию
        _currentPosition = Position(
          latitude: 55.7558,
          longitude: 37.6176,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        _setLoading(false);
        notifyListeners();
        return true;
      }

      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        _setError('Нет разрешения на доступ к геолокации');
        _setLoading(false);
        return false;
      }

      final position = kIsWeb
          ? Position(
              latitude: 55.7558,
              longitude: 37.6176,
              timestamp: DateTime.now(),
              accuracy: 10.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            )
          : await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 10),
            );

      _currentPosition = position;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка получения местоположения: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> startLocationTracking() async {
    if (_isTracking) return;

    if (kIsWeb) {
      // Для веб-платформы просто устанавливаем фиктивную позицию
      _isTracking = true;
      _currentPosition = Position(
        latitude: 55.7558,
        longitude: 37.6176,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
      notifyListeners();
      return;
    }

    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      _setError('Нет разрешения на доступ к геолокации');
      return;
    }

    _isTracking = true;
    notifyListeners();

    // Настройка потока позиций
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Обновлять каждые 10 метров
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentPosition = position;
        notifyListeners();
      },
      onError: (error) {
        _setError('Ошибка отслеживания: ${error.toString()}');
      },
    );

    // Запуск периодического обновления в Supabase
    _startPeriodicUpdate();
  }

  void stopLocationTracking() {
    _isTracking = false;
    _positionStream?.cancel();
    _positionStream = null;
    _updateTimer?.cancel();
    _updateTimer = null;
    notifyListeners();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(
      SupabaseConfig.locationUpdateInterval,
      (timer) {
        if (_currentPosition != null) {
          _updateLocationInSupabase(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
        }
      },
    );
  }

  Future<void> _updateLocationInSupabase(double lat, double lng) async {
    try {
      // Этот метод будет вызываться из AuthService
      // Здесь мы только логируем обновление
      debugPrint('Обновление локации: $lat, $lng');
    } catch (e) {
      debugPrint('Ошибка обновления локации в Supabase: $e');
    }
  }

  Future<bool> _checkLocationPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.location.status;
    return status.isGranted;
  }

  double? calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    if (_currentPosition == null) return null;

    if (kIsWeb) {
      // Простое вычисление расстояния для веб-платформы
      return 100.0; // Фиктивное расстояние
    }

    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      if (kIsWeb) {
        return 'Москва, Россия'; // Фиктивный адрес для веб-платформы
      }

      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
      }
      return null;
    } catch (e) {
      debugPrint('Ошибка получения адреса: $e');
      return null;
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

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
