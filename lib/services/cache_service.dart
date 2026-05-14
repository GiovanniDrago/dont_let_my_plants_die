import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/alarm.dart';
import '../models/map_area.dart';
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
      // Invalidate old cache format (version < 2)
      if (json['_cacheVersion'] != 2) {
        return null;
      }
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

  // Map Areas
  static Future<List<MapArea>> getSavedAreas() async {
    final List<dynamic> data = areasBox.get('saved_areas') ?? [];
    return data.map((e) => MapArea.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveArea(MapArea area) async {
    final areas = await getSavedAreas();
    areas.removeWhere((a) => a.id == area.id);
    areas.add(area);
    await areasBox.put('saved_areas', areas.map((a) => a.toJson()).toList());
  }

  static Future<void> deleteArea(String id) async {
    final areas = await getSavedAreas();
    areas.removeWhere((a) => a.id == id);
    await areasBox.put('saved_areas', areas.map((a) => a.toJson()).toList());
  }

  // Alarms
  static Future<List<Alarm>> getAlarms() async {
    final List<dynamic> data = alarmsBox.get('alarms') ?? [];
    return data.map((e) => Alarm.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static Future<void> saveAlarm(Alarm alarm) async {
    final alarms = await getAlarms();
    alarms.removeWhere((a) => a.id == alarm.id);
    alarms.add(alarm);
    await alarmsBox.put('alarms', alarms.map((a) => a.toJson()).toList());
  }

  static Future<void> deleteAlarm(String id) async {
    final alarms = await getAlarms();
    alarms.removeWhere((a) => a.id == id);
    await alarmsBox.put('alarms', alarms.map((a) => a.toJson()).toList());
  }
}
