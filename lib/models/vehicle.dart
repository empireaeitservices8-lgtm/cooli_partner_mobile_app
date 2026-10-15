enum VehicleType {
  bike,
  auto,
  miniTruck, // Tata Ace
  pickupTruck, // Bolero Pickup
  heavyTruck, // 10 Wheeler / 16 Ton
  container,
}

enum VehicleVerificationState {
  verified,
  pending,
  rejected,
  expired,
}

class Vehicle {
  final String id;
  final String partnerId;
  final VehicleType type;
  final String makeModel; // e.g. "Tata Ace Gold", "Mahindra Bolero Maxi Truck"
  final String registrationNumber; // e.g. "KL 07 AB 1234"
  final String capacity; // e.g. "1.5 Ton", "750 kg"
  final String fuelType; // "Diesel", "EV", "CNG"
  final VehicleVerificationState verificationState;
  final bool isActive;
  final String rcNumber;
  final DateTime insuranceExpiry;
  final DateTime fitnessExpiry;
  final String? imageUrl;

  const Vehicle({
    required this.id,
    required this.partnerId,
    required this.type,
    required this.makeModel,
    required this.registrationNumber,
    required this.capacity,
    required this.fuelType,
    required this.verificationState,
    this.isActive = false,
    required this.rcNumber,
    required this.insuranceExpiry,
    required this.fitnessExpiry,
    this.imageUrl,
  });

  String get typeDisplayName {
    switch (type) {
      case VehicleType.bike:
        return 'Bike / Scooter';
      case VehicleType.auto:
        return '3-Wheeler Cargo Auto';
      case VehicleType.miniTruck:
        return 'Mini Truck (Tata Ace)';
      case VehicleType.pickupTruck:
        return 'Pickup (Mahindra Bolero)';
      case VehicleType.heavyTruck:
        return 'Heavy Commercial Truck';
      case VehicleType.container:
        return 'Closed Container Truck';
    }
  }

  Vehicle copyWith({
    String? id,
    String? partnerId,
    VehicleType? type,
    String? makeModel,
    String? registrationNumber,
    String? capacity,
    String? fuelType,
    VehicleVerificationState? verificationState,
    bool? isActive,
    String? rcNumber,
    DateTime? insuranceExpiry,
    DateTime? fitnessExpiry,
    String? imageUrl,
  }) {
    return Vehicle(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      type: type ?? this.type,
      makeModel: makeModel ?? this.makeModel,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      capacity: capacity ?? this.capacity,
      fuelType: fuelType ?? this.fuelType,
      verificationState: verificationState ?? this.verificationState,
      isActive: isActive ?? this.isActive,
      rcNumber: rcNumber ?? this.rcNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      fitnessExpiry: fitnessExpiry ?? this.fitnessExpiry,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
