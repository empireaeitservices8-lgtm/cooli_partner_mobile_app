library;

/// Vehicle API Model matching CoolieDriver Backend

class VehicleApiModel {
  final dynamic id;
  final String vehicleNumber;
  final String vehicleType;
  final String brand;
  final String model;
  final String capacity;
  final String fuelType;
  final String? rcDocument;
  final String? insuranceDocument;
  final String? fitnessCertificate;
  final String? permitDocument;
  final String? pollutionCertificate;
  final String status;

  VehicleApiModel({
    this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.capacity,
    required this.fuelType,
    this.rcDocument,
    this.insuranceDocument,
    this.fitnessCertificate,
    this.permitDocument,
    this.pollutionCertificate,
    this.status = 'available',
  });

  factory VehicleApiModel.fromJson(Map<String, dynamic> json) {
    return VehicleApiModel(
      id: json['id'],
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      vehicleType: json['vehicle_type']?.toString() ?? 'bike',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      fuelType: json['fuel_type']?.toString() ?? 'Petrol',
      rcDocument: json['rc_document']?.toString(),
      insuranceDocument: json['insurance_document']?.toString(),
      fitnessCertificate: json['fitness_certificate']?.toString(),
      permitDocument: json['permit_document']?.toString(),
      pollutionCertificate: json['pollution_certificate']?.toString(),
      status: json['status']?.toString() ?? 'available',
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'vehicle_number': vehicleNumber,
        'vehicle_type': vehicleType,
        'brand': brand,
        'model': model,
        'capacity': capacity,
        'fuel_type': fuelType,
        'rc_document': rcDocument ?? '',
        'insurance_document': insuranceDocument ?? '',
        'fitness_certificate': fitnessCertificate ?? '',
        'permit_document': permitDocument ?? '',
        'pollution_certificate': pollutionCertificate ?? '',
        'status': status,
      };
}

class RideVehicleType {
  final int id;
  final int service;
  final String name;
  final String description;
  final String icon;
  final bool isActive;

  const RideVehicleType({
    required this.id,
    required this.service,
    required this.name,
    required this.description,
    required this.icon,
    this.isActive = true,
  });

  factory RideVehicleType.fromJson(Map<String, dynamic> json) {
    return RideVehicleType(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      service: json['service'] is int
          ? json['service']
          : int.tryParse(json['service']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      isActive: json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'service': service,
        'name': name,
        'description': description,
        'icon': icon,
        'is_active': isActive,
      };

  /// Fallback dummy data provided by CoolieDriver API:
  /// Endpoint: GET /api/ride/vehicle-types/
  static const List<RideVehicleType> dummyVehicleTypes = [
    RideVehicleType(
      id: 10,
      service: 8,
      name: 'Bike',
      description: 'Two-wheeler ride',
      icon: 'bike',
      isActive: true,
    ),
    RideVehicleType(
      id: 11,
      service: 8,
      name: 'Auto',
      description: 'Three-wheeler auto rickshaw',
      icon: 'auto',
      isActive: true,
    ),
    RideVehicleType(
      id: 12,
      service: 8,
      name: 'Car',
      description: 'Standard car ride',
      icon: 'car',
      isActive: true,
    ),
    RideVehicleType(
      id: 13,
      service: 8,
      name: 'Premium car',
      description: 'Premium car ride',
      icon: 'premium_car',
      isActive: true,
    ),
    RideVehicleType(
      id: 24,
      service: 8,
      name: 'BMW',
      description: 'VIP RIDE',
      icon: '',
      isActive: true,
    ),
  ];
}

