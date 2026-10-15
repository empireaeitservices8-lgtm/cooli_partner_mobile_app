/// Geographic point model with address and human-readable label
class LocationPoint {
  final double latitude;
  final double longitude;
  final String title;
  final String address;
  final String? landmark;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.address,
    this.landmark,
  });

  Map<String, dynamic> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
        'address': address,
        'landmark': landmark,
      };

  factory LocationPoint.fromMap(Map<String, dynamic> map) => LocationPoint(
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        title: map['title'] ?? '',
        address: map['address'] ?? '',
        landmark: map['landmark'],
      );
}
