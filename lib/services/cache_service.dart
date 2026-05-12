import 'package:hive_flutter/hive_flutter.dart';

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
}
