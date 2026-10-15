import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'app_providers.dart';

class PorterStateWrapper {
  final PorterJob? job;
  final bool isLoading;
  final String? error;

  const PorterStateWrapper({
    this.job,
    this.isLoading = false,
    this.error,
  });

  PorterStateWrapper copyWith({
    PorterJob? job,
    bool? isLoading,
    String? error,
  }) {
    return PorterStateWrapper(
      job: job ?? this.job,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PorterNotifier extends StateNotifier<PorterStateWrapper> {
  final Ref ref;

  PorterNotifier(this.ref) : super(PorterStateWrapper(job: MockData.activePorterJob));

  Future<void> advanceToNextState() async {
    final current = state.job;
    if (current == null) return;

    PorterState next;
    switch (current.state) {
      case PorterState.available:
        next = PorterState.accepted;
        break;
      case PorterState.accepted:
        next = PorterState.goingToPickup;
        break;
      case PorterState.goingToPickup:
        next = PorterState.arrivedAtPickup;
        break;
      case PorterState.arrivedAtPickup:
        next = PorterState.goodsLoaded;
        break;
      case PorterState.goodsLoaded:
        next = PorterState.deliveryStarted;
        break;
      case PorterState.deliveryStarted:
        next = PorterState.arrivedAtDrop;
        break;
      case PorterState.arrivedAtDrop:
        next = PorterState.goodsDelivered;
        break;
      case PorterState.goodsDelivered:
        next = PorterState.completed;
        break;
      case PorterState.completed:
      case PorterState.cancelled:
        return;
    }

    state = state.copyWith(isLoading: true);
    final updated = await ref.read(porterRepositoryProvider).updatePorterState(next);
    state = state.copyWith(job: updated, isLoading: false);
  }

  Future<bool> verifyDropPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await ref.read(porterRepositoryProvider).verifyDropPin(pin);
    if (success) {
      final updated = await ref.read(porterRepositoryProvider).updatePorterState(PorterState.completed);
      state = state.copyWith(job: updated, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: 'Incorrect Drop PIN. Try 7392');
      return false;
    }
  }

  void resetJob() {
    state = PorterStateWrapper(job: MockData.activePorterJob);
  }
}

final porterNotifierProvider = StateNotifierProvider<PorterNotifier, PorterStateWrapper>((ref) {
  return PorterNotifier(ref);
});
