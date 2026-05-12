import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/alarm.dart';
import '../../providers/alarm_provider.dart';
import '../alarm/alarm_form_screen.dart';
import '../alarm/alarm_detail_screen.dart';
import '../../widgets/weather_condition_icon.dart';

class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final alarms = ref.watch(alarmListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.alarms)),
      body: alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noAlarmsYet, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return AlarmListTile(alarm: alarm);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AlarmFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AlarmListTile extends ConsumerWidget {
  final Alarm alarm;

  const AlarmListTile({super.key, required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final conditionTexts = alarm.weatherConditions.map((c) {
      final (_, text) = WeatherConditionHelper.getWeatherInfo(
        context,
        _weatherCodeFromCondition(c),
      );
      return text;
    }).join(', ');

    final extraParts = <String>[];
    if (alarm.temperature != null) {
      extraParts.add('≥${alarm.temperature!.round()}${l10n.celsius}');
    }
    if (alarm.windSpeed != null) {
      extraParts.add('≥${alarm.windSpeed!.round()}${l10n.kmH}');
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Switch(
          value: alarm.enabled,
          onChanged: (_) => ref.read(alarmListProvider.notifier).toggleEnabled(alarm.id),
        ),
        title: Text(alarm.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${alarm.location.name} • $conditionTexts'),
            if (extraParts.isNotEmpty)
              Text(extraParts.join(' • ')),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AlarmDetailScreen(alarm: alarm)),
          );
        },
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
