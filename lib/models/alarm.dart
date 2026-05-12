import '../models/location.dart';

class Alarm {
  final String id;
  final String title;
  final String description;
  final AppLocation location;
  final String weatherCondition; // e.g., 'sunny', 'rainy', 'cloudy', etc.
  final double? temperature; // nullable
  final int noticePeriodHours;
  final bool enabled;
  final DateTime? lastTriggeredAt;
  final DateTime? lastResetAt;

  Alarm({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.weatherCondition,
    this.temperature,
    required this.noticePeriodHours,
    this.enabled = true,
    this.lastTriggeredAt,
    this.lastResetAt,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: AppLocation.fromJson(Map<String, dynamic>.from(json['location'])),
      weatherCondition: json['weatherCondition'] as String,
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      noticePeriodHours: json['noticePeriodHours'] as int,
      enabled: json['enabled'] as bool? ?? true,
      lastTriggeredAt: json['lastTriggeredAt'] != null
          ? DateTime.parse(json['lastTriggeredAt'] as String)
          : null,
      lastResetAt: json['lastResetAt'] != null
          ? DateTime.parse(json['lastResetAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location.toJson(),
      'weatherCondition': weatherCondition,
      'temperature': temperature,
      'noticePeriodHours': noticePeriodHours,
      'enabled': enabled,
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
      'lastResetAt': lastResetAt?.toIso8601String(),
    };
  }

  Alarm copyWith({
    String? id,
    String? title,
    String? description,
    AppLocation? location,
    String? weatherCondition,
    double? temperature,
    bool? clearTemperature,
    int? noticePeriodHours,
    bool? enabled,
    DateTime? lastTriggeredAt,
    bool? clearLastTriggeredAt,
    DateTime? lastResetAt,
    bool? clearLastResetAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: clearTemperature == true ? null : (temperature ?? this.temperature),
      noticePeriodHours: noticePeriodHours ?? this.noticePeriodHours,
      enabled: enabled ?? this.enabled,
      lastTriggeredAt: clearLastTriggeredAt == true
          ? null
          : (lastTriggeredAt ?? this.lastTriggeredAt),
      lastResetAt: clearLastResetAt == true ? null : (lastResetAt ?? this.lastResetAt),
    );
  }
}
