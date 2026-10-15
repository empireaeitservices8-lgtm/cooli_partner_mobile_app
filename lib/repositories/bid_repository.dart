import '../models/models.dart';
import '../services/mock_data.dart';

abstract class BidRepository {
  Future<List<Bid>> getBids({BidStatus? statusFilter});
  Future<Bid> submitBid({
    required String loadId,
    required String loadTitle,
    required String routeSummary,
    required double customerOfferedPrice,
    required double yourBidAmount,
  });
  Future<bool> acceptCounterOffer(String bidId);
  Future<bool> rejectCounterOffer(String bidId);
  Future<bool> counterAgain(String bidId, double newBidAmount);
}

class MockBidRepository implements BidRepository {
  final List<Bid> _bids = List.from(MockData.bidHistory);

  @override
  Future<List<Bid>> getBids({BidStatus? statusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (statusFilter == null) return List.from(_bids);
    return _bids.where((b) => b.status == statusFilter).toList();
  }

  @override
  Future<Bid> submitBid({
    required String loadId,
    required String loadTitle,
    required String routeSummary,
    required double customerOfferedPrice,
    required double yourBidAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newBid = Bid(
      id: 'bid-${DateTime.now().millisecondsSinceEpoch % 10000}',
      loadId: loadId,
      partnerId: MockData.currentPartner.id,
      loadTitle: loadTitle,
      routeSummary: routeSummary,
      customerOfferedPrice: customerOfferedPrice,
      yourBidAmount: yourBidAmount,
      status: BidStatus.active,
      submittedAt: DateTime.now(),
    );
    _bids.insert(0, newBid);
    return newBid;
  }

  @override
  Future<bool> acceptCounterOffer(String bidId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _bids.indexWhere((b) => b.id == bidId);
    if (index != -1) {
      _bids[index] = _bids[index].copyWith(
        status: BidStatus.accepted,
        respondedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> rejectCounterOffer(String bidId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _bids.indexWhere((b) => b.id == bidId);
    if (index != -1) {
      _bids[index] = _bids[index].copyWith(
        status: BidStatus.rejected,
        respondedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> counterAgain(String bidId, double newBidAmount) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _bids.indexWhere((b) => b.id == bidId);
    if (index != -1) {
      _bids[index] = _bids[index].copyWith(
        yourBidAmount: newBidAmount,
        status: BidStatus.active,
        submittedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }
}
