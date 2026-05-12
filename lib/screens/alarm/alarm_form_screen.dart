import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/app_localizations.dart';
import '../../models/alarm.dart';
import '../../models/location.dart';
import '../../models/map_area.dart';
import '../../providers/alarm_provider.dart';
import '../../widgets/location_search_field.dart';

class AlarmFormScreen extends ConsumerStatefulWidget {
  final Alarm? alarm;
  final MapArea? area;

  const AlarmFormScreen({super.key, this.alarm, this.area});

  @override
  ConsumerState<AlarmFormScreen> createState() => _AlarmFormScreenState();
}

class _AlarmFormScreenState extends ConsumerState<AlarmFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tempController = TextEditingController();
  final _noticeController = TextEditingController(text: '2');

  AppLocation? _selectedLocation;
  String? _selectedWeatherCondition;

  final List<String> _weatherConditions = [
    'sunny',
    'partlyCloudy',
    'cloudy',
    'foggy',
    'rainy',
    'snowy',
    'stormy',
    'windy',
    'hail',
    'thunderstorm',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _titleController.text = widget.alarm!.title;
      _descController.text = widget.alarm!.description;
      _selectedLocation = widget.alarm!.location;
      _selectedWeatherCondition = widget.alarm!.weatherCondition;
      if (widget.alarm!.temperature != null) {
        _tempController.text = widget.alarm!.temperature!.toStringAsFixed(0);
      }
      _noticeController.text = widget.alarm!.noticePeriodHours.toString();
    } else if (widget.area != null) {
      // Pre-fill from area
      final centroid = widget.area!.centroid;
      _selectedLocation = AppLocation(
        name: widget.area!.name,
        latitude: centroid.latitude,
        longitude: centroid.longitude,
        country: 'Custom area',
      );
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pickLocation)),
      );
      return;
    }
    if (_selectedWeatherCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pickWeatherCondition)),
      );
      return;
    }

    final alarm = Alarm(
      id: widget.alarm?.id ?? const Uuid().v4(),
      title: _titleController.text.isNotEmpty ? _titleController.text : l10n.alarm,
      description: _descController.text,
      location: _selectedLocation!,
      weatherCondition: _selectedWeatherCondition!,
      temperature: _tempController.text.isNotEmpty
          ? double.tryParse(_tempController.text)
          : null,
      noticePeriodHours: int.tryParse(_noticeController.text) ?? 2,
      enabled: widget.alarm?.enabled ?? true,
      areaId: widget.alarm?.areaId ?? widget.area?.id,
    );

    if (widget.alarm != null) {
      await ref.read(alarmListProvider.notifier).updateAlarm(alarm);
    } else {
      await ref.read(alarmListProvider.notifier).addAlarm(alarm);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm != null ? l10n.editAlarm : l10n.newAlarm),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: l10n.title),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: InputDecoration(labelText: l10n.description),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          if (widget.area != null)
            Chip(
              avatar: const Icon(Icons.map),
              label: Text('${l10n.area}: ${widget.area!.name}'),
              onDeleted: null,
            )
          else
            LocationSearchField(
              onLocationSelected: (loc) => setState(() => _selectedLocation = loc),
            ),
          if (_selectedLocation != null && widget.area == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(
                label: Text(_selectedLocation!.displayName),
                onDeleted: () => setState(() => _selectedLocation = null),
              ),
            ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: InputDecoration(labelText: l10n.pickWeatherCondition),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedWeatherCondition,
                isDense: true,
                isExpanded: true,
                items: _weatherConditions.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(_localizedCondition(l10n, condition)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedWeatherCondition = value),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tempController,
            decoration: InputDecoration(labelText: '${l10n.temperature} (${l10n.celsius})'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noticeController,
            decoration: InputDecoration(labelText: '${l10n.noticePeriod} (${l10n.hours})'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  String _localizedCondition(AppLocalizations l10n, String condition) {
    switch (condition) {
      case 'sunny': return l10n.sunny;
      case 'partlyCloudy': return l10n.partlyCloudy;
      case 'cloudy': return l10n.cloudy;
      case 'foggy': return l10n.foggy;
      case 'rainy': return l10n.rainy;
      case 'snowy': return l10n.snowy;
      case 'stormy': return l10n.stormy;
      case 'windy': return l10n.windy;
      case 'hail': return l10n.hail;
      case 'thunderstorm': return l10n.thunderstorm;
      default: return condition;
    }
  }
}
