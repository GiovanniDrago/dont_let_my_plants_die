import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alarm.dart';
import '../services/cache_service.dart';

final alarmListProvider = StateNotifierProvider<AlarmListNotifier, List<Alarm>>((ref) {
  return AlarmListNotifier();
});

class AlarmListNotifier extends StateNotifier<List<Alarm>> {
  AlarmListNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final alarms = await CacheService.getAlarms();
    state = alarms;
  }

  Future<void> addAlarm(Alarm alarm) async {
    await CacheService.saveAlarm(alarm);
    state = [...state, alarm];
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await CacheService.saveAlarm(alarm);
    state = [
      for (final a in state)
        if (a.id == alarm.id) alarm else a
    ];
  }

  Future<void> deleteAlarm(String id) async {
    await CacheService.deleteAlarm(id);
    state = state.where((a) => a.id != id).toList();
  }

  Future<void> toggleEnabled(String id) async {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final updated = state[index].copyWith(enabled: !state[index].enabled);
    await CacheService.saveAlarm(updated);
    state = [
      for (final a in state)
        if (a.id == id) updated else a
    ];
  }
}
