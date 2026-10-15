import 'location_point.dart';

enum JobType {
  ride,
  porter,
  truck,
}

enum JobStatus {
  available,
  requested,
  accepted,
  active,
  completed,
  cancelled,
  expired,
}

class Job {
  final String id;
  final JobType type;
  final JobStatus status;
  final LocationPoint pickup;
  final LocationPoint destination;
  final double distanceKm;
  final int estimatedMinutes;
  final double grossFare;
  final double netEarnings;
  final double commission;
  final String customerName;
  final String customerPhone;
  final double customerRating;
  final String vehicleRequired;
  final String? packageDetails; // For Porter / Truck
  final double? weightKg; // For Porter / Truck
  final String? instructions;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const Job({
    required this.id,
    required this.type,
    required this.status,
    required this.pickup,
    required this.destination,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.grossFare,
    required this.netEarnings,
    this.commission = 0.0,
    required this.customerName,
    required this.customerPhone,
    required this.customerRating,
    required this.vehicleRequired,
    this.packageDetails,
    this.weightKg,
    this.instructions,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  String get typeLabel {
    switch (type) {
      case JobType.ride:
        return 'RIDE';
      case JobType.porter:
        return 'PORTER';
      case JobType.truck:
        return 'TRUCK LOAD';
    }
  }

  Job copyWith({
    String? id,
    JobType? type,
    JobStatus? status,
    LocationPoint? pickup,
    LocationPoint? destination,
    double? distanceKm,
    int? estimatedMinutes,
    double? grossFare,
    double? netEarnings,
    double? commission,
    String? customerName,
    String? customerPhone,
    double? customerRating,
    String? vehicleRequired,
    String? packageDetails,
    double? weightKg,
    String? instructions,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return Job(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      grossFare: grossFare ?? this.grossFare,
      netEarnings: netEarnings ?? this.netEarnings,
      commission: commission ?? this.commission,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerRating: customerRating ?? this.customerRating,
      vehicleRequired: vehicleRequired ?? this.vehicleRequired,
      packageDetails: packageDetails ?? this.packageDetails,
      weightKg: weightKg ?? this.weightKg,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
