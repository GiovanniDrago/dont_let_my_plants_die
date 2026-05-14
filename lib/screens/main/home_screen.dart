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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = ref.read(selectedLocationProvider);
      if (location != null) {
        ref.read(weatherProvider.notifier).loadWeather(location);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  String _buildTitle(AppLocation? location, double? elevation) {
    final base = location?.name ?? AppLocalizations.of(context)!.location;
    if (elevation != null && elevation != 0.0) {
      return '$base (${elevation.round()}m)';
    }
    if (location?.elevation != null && location!.elevation != 0.0) {
      return '$base (${location.elevation!.round()}m)';
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = ref.watch(selectedLocationProvider);
    final weatherAsync = ref.watch(weatherProvider);

    ref.listen<int>(selectedDayIndexProvider, (previous, next) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showLocationPicker,
          child: weatherAsync.when(
            data: (forecast) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 20),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _buildTitle(location, forecast?.elevation),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              );
            },
            loading: () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _buildTitle(location, null),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
            error: (_, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _buildTitle(location, null),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
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

          return Column(
            children: [
              HorizontalCalendar(days: forecast.days),
              const Divider(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: forecast.days.length,
                  onPageChanged: (index) {
                    ref.read(selectedDayIndexProvider.notifier).state = index;
                  },
                  itemBuilder: (context, dayIndex) {
                    final selectedDay = forecast.days[dayIndex];
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  isToday ? l10n.today : '${selectedDay.date.day}/${selectedDay.date.month}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Spacer(),
                                if (selectedDay.minTemperature != null && selectedDay.maxTemperature != null)
                                  Text(
                                    '${l10n.tempMin}: ${selectedDay.minTemperature!.round()}${l10n.celsius}  ${l10n.tempMax}: ${selectedDay.maxTemperature!.round()}${l10n.celsius}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          HourlyWeatherList(
                            hourly: hourly,
                            daily: selectedDay,
                            elevation: forecast.elevation,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
