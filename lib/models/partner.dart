import 'job.dart';

enum PartnerStatus {
  active,
  pendingVerification,
  suspended,
  offline,
}

enum WorkPreference {
  all,
  rides,
  porter,
  truck,
}

enum PartnerRole {
  rider,
  porter,
  truckDriver,
  fleetOwner,
}

extension PartnerRoleExtension on PartnerRole {
  String get title {
    switch (this) {
      case PartnerRole.rider:
        return 'Rider';
      case PartnerRole.porter:
        return 'Porter';
      case PartnerRole.truckDriver:
        return 'Truck Driver';
      case PartnerRole.fleetOwner:
        return 'Fleet Owner';
    }
  }

  String get shortTitle {
    switch (this) {
      case PartnerRole.rider:
        return 'Rider';
      case PartnerRole.porter:
        return 'Porter';
      case PartnerRole.truckDriver:
        return 'Truck';
      case PartnerRole.fleetOwner:
        return 'Fleet';
    }
  }

  String get description {
    switch (this) {
      case PartnerRole.rider:
        return 'Passenger Cabs, Taxis, Auto & Bike Rides';
      case PartnerRole.porter:
        return 'Mini-Trucks, Intra-City Loading & Shifting';
      case PartnerRole.truckDriver:
        return 'Heavy Commercial Trucks, Interstate & Bidding';
      case PartnerRole.fleetOwner:
        return 'Multi-Vehicle Commercial Fleet & Driver Management';
    }
  }

  String get defaultVehicle {
    switch (this) {
      case PartnerRole.rider:
        return 'Maruti Dzire Tour (Cab) / Auto';
      case PartnerRole.porter:
        return 'Tata Ace Gold (Mini-Truck)';
      case PartnerRole.truckDriver:
        return 'Ashok Leyland 16T (Heavy Freight)';
      case PartnerRole.fleetOwner:
        return 'Fleet (Tata Ace, Bolero, 16T Trucks)';
    }
  }

  JobType? get associatedJobType {
    switch (this) {
      case PartnerRole.rider:
        return JobType.ride;
      case PartnerRole.porter:
        return JobType.porter;
      case PartnerRole.truckDriver:
        return JobType.truck;
      case PartnerRole.fleetOwner:
        return null; // Fleet owner can see all commercial types
    }
  }
}

class Partner {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String avatarUrl;
  final double rating;
  final int totalRatings;
  final int completedJobs;
  final bool isOnline;
  final PartnerStatus status;
  final WorkPreference workPreference;
  final PartnerRole role;
  final String? activeVehicleId;
  final String city;
  final DateTime joinedAt;

  const Partner({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.avatarUrl,
    required this.rating,
    required this.totalRatings,
    required this.completedJobs,
    required this.isOnline,
    required this.status,
    this.workPreference = WorkPreference.all,
    this.role = PartnerRole.porter,
    this.activeVehicleId,
    required this.city,
    required this.joinedAt,
  });

  Partner copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    double? rating,
    int? totalRatings,
    int? completedJobs,
    bool? isOnline,
    PartnerStatus? status,
    WorkPreference? workPreference,
    PartnerRole? role,
    String? activeVehicleId,
    String? city,
    DateTime? joinedAt,
  }) {
    return Partner(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      completedJobs: completedJobs ?? this.completedJobs,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      workPreference: workPreference ?? this.workPreference,
      role: role ?? this.role,
      activeVehicleId: activeVehicleId ?? this.activeVehicleId,
      city: city ?? this.city,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
