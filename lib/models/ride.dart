import 'location_point.dart';

enum RideState {
  requested,
  accepted,
  navigatingToPickup,
  arrivedAtPickup,
  passengerPicked,
  tripStarted,
  inProgress,
  arrivedAtDestination,
  completed,
  paymentReceived,
  rated,
  cancelled,
}

class Ride {
  final String id;
  final String partnerId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String otp; // 4-digit start trip OTP
  final LocationPoint pickup;
  final LocationPoint dropoff;
  final double distanceKm;
  final int durationMinutes;
  final double baseFare;
  final double distanceFare;
  final double commission;
  final double totalFare;
  final double netEarnings;
  final RideState state;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const Ride({
    required this.id,
    required this.partnerId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.otp,
    required this.pickup,
    required this.dropoff,
    required this.distanceKm,
    required this.durationMinutes,
    required this.baseFare,
    required this.distanceFare,
    required this.commission,
    required this.totalFare,
    required this.netEarnings,
    required this.state,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  Ride copyWith({
    String? id,
    String? partnerId,
    String? passengerName,
    String? passengerPhone,
    double? passengerRating,
    String? otp,
    LocationPoint? pickup,
    LocationPoint? dropoff,
    double? distanceKm,
    int? durationMinutes,
    double? baseFare,
    double? distanceFare,
    double? commission,
    double? totalFare,
    double? netEarnings,
    RideState? state,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerRating: passengerRating ?? this.passengerRating,
      otp: otp ?? this.otp,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      baseFare: baseFare ?? this.baseFare,
      distanceFare: distanceFare ?? this.distanceFare,
      commission: commission ?? this.commission,
      totalFare: totalFare ?? this.totalFare,
      netEarnings: netEarnings ?? this.netEarnings,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
