import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _ordersKey = 'cached_orders';
  static const String _driverKey = 'cached_driver';
  static const String _statsKey = 'cached_stats';
  static const int _cacheExpirationHours = 24;

  // Cache orders
  static Future<bool> cacheOrders(List<Map<String, dynamic>> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': orders,
        'timestamp': DateTime.now().toIso8601String(),
      };
      return await prefs.setString(_ordersKey, json.encode(cacheData));
    } catch (e) {
      debugPrint('Ошибка кэширования заказов: $e');
      return false;
    }
  }

  // Get cached orders
  static Future<List<Map<String, dynamic>>?> getCachedOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_ordersKey);

      if (cachedString == null) return null;

      final cacheData = json.decode(cachedString);
      final timestamp = DateTime.parse(cacheData['timestamp']);

      // Check if cache is expired
      if (DateTime.now().difference(timestamp).inHours > _cacheExpirationHours) {
        await prefs.remove(_ordersKey);
        return null;
      }

      return List<Map<String, dynamic>>.from(cacheData['data']);
    } catch (e) {
      debugPrint('Ошибка чтения кэша заказов: $e');
      return null;
    }
  }

  // Cache driver data
  static Future<bool> cacheDriver(Map<String, dynamic> driver) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': driver,
        'timestamp': DateTime.now().toIso8601String(),
      };
      return await prefs.setString(_driverKey, json.encode(cacheData));
    } catch (e) {
      debugPrint('Ошибка кэширования водителя: $e');
      return false;
    }
  }

  // Get cached driver
  static Future<Map<String, dynamic>?> getCachedDriver() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_driverKey);

      if (cachedString == null) return null;

      final cacheData = json.decode(cachedString);
      final timestamp = DateTime.parse(cacheData['timestamp']);

      // Check if cache is expired
      if (DateTime.now().difference(timestamp).inHours > _cacheExpirationHours) {
        await prefs.remove(_driverKey);
        return null;
      }

      return Map<String, dynamic>.from(cacheData['data']);
    } catch (e) {
      debugPrint('Ошибка чтения кэша водителя: $e');
      return null;
    }
  }

  // Cache driver stats
  static Future<bool> cacheStats(Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': stats,
        'timestamp': DateTime.now().toIso8601String(),
      };
      return await prefs.setString(_statsKey, json.encode(cacheData));
    } catch (e) {
      debugPrint('Ошибка кэширования статистики: $e');
      return false;
    }
  }

  // Get cached stats
  static Future<Map<String, dynamic>?> getCachedStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_statsKey);

      if (cachedString == null) return null;

      final cacheData = json.decode(cachedString);
      final timestamp = DateTime.parse(cacheData['timestamp']);

      // Check if cache is expired
      if (DateTime.now().difference(timestamp).inHours > _cacheExpirationHours) {
        await prefs.remove(_statsKey);
        return null;
      }

      return Map<String, dynamic>.from(cacheData['data']);
    } catch (e) {
      debugPrint('Ошибка чтения кэша статистики: $e');
      return null;
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersKey);
      await prefs.remove(_driverKey);
      await prefs.remove(_statsKey);
    } catch (e) {
      debugPrint('Ошибка очистки кэша: $e');
    }
  }

  // Check if cache exists
  static Future<bool> hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_ordersKey) ||
             prefs.containsKey(_driverKey) ||
             prefs.containsKey(_statsKey);
    } catch (e) {
      return false;
    }
  }
}
