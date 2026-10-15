import '../models/models.dart';
import '../services/mock_data.dart';

abstract class RideRepository {
  Future<Ride?> getActiveRide();
  Future<Ride> updateRideState(RideState newState);
  Future<bool> verifyOtp(String enteredOtp);
  Future<bool> ratePassenger(double rating, String? comment);
  Future<void> cancelRide(String reason);
}

class MockRideRepository implements RideRepository {
  Ride? _currentRide = MockData.activeRide;

  @override
  Future<Ride?> getActiveRide() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentRide;
  }

  @override
  Future<Ride> updateRideState(RideState newState) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(
        state: newState,
        startedAt: newState == RideState.tripStarted ? DateTime.now() : _currentRide!.startedAt,
        endedAt: newState == RideState.completed ? DateTime.now() : _currentRide!.endedAt,
      );
    }
    return _currentRide!;
  }

  @override
  Future<bool> verifyOtp(String enteredOtp) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentRide != null && (_currentRide!.otp == enteredOtp || enteredOtp == '4821' || enteredOtp == '1234')) {
      _currentRide = _currentRide!.copyWith(state: RideState.tripStarted);
      return true;
    }
    return false;
  }

  @override
  Future<bool> ratePassenger(double rating, String? comment) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(state: RideState.rated);
    }
    return true;
  }

  @override
  Future<void> cancelRide(String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentRide != null) {
      _currentRide = _currentRide!.copyWith(state: RideState.cancelled);
    }
  }
}
