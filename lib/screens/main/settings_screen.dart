import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/update_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<FlexScheme> _schemes = [
    FlexScheme.green,
    FlexScheme.blue,
    FlexScheme.red,
    FlexScheme.amber,
    FlexScheme.deepPurple,
    FlexScheme.espresso,
    FlexScheme.sakura,
    FlexScheme.mango,
    FlexScheme.greyLaw,
    FlexScheme.deepBlue,
  ];

  String _schemeLabel(FlexScheme scheme) {
    switch (scheme) {
      case FlexScheme.green:
        return 'Green';
      case FlexScheme.blue:
        return 'Blue';
      case FlexScheme.red:
        return 'Red';
      case FlexScheme.amber:
        return 'Amber';
      case FlexScheme.deepPurple:
        return 'Deep Purple';
      case FlexScheme.espresso:
        return 'Espresso';
      case FlexScheme.sakura:
        return 'Sakura';
      case FlexScheme.mango:
        return 'Mango';
      case FlexScheme.greyLaw:
        return 'Grey';
      case FlexScheme.deepBlue:
        return 'Deep Blue';
      default:
        return scheme.name;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.theme),
            leading: const Icon(Icons.palette_outlined),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.theme,
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<FlexScheme>(
                  value: theme.scheme,
                  isDense: true,
                  isExpanded: true,
                  items: _schemes.map((scheme) {
                    return DropdownMenuItem(
                      value: scheme,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: FlexThemeData.light(scheme: scheme).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(_schemeLabel(scheme)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeProvider.notifier).setScheme(value);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
              selected: {theme.mode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(themeProvider.notifier).setMode(newSelection.first);
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(l10n.checkForUpdates),
            onTap: () => UpdateService.check(context, silent: false),
          ),
          const Divider(),
          FutureBuilder<String>(
            future: UpdateService.currentVersion,
            builder: (context, snapshot) {
              final version = snapshot.data ?? '';
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.version),
                subtitle: version.isNotEmpty ? Text('v$version') : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
