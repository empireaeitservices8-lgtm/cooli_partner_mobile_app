import 'location_point.dart';

enum PorterState {
  available,
  accepted,
  goingToPickup,
  arrivedAtPickup,
  goodsLoaded,
  deliveryStarted,
  arrivedAtDrop,
  goodsDelivered,
  completed,
  cancelled,
}

class PorterJob {
  final String id;
  final String goodsType; // e.g. "Electronics", "Furniture", "Hardware"
  final double weightKg; // e.g. 120.0
  final int packageCount;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final LocationPoint pickup;
  final LocationPoint dropoff;
  final double distanceKm;
  final int estimatedMinutes;
  final double totalFare;
  final double netEarnings;
  final String securityPin; // Drop verification PIN
  final PorterState state;
  final String? loadingHelpRequired; // e.g. "Helper included", "Driver assist"
  final DateTime createdAt;

  const PorterJob({
    required this.id,
    required this.goodsType,
    required this.weightKg,
    required this.packageCount,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.pickup,
    required this.dropoff,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.totalFare,
    required this.netEarnings,
    required this.securityPin,
    required this.state,
    this.loadingHelpRequired,
    required this.createdAt,
  });

  PorterJob copyWith({
    String? id,
    String? goodsType,
    double? weightKg,
    int? packageCount,
    String? senderName,
    String? senderPhone,
    String? receiverName,
    String? receiverPhone,
    LocationPoint? pickup,
    LocationPoint? dropoff,
    double? distanceKm,
    int? estimatedMinutes,
    double? totalFare,
    double? netEarnings,
    String? securityPin,
    PorterState? state,
    String? loadingHelpRequired,
    DateTime? createdAt,
  }) {
    return PorterJob(
      id: id ?? this.id,
      goodsType: goodsType ?? this.goodsType,
      weightKg: weightKg ?? this.weightKg,
      packageCount: packageCount ?? this.packageCount,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      totalFare: totalFare ?? this.totalFare,
      netEarnings: netEarnings ?? this.netEarnings,
      securityPin: securityPin ?? this.securityPin,
      state: state ?? this.state,
      loadingHelpRequired: loadingHelpRequired ?? this.loadingHelpRequired,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
