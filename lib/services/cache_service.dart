import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/weather_data.dart';

class CacheService {
  static const String _settingsBox = 'settings';
  static const String _weatherBox = 'weather_cache';
  static const String _alarmsBox = 'alarms';
  static const String _areasBox = 'areas';
  static const String _locationsBox = 'locations';

  static Future<void> init() async {
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_weatherBox);
    await Hive.openBox(_alarmsBox);
    await Hive.openBox(_areasBox);
    await Hive.openBox(_locationsBox);
  }

  static Box get settingsBox => Hive.box(_settingsBox);
  static Box get weatherBox => Hive.box(_weatherBox);
  static Box get alarmsBox => Hive.box(_alarmsBox);
  static Box get areasBox => Hive.box(_areasBox);
  static Box get locationsBox => Hive.box(_locationsBox);

  static Future<bool> hasMainLocation() async {
    return settingsBox.containsKey('main_location');
  }

  static Future<void> setMainLocation(Map<String, dynamic> location) async {
    await settingsBox.put('main_location', location);
  }

  static Map<dynamic, dynamic>? getMainLocation() {
    return settingsBox.get('main_location');
  }

  static String _weatherKey(double lat, double lon) {
    return '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
  }

  static Future<WeatherForecast?> getCachedWeather(double lat, double lon) async {
    final key = _weatherKey(lat, lon);
    final data = weatherBox.get(key) as String?;
    if (data == null) return null;
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return WeatherForecast.fromResponse(json);
    } catch (_) {
      return null;
    }
  }

  static Future<void> cacheWeather(WeatherForecast forecast) async {
    final key = _weatherKey(forecast.latitude, forecast.longitude);
    await weatherBox.put(key, jsonEncode(forecast.toJson()));
  }

  static bool isCacheStale(DateTime fetchedAt, {Duration maxAge = const Duration(hours: 3)}) {
    return DateTime.now().difference(fetchedAt) > maxAge;
  }
}
