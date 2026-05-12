import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.theme),
            subtitle: Text(_themeLabel(context, themeMode)),
            leading: const Icon(Icons.palette_outlined),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.light),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.dark),
                  icon: const Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.system),
                  icon: const Icon(Icons.settings_suggest),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(themeProvider.notifier).setTheme(newSelection.first);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(locale.languageCode == 'it' ? l10n.italian : l10n.english),
            leading: const Icon(Icons.language),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<Locale>(
              segments: [
                ButtonSegment(
                  value: const Locale('en'),
                  label: Text(l10n.english),
                ),
                ButtonSegment(
                  value: const Locale('it'),
                  label: Text(l10n.italian),
                ),
              ],
              selected: {locale},
              onSelectionChanged: (Set<Locale> newSelection) {
                ref.read(localeProvider.notifier).setLocale(newSelection.first);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.resetAlarmAfter),
            subtitle: const Text('2 h'),
            leading: const Icon(Icons.timer_outlined),
          ),
        ],
      ),
    );
  }

  String _themeLabel(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }
}
