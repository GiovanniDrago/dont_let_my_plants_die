import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';
import '../models/weather_data.dart';
import '../services/cache_service.dart';
import '../services/open_meteo_service.dart';

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherForecast?>>((ref) {
  return WeatherNotifier();
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherForecast?>> {
  WeatherNotifier() : super(const AsyncValue.loading());

  Future<void> loadWeather(AppLocation location) async {
    state = const AsyncValue.loading();
    try {
      final forecast = await OpenMeteoService.fetchHourlyForecast(
        location.latitude,
        location.longitude,
      );
      state = AsyncValue.data(forecast);
    } catch (e, stack) {
      // Try to return stale cache if available
      final cached = await CacheService.getCachedWeather(
        location.latitude,
        location.longitude,
      );
      if (cached != null) {
        state = AsyncValue.data(cached);
      } else {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}
