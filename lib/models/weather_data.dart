class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final double windGusts;
  final double precipitation;
  final int precipitationProbability;
  final int cloudCover;
  final double uvIndex;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.windGusts,
    required this.precipitation,
    required this.precipitationProbability,
    required this.cloudCover,
    required this.uvIndex,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json, int index) {
    return HourlyWeather(
      time: DateTime.parse(json['time'][index] as String),
      temperature: (json['temperature_2m'][index] as num).toDouble(),
      humidity: (json['relative_humidity_2m'][index] as num).toInt(),
      weatherCode: (json['weather_code'][index] as num).toInt(),
      windSpeed: (json['wind_speed_10m'][index] as num).toDouble(),
      windGusts: (json['wind_gusts_10m'] != null)
          ? (json['wind_gusts_10m'][index] as num).toDouble()
          : 0.0,
      precipitation: (json['precipitation'] != null)
          ? (json['precipitation'][index] as num).toDouble()
          : 0.0,
      precipitationProbability: (json['precipitation_probability'] != null)
          ? (json['precipitation_probability'][index] as num).toInt()
          : 0,
      cloudCover: (json['cloudcover'] != null)
          ? (json['cloudcover'][index] as num).toInt()
          : 0,
      uvIndex: (json['uv_index'] != null)
          ? (json['uv_index'][index] as num).toDouble()
          : 0.0,
    );
  }
}

class DailyWeather {
  final DateTime date;
  final List<HourlyWeather> hourly;
  final double avgTemperature;
  final double? minTemperature;
  final double? maxTemperature;

  DailyWeather({
    required this.date,
    required this.hourly,
    required this.avgTemperature,
    this.minTemperature,
    this.maxTemperature,
  });

  factory DailyWeather.fromHourlyList(
    DateTime date,
    List<HourlyWeather> hourly, {
    double? minTemp,
    double? maxTemp,
  }) {
    final dayHourly = hourly.where((h) => _isSameDay(h.time, date)).toList();
    final avgTemp = dayHourly.isNotEmpty
        ? dayHourly.map((h) => h.temperature).reduce((a, b) => a + b) / dayHourly.length
        : 0.0;
    return DailyWeather(
      date: date,
      hourly: dayHourly,
      avgTemperature: avgTemp,
      minTemperature: minTemp,
      maxTemperature: maxTemp,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class WeatherForecast {
  final double latitude;
  final double longitude;
  final double elevation;
  final List<DailyWeather> days;
  final DateTime fetchedAt;

  WeatherForecast({
    required this.latitude,
    required this.longitude,
    required this.elevation,
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

    // Parse daily min/max if available
    final dailyData = response['daily'] as Map<String, dynamic>?;
    final dailyMin = <DateTime, double>{};
    final dailyMax = <DateTime, double>{};
    if (dailyData != null) {
      final dailyTimes = dailyData['time'] as List<dynamic>?;
      final minTemps = dailyData['temperature_2m_min'] as List<dynamic>?;
      final maxTemps = dailyData['temperature_2m_max'] as List<dynamic>?;
      if (dailyTimes != null && minTemps != null && maxTemps != null) {
        for (int i = 0; i < dailyTimes.length; i++) {
          final day = DateTime.parse(dailyTimes[i] as String);
          dailyMin[DateTime(day.year, day.month, day.day)] =
              (minTemps[i] as num).toDouble();
          dailyMax[DateTime(day.year, day.month, day.day)] =
              (maxTemps[i] as num).toDouble();
        }
      }
    }

    // Group by day
    final dayMap = <DateTime, List<HourlyWeather>>{};
    for (final h in allHourly) {
      final day = DateTime(h.time.year, h.time.month, h.time.day);
      dayMap.putIfAbsent(day, () => []).add(h);
    }

    final days = dayMap.entries.map((e) {
      final day = e.key;
      return DailyWeather.fromHourlyList(
        day,
        e.value,
        minTemp: dailyMin[day],
        maxTemp: dailyMax[day],
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return WeatherForecast(
      latitude: (response['latitude'] as num).toDouble(),
      longitude: (response['longitude'] as num).toDouble(),
      elevation: (response['elevation'] as num?)?.toDouble() ?? 0.0,
      days: days,
      fetchedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_cacheVersion': 2,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'fetchedAt': fetchedAt.toIso8601String(),
      'hourly': {
        'time': days.expand((d) => d.hourly.map((h) => h.time.toIso8601String())).toList(),
        'temperature_2m': days.expand((d) => d.hourly.map((h) => h.temperature)).toList(),
        'relative_humidity_2m': days.expand((d) => d.hourly.map((h) => h.humidity)).toList(),
        'weather_code': days.expand((d) => d.hourly.map((h) => h.weatherCode)).toList(),
        'wind_speed_10m': days.expand((d) => d.hourly.map((h) => h.windSpeed)).toList(),
        'wind_gusts_10m': days.expand((d) => d.hourly.map((h) => h.windGusts)).toList(),
        'precipitation': days.expand((d) => d.hourly.map((h) => h.precipitation)).toList(),
        'precipitation_probability': days.expand((d) => d.hourly.map((h) => h.precipitationProbability)).toList(),
        'cloudcover': days.expand((d) => d.hourly.map((h) => h.cloudCover)).toList(),
        'uv_index': days.expand((d) => d.hourly.map((h) => h.uvIndex)).toList(),
      },
      'daily': {
        'time': days.map((d) => DateTime(d.date.year, d.date.month, d.date.day).toIso8601String()).toList(),
        'temperature_2m_min': days.map((d) => d.minTemperature ?? 0.0).toList(),
        'temperature_2m_max': days.map((d) => d.maxTemperature ?? 0.0).toList(),
      },
    };
  }
}
