import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weather_data.dart';

final selectedDayIndexProvider = StateProvider<int>((ref) => 0);
final weatherMetricProvider = StateProvider<WeatherMetric>((ref) => WeatherMetric.temperature);

enum WeatherMetric { temperature, wind, humidity }

extension WeatherMetricExtension on WeatherMetric {
  String label(BuildContext context) {
    switch (this) {
      case WeatherMetric.temperature:
        return 'Temperature'; // Will use l10n in widgets
      case WeatherMetric.wind:
        return 'Wind';
      case WeatherMetric.humidity:
        return 'Humidity';
    }
  }

  String unit(BuildContext context) {
    switch (this) {
      case WeatherMetric.temperature:
        return '°C';
      case WeatherMetric.wind:
        return 'km/h';
      case WeatherMetric.humidity:
        return '%';
    }
  }

  double value(HourlyWeather hourly) {
    switch (this) {
      case WeatherMetric.temperature:
        return hourly.temperature;
      case WeatherMetric.wind:
        return hourly.windSpeed;
      case WeatherMetric.humidity:
        return hourly.humidity.toDouble();
    }
  }
}
