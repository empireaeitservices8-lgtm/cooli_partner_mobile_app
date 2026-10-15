import '../models/models.dart';
import '../services/mock_data.dart';

abstract class PorterRepository {
  Future<PorterJob?> getActivePorterJob();
  Future<PorterJob> updatePorterState(PorterState newState);
  Future<bool> verifyDropPin(String enteredPin);
  Future<void> cancelPorterJob(String reason);
}

class MockPorterRepository implements PorterRepository {
  PorterJob? _currentJob = MockData.activePorterJob;

  @override
  Future<PorterJob?> getActivePorterJob() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentJob;
  }

  @override
  Future<PorterJob> updatePorterState(PorterState newState) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentJob != null) {
      _currentJob = _currentJob!.copyWith(state: newState);
    }
    return _currentJob!;
  }

  @override
  Future<bool> verifyDropPin(String enteredPin) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentJob != null && (_currentJob!.securityPin == enteredPin || enteredPin == '7392' || enteredPin == '1234')) {
      _currentJob = _currentJob!.copyWith(state: PorterState.completed);
      return true;
    }
    return false;
  }

  @override
  Future<void> cancelPorterJob(String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentJob != null) {
      _currentJob = _currentJob!.copyWith(state: PorterState.cancelled);
    }
  }
}
