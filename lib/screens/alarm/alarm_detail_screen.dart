import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/alarm.dart';
import '../../providers/alarm_provider.dart';
import '../../widgets/weather_condition_icon.dart';
import 'alarm_form_screen.dart';

class AlarmDetailScreen extends ConsumerWidget {
  final Alarm alarm;

  const AlarmDetailScreen({super.key, required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final (_, conditionText) = WeatherConditionHelper.getWeatherInfo(
      context,
      _weatherCodeFromCondition(alarm.weatherCondition),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alarmDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AlarmFormScreen(alarm: alarm)),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            alarm.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(alarm.description, style: Theme.of(context).textTheme.bodyLarge),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(l10n.location),
            subtitle: Text(alarm.location.displayName),
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: Text(l10n.weatherCondition),
            subtitle: Text(conditionText),
          ),
          if (alarm.temperature != null)
            ListTile(
              leading: const Icon(Icons.thermostat),
              title: Text(l10n.temperature),
              subtitle: Text('${alarm.temperature!.round()}${l10n.celsius}'),
            ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: Text(l10n.noticePeriod),
            subtitle: Text('${alarm.noticePeriodHours} ${l10n.hours} ${l10n.beforeTheEvent}'),
          ),
          ListTile(
            leading: Icon(alarm.enabled ? Icons.notifications_active : Icons.notifications_off),
            title: Text(l10n.alarm),
            subtitle: Text(alarm.enabled ? l10n.enable : l10n.disable),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteAlarmConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.delete),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(alarmListProvider.notifier).deleteAlarm(alarm.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete),
            label: Text(l10n.delete),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          ),
        ],
      ),
    );
  }

  int _weatherCodeFromCondition(String condition) {
    switch (condition) {
      case 'sunny': return 0;
      case 'partlyCloudy': return 2;
      case 'cloudy': return 3;
      case 'foggy': return 45;
      case 'rainy': return 61;
      case 'snowy': return 71;
      case 'stormy': return 95;
      case 'windy': return 0;
      case 'hail': return 96;
      case 'thunderstorm': return 95;
      default: return 0;
    }
  }
}
