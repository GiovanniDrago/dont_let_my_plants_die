import '../models/location.dart';

class Alarm {
  final String id;
  final String title;
  final String description;
  final AppLocation location;
  final List<String> weatherConditions; // e.g., ['sunny', 'cloudy']
  final double? temperature;
  final double? windSpeed;
  final int noticePeriodHours;
  final bool enabled;
  final DateTime? lastTriggeredAt;
  final DateTime? lastResetAt;
  final String? areaId;

  Alarm({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.weatherConditions,
    this.temperature,
    this.windSpeed,
    required this.noticePeriodHours,
    this.enabled = true,
    this.lastTriggeredAt,
    this.lastResetAt,
    this.areaId,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    // Backward compatibility: old alarms stored weatherCondition as String
    List<String> conditions;
    final raw = json['weatherConditions'] ?? json['weatherCondition'];
    if (raw is String) {
      conditions = [raw];
    } else if (raw is List) {
      conditions = raw.cast<String>();
    } else {
      conditions = [];
    }

    return Alarm(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: AppLocation.fromJson(Map<String, dynamic>.from(json['location'])),
      weatherConditions: conditions,
      temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
      windSpeed: json['windSpeed'] != null ? (json['windSpeed'] as num).toDouble() : null,
      noticePeriodHours: json['noticePeriodHours'] as int,
      enabled: json['enabled'] as bool? ?? true,
      lastTriggeredAt: json['lastTriggeredAt'] != null
          ? DateTime.parse(json['lastTriggeredAt'] as String)
          : null,
      lastResetAt: json['lastResetAt'] != null
          ? DateTime.parse(json['lastResetAt'] as String)
          : null,
      areaId: json['areaId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location.toJson(),
      'weatherConditions': weatherConditions,
      'temperature': temperature,
      'windSpeed': windSpeed,
      'noticePeriodHours': noticePeriodHours,
      'enabled': enabled,
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
      'lastResetAt': lastResetAt?.toIso8601String(),
      'areaId': areaId,
    };
  }

  Alarm copyWith({
    String? id,
    String? title,
    String? description,
    AppLocation? location,
    List<String>? weatherConditions,
    double? temperature,
    bool? clearTemperature,
    double? windSpeed,
    bool? clearWindSpeed,
    int? noticePeriodHours,
    bool? enabled,
    DateTime? lastTriggeredAt,
    bool? clearLastTriggeredAt,
    DateTime? lastResetAt,
    bool? clearLastResetAt,
    String? areaId,
    bool? clearAreaId,
  }) {
    return Alarm(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      temperature: clearTemperature == true ? null : (temperature ?? this.temperature),
      windSpeed: clearWindSpeed == true ? null : (windSpeed ?? this.windSpeed),
      noticePeriodHours: noticePeriodHours ?? this.noticePeriodHours,
      enabled: enabled ?? this.enabled,
      lastTriggeredAt: clearLastTriggeredAt == true
          ? null
          : (lastTriggeredAt ?? this.lastTriggeredAt),
      lastResetAt: clearLastResetAt == true ? null : (lastResetAt ?? this.lastResetAt),
      areaId: clearAreaId == true ? null : (areaId ?? this.areaId),
    );
  }
}
