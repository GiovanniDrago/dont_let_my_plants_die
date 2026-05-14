import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/weather_data.dart';
import '../providers/weather_display_provider.dart';
import '../l10n/app_localizations.dart';
import 'weather_condition_icon.dart';

class HourlyWeatherList extends ConsumerStatefulWidget {
  final List<HourlyWeather> hourly;
  final DailyWeather? daily;
  final double? elevation;

  const HourlyWeatherList({
    super.key,
    required this.hourly,
    this.daily,
    this.elevation,
  });

  @override
  ConsumerState<HourlyWeatherList> createState() => _HourlyWeatherListState();
}

class _HourlyWeatherListState extends ConsumerState<HourlyWeatherList> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final metric = ref.watch(weatherMetricProvider);
    final l10n = AppLocalizations.of(context)!;

    if (widget.hourly.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.hourly.length,
      itemBuilder: (context, index) {
        final h = widget.hourly[index];
        final (icon, conditionText) = WeatherConditionHelper.getWeatherInfo(context, h.weatherCode);
        final isNow = _isNow(h.time);
        final isExpanded = _expandedIndex == index;

        return InkWell(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
            child: Column(
              children: [
                Padding(
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
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildDetails(context, h, conditionText, l10n),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetails(
    BuildContext context,
    HourlyWeather h,
    String conditionText,
    AppLocalizations l10n,
  ) {
    final day = widget.daily;
    final elev = widget.elevation;

    // Heuristic: if precipitation > 0 but probability is 0, show >0%
    final probValue = (h.precipitation > 0 && h.precipitationProbability == 0)
        ? '>0${l10n.percent}'
        : '${h.precipitationProbability}${l10n.percent}';

    final details = <Widget>[
      _detailChip(context, '${l10n.weatherCondition}: $conditionText'),
      _detailChip(context, '${l10n.temperature}: ${h.temperature.round()}${l10n.celsius}'),
      if (day?.minTemperature != null && day?.maxTemperature != null)
        _detailChip(
          context,
          '${l10n.tempMin}/${l10n.tempMax}: ${day!.minTemperature!.round()}${l10n.celsius} / ${day.maxTemperature!.round()}${l10n.celsius}',
        ),
      _detailChip(context, '${l10n.windSpeed}: ${h.windSpeed.round()} ${l10n.kmH}'),
      _detailChip(context, '${l10n.windGusts}: ${h.windGusts.round()} ${l10n.kmH}'),
      _detailChip(context, '${l10n.humidity}: ${h.humidity}${l10n.percent}'),
      _detailChip(context, '${l10n.precipitation}: ${h.precipitation.toStringAsFixed(1)} mm'),
      _precipProbabilityChip(context, l10n, probValue),
      _detailChip(context, '${l10n.cloudCover}: ${h.cloudCover}${l10n.percent}'),
      _detailChip(context, '${l10n.uvIndex}: ${h.uvIndex.toStringAsFixed(1)}'),
      if (elev != null && elev != 0.0)
        _detailChip(context, '${l10n.elevation}: ${elev.round()} m'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: details,
      ),
    );
  }

  Widget _detailChip(BuildContext context, String text) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      label: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _precipProbabilityChip(
    BuildContext context,
    AppLocalizations l10n,
    String probValue,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
          label: Text(
            '${l10n.precipitationProbability}: $probValue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        InkWell(
          onTap: () => _showRainProbabilityInfo(context, l10n),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showRainProbabilityInfo(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rainProbabilityInfoTitle),
        content: Text(l10n.rainProbabilityInfoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
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
