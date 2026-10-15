enum BidStatus {
  active,
  counterOfferReceived,
  accepted,
  rejected,
  expired,
}

class Bid {
  final String id;
  final String loadId;
  final String partnerId;
  final String loadTitle;
  final String routeSummary; // e.g. "Kochi → Thrissur (180 km)"
  final double customerOfferedPrice;
  final double yourBidAmount;
  final double? counterOfferAmount;
  final BidStatus status;
  final DateTime submittedAt;
  final DateTime? respondedAt;
  final String? counterNote;

  const Bid({
    required this.id,
    required this.loadId,
    required this.partnerId,
    required this.loadTitle,
    required this.routeSummary,
    required this.customerOfferedPrice,
    required this.yourBidAmount,
    this.counterOfferAmount,
    required this.status,
    required this.submittedAt,
    this.respondedAt,
    this.counterNote,
  });

  Bid copyWith({
    String? id,
    String? loadId,
    String? partnerId,
    String? loadTitle,
    String? routeSummary,
    double? customerOfferedPrice,
    double? yourBidAmount,
    double? counterOfferAmount,
    BidStatus? status,
    DateTime? submittedAt,
    DateTime? respondedAt,
    String? counterNote,
  }) {
    return Bid(
      id: id ?? this.id,
      loadId: loadId ?? this.loadId,
      partnerId: partnerId ?? this.partnerId,
      loadTitle: loadTitle ?? this.loadTitle,
      routeSummary: routeSummary ?? this.routeSummary,
      customerOfferedPrice: customerOfferedPrice ?? this.customerOfferedPrice,
      yourBidAmount: yourBidAmount ?? this.yourBidAmount,
      counterOfferAmount: counterOfferAmount ?? this.counterOfferAmount,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      counterNote: counterNote ?? this.counterNote,
    );
  }
}
