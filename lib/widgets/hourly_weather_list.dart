import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/weather_data.dart';
import '../providers/weather_display_provider.dart';
import '../l10n/app_localizations.dart';
import 'weather_condition_icon.dart';

class HourlyWeatherList extends ConsumerWidget {
  final List<HourlyWeather> hourly;

  const HourlyWeatherList({super.key, required this.hourly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metric = ref.watch(weatherMetricProvider);
    final l10n = AppLocalizations.of(context)!;

    if (hourly.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hourly.length,
      itemBuilder: (context, index) {
        final h = hourly[index];
        final (icon, conditionText) = WeatherConditionHelper.getWeatherInfo(context, h.weatherCode);
        final isNow = _isNow(h.time);

        return Container(
          decoration: BoxDecoration(
            color: isNow
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    isNow ? l10n.now : DateFormat.Hm(l10n.localeName).format(h.time),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ),
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conditionText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${metric.value(h).round()}${metric.unit(context)}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isNow(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day &&
        time.hour == now.hour;
  }
}
