class AppLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;

  const AppLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  factory AppLocation.fromJson(Map<String, dynamic> json) {
    return AppLocation(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String,
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
    };
  }

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty) {
      return '$name, $admin1 ($country)';
    }
    return '$name, $country';
  }

  @override
  String toString() => displayName;
}
