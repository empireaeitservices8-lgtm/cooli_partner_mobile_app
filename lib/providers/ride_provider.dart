import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'app_providers.dart';

class RideStateWrapper {
  final Ride? ride;
  final bool isLoading;
  final String? error;
  final bool otpVerified;

  const RideStateWrapper({
    this.ride,
    this.isLoading = false,
    this.error,
    this.otpVerified = false,
  });

  RideStateWrapper copyWith({
    Ride? ride,
    bool? isLoading,
    String? error,
    bool? otpVerified,
  }) {
    return RideStateWrapper(
      ride: ride ?? this.ride,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }
}

class RideNotifier extends StateNotifier<RideStateWrapper> {
  final Ref ref;

  RideNotifier(this.ref) : super(RideStateWrapper(ride: MockData.activeRide));

  Future<void> advanceToNextState() async {
    final current = state.ride;
    if (current == null) return;

    RideState next;
    switch (current.state) {
      case RideState.requested:
        next = RideState.accepted;
        break;
      case RideState.accepted:
        next = RideState.navigatingToPickup;
        break;
      case RideState.navigatingToPickup:
        next = RideState.arrivedAtPickup;
        break;
      case RideState.arrivedAtPickup:
        next = RideState.passengerPicked;
        break;
      case RideState.passengerPicked:
        next = RideState.tripStarted;
        break;
      case RideState.tripStarted:
        next = RideState.inProgress;
        break;
      case RideState.inProgress:
        next = RideState.arrivedAtDestination;
        break;
      case RideState.arrivedAtDestination:
        next = RideState.completed;
        break;
      case RideState.completed:
        next = RideState.paymentReceived;
        break;
      case RideState.paymentReceived:
        next = RideState.rated;
        break;
      case RideState.rated:
      case RideState.cancelled:
        return;
    }

    state = state.copyWith(isLoading: true);
    final updated =
        await ref.read(rideRepositoryProvider).updateRideState(next);
    state = state.copyWith(ride: updated, isLoading: false);
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await ref.read(rideRepositoryProvider).verifyOtp(otp);
    if (success) {
      final updated = await ref
          .read(rideRepositoryProvider)
          .updateRideState(RideState.tripStarted);
      state =
          state.copyWith(ride: updated, isLoading: false, otpVerified: true);
      return true;
    } else {
      state = state.copyWith(
          isLoading: false,
          error:
              'Incorrect OTP. Please check the code with your rider and try again.');
      return false;
    }
  }

  Future<void> ratePassenger(double rating, String? comment) async {
    state = state.copyWith(isLoading: true);
    await ref.read(rideRepositoryProvider).ratePassenger(rating, comment);
    final updated =
        await ref.read(rideRepositoryProvider).updateRideState(RideState.rated);
    state = state.copyWith(ride: updated, isLoading: false);
  }

  Future<void> cancelRide(String reason) async {
    state = state.copyWith(isLoading: true);
    await ref.read(rideRepositoryProvider).cancelRide(reason);
    final updated = await ref
        .read(rideRepositoryProvider)
        .updateRideState(RideState.cancelled);
    state = state.copyWith(ride: updated, isLoading: false);
  }

  void resetRide() {
    state = RideStateWrapper(ride: MockData.activeRide);
  }
}

final rideNotifierProvider =
    StateNotifierProvider<RideNotifier, RideStateWrapper>((ref) {
  return RideNotifier(ref);
});
