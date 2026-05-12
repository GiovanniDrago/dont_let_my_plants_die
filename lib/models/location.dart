class AppLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? countryCode;
  final String? admin1;
  final String? postcode;
  final double? elevation;

  const AppLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.countryCode,
    this.admin1,
    this.postcode,
    this.elevation,
  });

  factory AppLocation.fromJson(Map<String, dynamic> json) {
    return AppLocation(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String,
      countryCode: json['country_code'] as String?,
      admin1: json['admin1'] as String?,
      postcode: json['postcodes'] != null
          ? (json['postcodes'] as List<dynamic>).firstOrNull as String?
          : json['postcode'] as String?,
      elevation: json['elevation'] != null ? (json['elevation'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'country_code': countryCode,
      'admin1': admin1,
      'postcode': postcode,
      'elevation': elevation,
    };
  }

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty) {
      return '$name, $admin1 ($country)';
    }
    return '$name, $country';
  }

  /// A detailed display string that includes distinguishing fields.
  String get detailLabel {
    final parts = <String>[];
    if (postcode != null && postcode!.isNotEmpty) {
      parts.add(postcode!);
    }
    if (countryCode != null && countryCode!.isNotEmpty) {
      parts.add(countryCode!.toUpperCase());
    }
    if (elevation != null) {
      parts.add('${elevation!.round()}m');
    }
    if (parts.isEmpty) return displayName;
    return '$displayName  •  ${parts.join(' • ')}';
  }

  /// Unique key for deduplication.
  String get uniqueKey {
    return '${name.toLowerCase().trim()}_${(countryCode ?? country).toLowerCase()}_${(admin1 ?? '').toLowerCase()}_${(postcode ?? '').toLowerCase()}';
  }

  @override
  String toString() => displayName;
}
