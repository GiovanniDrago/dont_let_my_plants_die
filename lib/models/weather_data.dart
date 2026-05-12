class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int humidity;
  final int weatherCode;
  final double windSpeed;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json, int index) {
    return HourlyWeather(
      time: DateTime.parse(json['time'][index] as String),
      temperature: (json['temperature_2m'][index] as num).toDouble(),
      humidity: (json['relative_humidity_2m'][index] as num).toInt(),
      weatherCode: (json['weather_code'][index] as num).toInt(),
      windSpeed: (json['wind_speed_10m'][index] as num).toDouble(),
    );
  }
}

class DailyWeather {
  final DateTime date;
  final List<HourlyWeather> hourly;
  final double avgTemperature;

  DailyWeather({
    required this.date,
    required this.hourly,
    required this.avgTemperature,
  });

  factory DailyWeather.fromHourlyList(DateTime date, List<HourlyWeather> hourly) {
    final dayHourly = hourly.where((h) => _isSameDay(h.time, date)).toList();
    final avgTemp = dayHourly.isNotEmpty
        ? dayHourly.map((h) => h.temperature).reduce((a, b) => a + b) / dayHourly.length
        : 0.0;
    return DailyWeather(
      date: date,
      hourly: dayHourly,
      avgTemperature: avgTemp,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class WeatherForecast {
  final double latitude;
  final double longitude;
  final List<DailyWeather> days;
  final DateTime fetchedAt;

  WeatherForecast({
    required this.latitude,
    required this.longitude,
    required this.days,
    required this.fetchedAt,
  });

  factory WeatherForecast.fromResponse(Map<String, dynamic> response) {
    final hourly = response['hourly'] as Map<String, dynamic>;
    final times = hourly['time'] as List<dynamic>;
    final List<HourlyWeather> allHourly = [];
    for (int i = 0; i < times.length; i++) {
      allHourly.add(HourlyWeather.fromJson(hourly, i));
    }

    // Group by day
    final dayMap = <DateTime, List<HourlyWeather>>{};
    for (final h in allHourly) {
      final day = DateTime(h.time.year, h.time.month, h.time.day);
      dayMap.putIfAbsent(day, () => []).add(h);
    }

    final days = dayMap.entries.map((e) => DailyWeather.fromHourlyList(e.key, e.value)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return WeatherForecast(
      latitude: (response['latitude'] as num).toDouble(),
      longitude: (response['longitude'] as num).toDouble(),
      days: days,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'fetchedAt': fetchedAt.toIso8601String(),
      'hourly': {
        'time': days.expand((d) => d.hourly.map((h) => h.time.toIso8601String())).toList(),
        'temperature_2m': days.expand((d) => d.hourly.map((h) => h.temperature)).toList(),
        'relative_humidity_2m': days.expand((d) => d.hourly.map((h) => h.humidity)).toList(),
        'weather_code': days.expand((d) => d.hourly.map((h) => h.weatherCode)).toList(),
        'wind_speed_10m': days.expand((d) => d.hourly.map((h) => h.windSpeed)).toList(),
      },
    };
  }
}
