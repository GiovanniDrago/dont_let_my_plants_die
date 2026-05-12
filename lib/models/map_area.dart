import 'package:latlong2/latlong.dart';

class MapArea {
  final String id;
  final String name;
  final List<LatLng> points;
  final DateTime createdAt;

  MapArea({
    required this.id,
    required this.name,
    required this.points,
    required this.createdAt,
  });

  factory MapArea.fromJson(Map<String, dynamic> json) {
    return MapArea(
      id: json['id'] as String,
      name: json['name'] as String,
      points: (json['points'] as List<dynamic>)
          .map((e) => LatLng((e['lat'] as num).toDouble(), (e['lng'] as num).toDouble()))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LatLng get centroid {
    if (points.isEmpty) return const LatLng(0, 0);
    double latSum = 0;
    double lngSum = 0;
    for (final p in points) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }
}
