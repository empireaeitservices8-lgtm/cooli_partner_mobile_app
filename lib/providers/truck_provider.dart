import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'app_providers.dart';

class TruckState {
  final List<TruckLoad> loads;
  final List<Bid> bids;
  final BidStatus? bidFilter;
  final bool isLoading;
  final String? error;
  final String? lastSubmittedBidId;

  const TruckState({
    this.loads = const [],
    this.bids = const [],
    this.bidFilter,
    this.isLoading = false,
    this.error,
    this.lastSubmittedBidId,
  });

  TruckState copyWith({
    List<TruckLoad>? loads,
    List<Bid>? bids,
    BidStatus? bidFilter,
    bool clearBidFilter = false,
    bool? isLoading,
    String? error,
    String? lastSubmittedBidId,
  }) {
    return TruckState(
      loads: loads ?? this.loads,
      bids: bids ?? this.bids,
      bidFilter: clearBidFilter ? null : (bidFilter ?? this.bidFilter),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastSubmittedBidId: lastSubmittedBidId ?? this.lastSubmittedBidId,
    );
  }
}

class TruckNotifier extends StateNotifier<TruckState> {
  final Ref ref;

  TruckNotifier(this.ref) : super(const TruckState()) {
    loadTruckData();
  }

  Future<void> loadTruckData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final truckRepo = ref.read(truckRepositoryProvider);
      final bidRepo = ref.read(bidRepositoryProvider);
      final loads = await truckRepo.getAvailableLoads();
      final bids = await bidRepo.getBids(statusFilter: state.bidFilter);
      state = state.copyWith(loads: loads, bids: bids, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load truck marketplace.');
    }
  }

  void setBidFilter(BidStatus? filter) {
    if (filter == state.bidFilter) {
      state = state.copyWith(clearBidFilter: true);
    } else {
      state = state.copyWith(bidFilter: filter);
    }
    loadTruckData();
  }

  Future<bool> submitBid({
    required TruckLoad load,
    required double yourBidAmount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bid = await ref.read(bidRepositoryProvider).submitBid(
            loadId: load.id,
            loadTitle: '${load.material} (${load.weightDescription})',
            routeSummary: '${load.pickup.title.split(',').first} → ${load.destination.title.split(',').first} (${load.distanceKm} km)',
            customerOfferedPrice: load.customerOfferedPrice,
            yourBidAmount: yourBidAmount,
          );
      state = state.copyWith(lastSubmittedBidId: bid.id);
      await loadTruckData();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not submit bid.');
      return false;
    }
  }

  Future<bool> acceptCounterOffer(String bidId) async {
    final success = await ref.read(bidRepositoryProvider).acceptCounterOffer(bidId);
    if (success) await loadTruckData();
    return success;
  }

  Future<bool> rejectCounterOffer(String bidId) async {
    final success = await ref.read(bidRepositoryProvider).rejectCounterOffer(bidId);
    if (success) await loadTruckData();
    return success;
  }

  Future<bool> counterAgain(String bidId, double newBidAmount) async {
    final success = await ref.read(bidRepositoryProvider).counterAgain(bidId, newBidAmount);
    if (success) await loadTruckData();
    return success;
  }
}

final truckNotifierProvider = StateNotifierProvider<TruckNotifier, TruckState>((ref) {
  return TruckNotifier(ref);
});
