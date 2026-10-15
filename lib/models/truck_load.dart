import 'location_point.dart';

enum TruckLoadStatus {
  openForBidding,
  bidPlaced,
  counterOfferReceived,
  booked,
  inTransit,
  delivered,
  expired,
}

class TruckLoad {
  final String id;
  final String material; // e.g. "Apples / Fresh Produce", "Industrial Hardware"
  final String weightDescription; // e.g. "1 Ton", "3.5 Ton", "15 Ton"
  final double weightTons;
  final String vehicleRequired; // e.g. "Tata Ace", "14 Ft Open Body", "Container"
  final LocationPoint pickup;
  final LocationPoint destination;
  final double distanceKm;
  final String loadingType; // "Loading by Shipper", "Driver assistance needed"
  final DateTime deliveryDeadline;
  final double customerOfferedPrice;
  final double suggestedPrice;
  final double estimatedDriverEarnings;
  final TruckLoadStatus status;
  final String shipperName;
  final String shipperPhone;
  final double shipperRating;
  final String? notes;
  final DateTime createdAt;

  const TruckLoad({
    required this.id,
    required this.material,
    required this.weightDescription,
    required this.weightTons,
    required this.vehicleRequired,
    required this.pickup,
    required this.destination,
    required this.distanceKm,
    required this.loadingType,
    required this.deliveryDeadline,
    required this.customerOfferedPrice,
    required this.suggestedPrice,
    required this.estimatedDriverEarnings,
    required this.status,
    required this.shipperName,
    required this.shipperPhone,
    required this.shipperRating,
    this.notes,
    required this.createdAt,
  });

  TruckLoad copyWith({
    String? id,
    String? material,
    String? weightDescription,
    double? weightTons,
    String? vehicleRequired,
    LocationPoint? pickup,
    LocationPoint? destination,
    double? distanceKm,
    String? loadingType,
    DateTime? deliveryDeadline,
    double? customerOfferedPrice,
    double? suggestedPrice,
    double? estimatedDriverEarnings,
    TruckLoadStatus? status,
    String? shipperName,
    String? shipperPhone,
    double? shipperRating,
    String? notes,
    DateTime? createdAt,
  }) {
    return TruckLoad(
      id: id ?? this.id,
      material: material ?? this.material,
      weightDescription: weightDescription ?? this.weightDescription,
      weightTons: weightTons ?? this.weightTons,
      vehicleRequired: vehicleRequired ?? this.vehicleRequired,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      distanceKm: distanceKm ?? this.distanceKm,
      loadingType: loadingType ?? this.loadingType,
      deliveryDeadline: deliveryDeadline ?? this.deliveryDeadline,
      customerOfferedPrice: customerOfferedPrice ?? this.customerOfferedPrice,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      estimatedDriverEarnings: estimatedDriverEarnings ?? this.estimatedDriverEarnings,
      status: status ?? this.status,
      shipperName: shipperName ?? this.shipperName,
      shipperPhone: shipperPhone ?? this.shipperPhone,
      shipperRating: shipperRating ?? this.shipperRating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
