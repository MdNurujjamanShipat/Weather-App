
class Location {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;

  Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      country: json['country'] ?? '',
      admin1: json['admin1'],
    );
  }

  String get displayName {
    if (admin1 != null) {
      return '$name, $admin1, $country';
    }
    return '$name, $country';
  }
}