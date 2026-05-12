import 'package:workmanager/workmanager.dart';

import '../models/alarm.dart';
import '../models/weather_data.dart';
import 'cache_service.dart';
import 'notification_service.dart';
import 'open_meteo_service.dart';

const String _backgroundTaskName = 'weatherAlarmCheck';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _backgroundTaskName) {
      await _evaluateAlarms();
    }
    return true;
  });
}

class BackgroundService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _backgroundTaskName,
      _backgroundTaskName,
      frequency: const Duration(hours: 3),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_backgroundTaskName);
  }
}

Future<void> _evaluateAlarms() async {
  await CacheService.init();
  await NotificationService.init();

  final alarms = await CacheService.getAlarms();
  final enabledAlarms = alarms.where((a) => a.enabled).toList();

  for (final alarm in enabledAlarms) {
    try {
      final forecast = await OpenMeteoService.fetchHourlyForecast(
        alarm.location.latitude,
        alarm.location.longitude,
      );

      final matchingPeriods = _findMatchingPeriods(alarm, forecast);
      if (matchingPeriods.isEmpty) {
        // Condition not met — check if we should reset
        if (alarm.lastTriggeredAt != null) {
          final resetDuration = const Duration(hours: 2);
          final lastMatch = _findLastMatchingTime(alarm, forecast);
          if (lastMatch == null ||
              DateTime.now().difference(lastMatch) > resetDuration) {
            final resetAlarm = alarm.copyWith(
              clearLastTriggeredAt: true,
              lastResetAt: DateTime.now(),
            );
            await CacheService.saveAlarm(resetAlarm);
          }
        }
        continue;
      }

      final firstMatch = matchingPeriods.first;

      // If already triggered for this period, skip
      if (alarm.lastTriggeredAt != null &&
          firstMatch.difference(alarm.lastTriggeredAt!).abs() <
              const Duration(hours: 1)) {
        continue;
      }

      // Schedule notice notification
      final noticeTime = firstMatch.subtract(
        Duration(hours: alarm.noticePeriodHours),
      );
      if (noticeTime.isAfter(DateTime.now())) {
        await NotificationService.scheduleNotification(
          id: '${alarm.id}_notice'.hashCode,
          title: 'Alarm notice: ${alarm.title}',
          body:
              '${alarm.weatherCondition} expected in ${alarm.location.name} at ${firstMatch.hour}:00',
          scheduledDate: noticeTime,
        );
      }

      // Schedule exact-time notification
      if (firstMatch.isAfter(DateTime.now())) {
        await NotificationService.scheduleNotification(
          id: '${alarm.id}_now'.hashCode,
          title: 'Alarm: ${alarm.title}',
          body:
              '${alarm.weatherCondition} is now occurring in ${alarm.location.name}',
          scheduledDate: firstMatch,
        );
      } else {
        // If it's already happening, show immediately
        await NotificationService.showNotification(
          id: '${alarm.id}_now'.hashCode,
          title: 'Alarm: ${alarm.title}',
          body:
              '${alarm.weatherCondition} is now occurring in ${alarm.location.name}',
        );
      }

      // Update alarm lastTriggeredAt
      final updatedAlarm = alarm.copyWith(lastTriggeredAt: firstMatch);
      await CacheService.saveAlarm(updatedAlarm);
    } catch (e) {
      // Silently fail for individual alarms to not block others
    }
  }
}

List<DateTime> _findMatchingPeriods(Alarm alarm, WeatherForecast forecast) {
  final results = <DateTime>[];
  for (final day in forecast.days) {
    for (final hour in day.hourly) {
      if (_matchesAlarm(alarm, hour)) {
        results.add(hour.time);
      }
    }
  }
  return results;
}

DateTime? _findLastMatchingTime(Alarm alarm, WeatherForecast forecast) {
  DateTime? last;
  for (final day in forecast.days) {
    for (final hour in day.hourly) {
      if (_matchesAlarm(alarm, hour)) {
        last = hour.time;
      }
    }
  }
  return last;
}

bool _matchesAlarm(Alarm alarm, HourlyWeather hour) {
  // Check temperature
  if (alarm.temperature != null) {
    if (alarm.weatherCondition == 'sunny' || alarm.weatherCondition == 'cloudy') {
      // For these conditions we assume the user wants temp >= threshold
      if (hour.temperature < alarm.temperature!) return false;
    } else {
      if (hour.temperature > alarm.temperature!) return false;
    }
  }

  // Check weather condition (simplified mapping)
  final code = hour.weatherCode;
  switch (alarm.weatherCondition) {
    case 'sunny':
      return code == 0 || code == 1;
    case 'partlyCloudy':
      return code == 2;
    case 'cloudy':
      return code == 3;
    case 'foggy':
      return code == 45 || code == 48;
    case 'rainy':
      return code >= 51 && code <= 67 || code >= 80 && code <= 82;
    case 'snowy':
      return code >= 71 && code <= 77 || code >= 85 && code <= 86;
    case 'stormy':
      return code == 95 || code == 96 || code == 99;
    case 'thunderstorm':
      return code == 95 || code == 96 || code == 99;
    case 'hail':
      return code == 96 || code == 99;
    case 'windy':
      return hour.windSpeed > 20; // arbitrary windy threshold
    default:
      return false;
  }
}
