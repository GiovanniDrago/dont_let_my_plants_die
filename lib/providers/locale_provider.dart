import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const _boxName = 'settings';
  static const _key = 'locale';

  LocaleNotifier() : super(const Locale('it')) {
    _load();
  }

  Future<void> _load() async {
    final box = Hive.box(_boxName);
    final value = box.get(_key) as String?;
    if (value != null) {
      state = Locale(value);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final box = Hive.box(_boxName);
    await box.put(_key, locale.languageCode);
  }
}
