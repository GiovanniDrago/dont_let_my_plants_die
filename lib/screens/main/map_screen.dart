import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/map_area.dart';
import '../../models/weather_data.dart';
import '../../providers/weather_display_provider.dart';
import '../../services/cache_service.dart';
import '../../services/open_meteo_service.dart';
import '../../widgets/horizontal_calendar.dart';
import '../../widgets/hourly_weather_list.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _points = [];
  bool _isClosed = false;
  bool _isLoadingWeather = false;
  WeatherForecast? _areaWeather;
  List<MapArea> _savedAreas = [];
  MapArea? _currentArea;

  @override
  void initState() {
    super.initState();
    _loadSavedAreas();
  }

  Future<void> _loadSavedAreas() async {
    final areas = await CacheService.getSavedAreas();
    setState(() {
      _savedAreas = areas;
    });
  }

  void _onMapTap(TapPosition _, LatLng latLng) {
    if (_isClosed) return;
    setState(() {
      _points.add(latLng);
    });
  }

  void _onFirstDotTap() {
    if (_points.length < 3) return;
    setState(() {
      _isClosed = true;
    });
    _fetchAreaWeather();
  }

  Future<void> _fetchAreaWeather() async {
    if (_points.isEmpty) return;
    final centroid = _calculateCentroid(_points);
    setState(() => _isLoadingWeather = true);
    try {
      final forecast = await OpenMeteoService.fetchHourlyForecast(
        centroid.latitude,
        centroid.longitude,
      );
      setState(() {
        _areaWeather = forecast;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() => _isLoadingWeather = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    double latSum = 0;
    double lngSum = 0;
    for (final p in points) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }

  Future<void> _saveArea() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isClosed || _points.isEmpty) return;

    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.save),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: l10n.title),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.save)),
        ],
      ),
    );

    if (confirmed == true && nameController.text.isNotEmpty) {
      final area = MapArea(
        id: const Uuid().v4(),
        name: nameController.text,
        points: List.from(_points),
        createdAt: DateTime.now(),
      );
      await CacheService.saveArea(area);
      await _loadSavedAreas();
      setState(() => _currentArea = area);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.save} OK')),
        );
      }
    }
  }

  Future<void> _deleteArea() async {
    final l10n = AppLocalizations.of(context)!;
    if (_currentArea == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAreaConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirmed == true) {
      await CacheService.deleteArea(_currentArea!.id);
      await _loadSavedAreas();
      _clearDrawing();
    }
  }

  void _clearDrawing() {
    setState(() {
      _points.clear();
      _isClosed = false;
      _areaWeather = null;
      _currentArea = null;
    });
  }

  void _loadArea(MapArea area) {
    setState(() {
      _points.clear();
      _points.addAll(area.points);
      _isClosed = true;
      _currentArea = area;
    });
    _fetchAreaWeather();
    _mapController.move(area.centroid, 6);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.map),
        actions: [
          if (_points.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: l10n.cancel,
              onPressed: _clearDrawing,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: _isClosed && _areaWeather != null ? 1 : 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(50.0, 10.0),
                initialZoom: 4.0,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.dont_let_my_plants_die',
                ),
                if (_points.isNotEmpty)
                  MarkerLayer(
                    markers: _points.asMap().entries.map((entry) {
                      final index = entry.key;
                      final point = entry.value;
                      final isFirst = index == 0;
                      return Marker(
                        point: point,
                        width: isFirst ? 40 : 24,
                        height: isFirst ? 40 : 24,
                        child: GestureDetector(
                          onTap: isFirst && _points.length > 2 && !_isClosed
                              ? _onFirstDotTap
                              : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: isFirst && !_isClosed
                                ? const Icon(Icons.close, color: Colors.white, size: 20)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                if (_points.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _isClosed ? [..._points, _points.first] : _points,
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                if (_isClosed)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: _points,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        borderColor: Theme.of(context).colorScheme.primary,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_points.isNotEmpty && !_isClosed)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                l10n.closeArea,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (_isClosed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saveArea,
                      icon: const Icon(Icons.save),
                      label: Text(l10n.save),
                    ),
                  ),
                  if (_currentArea != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _deleteArea,
                        icon: const Icon(Icons.delete),
                        label: Text(l10n.delete),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (_savedAreas.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _savedAreas.length,
                itemBuilder: (context, index) {
                  final area = _savedAreas[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      avatar: const Icon(Icons.map),
                      label: Text(area.name),
                      onPressed: () => _loadArea(area),
                    ),
                  );
                },
              ),
            ),
          if (_isLoadingWeather)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_isClosed && _areaWeather != null)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  HorizontalCalendar(days: _areaWeather!.days),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        Consumer(builder: (context, ref, _) {
                          final selectedDayIndex = ref.watch(selectedDayIndexProvider);
                          final selectedDay = _areaWeather!.days[
                              selectedDayIndex.clamp(0, _areaWeather!.days.length - 1)];
                          final now = DateTime.now();
                          final isToday = selectedDay.date.year == now.year &&
                              selectedDay.date.month == now.month &&
                              selectedDay.date.day == now.day;
                          final hourly = isToday
                              ? selectedDay.hourly
                                  .where((h) => h.time.isAfter(now.subtract(const Duration(minutes: 1))))
                                  .toList()
                              : selectedDay.hourly;
                          return HourlyWeatherList(hourly: hourly);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
