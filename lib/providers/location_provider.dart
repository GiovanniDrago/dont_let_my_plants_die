import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';
import '../services/cache_service.dart';

final selectedLocationProvider = StateNotifierProvider<SelectedLocationNotifier, AppLocation?>((ref) {
  return SelectedLocationNotifier();
});

class SelectedLocationNotifier extends StateNotifier<AppLocation?> {
  SelectedLocationNotifier() : super(null) {
    _loadMainLocation();
  }

  void _loadMainLocation() {
    final data = CacheService.getMainLocation();
    if (data != null) {
      state = AppLocation.fromJson(Map<String, dynamic>.from(data));
    }
  }

  Future<void> setLocation(AppLocation location) async {
    state = location;
    await CacheService.setMainLocation(location.toJson());
  }
}
