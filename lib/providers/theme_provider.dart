import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppTheme {
  final ThemeMode mode;
  final FlexScheme scheme;

  const AppTheme({
    this.mode = ThemeMode.system,
    this.scheme = FlexScheme.green,
  });

  AppTheme copyWith({
    ThemeMode? mode,
    FlexScheme? scheme,
  }) {
    return AppTheme(
      mode: mode ?? this.mode,
      scheme: scheme ?? this.scheme,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppTheme> {
  static const _boxName = 'settings';
  static const _modeKey = 'theme_mode';
  static const _schemeKey = 'theme_scheme';

  ThemeNotifier() : super(const AppTheme()) {
    _load();
  }

  Future<void> _load() async {
    final box = Hive.box(_boxName);
    final modeValue = box.get(_modeKey) as String?;
    final schemeValue = box.get(_schemeKey) as String?;

    ThemeMode mode;
    switch (modeValue) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    FlexScheme scheme;
    try {
      scheme = FlexScheme.values.byName(schemeValue ?? 'green');
    } catch (_) {
      scheme = FlexScheme.green;
    }

    state = AppTheme(mode: mode, scheme: scheme);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final box = Hive.box(_boxName);
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await box.put(_modeKey, value);
  }

  Future<void> setScheme(FlexScheme scheme) async {
    state = state.copyWith(scheme: scheme);
    final box = Hive.box(_boxName);
    await box.put(_schemeKey, scheme.name);
  }
}
