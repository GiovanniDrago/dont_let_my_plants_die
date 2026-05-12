import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/location.dart';
import '../../providers/location_provider.dart';
import '../../providers/weather_display_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/hourly_weather_list.dart';
import '../../widgets/horizontal_calendar.dart';
import '../../widgets/location_search_field.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = ref.read(selectedLocationProvider);
      if (location != null) {
        ref.read(weatherProvider.notifier).loadWeather(location);
      }
    });
  }

  Future<void> _showLocationPicker() async {
    final l10n = AppLocalizations.of(context)!;
    AppLocation? selected;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.pickLocation, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              LocationSearchField(
                onLocationSelected: (loc) {
                  selected = loc;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(selectedLocationProvider.notifier).setLocation(selected!);
      await ref.read(weatherProvider.notifier).loadWeather(selected!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = ref.watch(selectedLocationProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showLocationPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  location?.name ?? l10n.location,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<WeatherMetric>(
            icon: const Icon(Icons.swap_vert),
            tooltip: l10n.temperature,
            onSelected: (value) {
              ref.read(weatherMetricProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: WeatherMetric.temperature, child: Text(l10n.temperature)),
              PopupMenuItem(value: WeatherMetric.wind, child: Text(l10n.wind)),
              PopupMenuItem(value: WeatherMetric.humidity, child: Text(l10n.humidity)),
            ],
          ),
        ],
      ),
      body: weatherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${l10n.error}: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (location != null) {
                    ref.read(weatherProvider.notifier).loadWeather(location);
                  }
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (forecast) {
          if (forecast == null || forecast.days.isEmpty) {
            return const Center(child: Text('No data'));
          }

          final selectedDayIndex = ref.watch(selectedDayIndexProvider);
          final selectedDay = forecast.days[selectedDayIndex.clamp(0, forecast.days.length - 1)];

          // Filter hours: for today, from now onward; for future days, all hours
          final now = DateTime.now();
          final isToday = selectedDay.date.year == now.year &&
              selectedDay.date.month == now.month &&
              selectedDay.date.day == now.day;

          final hourly = isToday
              ? selectedDay.hourly.where((h) => h.time.isAfter(now.subtract(const Duration(minutes: 1)))).toList()
              : selectedDay.hourly;

          return RefreshIndicator(
            onRefresh: () async {
              if (location != null) {
                await ref.read(weatherProvider.notifier).loadWeather(location);
              }
            },
            child: ListView(
              children: [
                HorizontalCalendar(days: forecast.days),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    isToday ? l10n.today : '${selectedDay.date.day}/${selectedDay.date.month}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                HourlyWeatherList(hourly: hourly),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
