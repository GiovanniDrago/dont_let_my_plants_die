import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/location.dart';

class OpenMeteoService {
  static const String _geocodingBase = 'https://geocoding-api.open-meteo.com/v1';
  static const String _forecastBase = 'https://api.open-meteo.com/v1';

  static Future<List<AppLocation>> searchLocation(String query, String lang) async {
    if (query.trim().length < 2) return [];

    final uri = Uri.parse(
      '$_geocodingBase/search?name=${Uri.encodeComponent(query.trim())}&count=5&language=$lang&format=json',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Geocoding error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      return [];
    }

    return results
        .map((e) => AppLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> fetchHourlyForecast(
    double latitude,
    double longitude, {
    int days = 5,
  }) async {
    final uri = Uri.parse(
      '$_forecastBase/forecast?latitude=$latitude&longitude=$longitude'
      '&hourly=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      '&forecast_days=$days&timezone=auto',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Forecast error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
