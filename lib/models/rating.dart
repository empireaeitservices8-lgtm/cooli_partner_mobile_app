import 'job.dart';

class PartnerReview {
  final String id;
  final String customerName;
  final double rating;
  final String comment;
  final JobType jobType;
  final DateTime date;

  const PartnerReview({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.jobType,
    required this.date,
  });
}

class RatingSummary {
  final double overallRating;
  final int totalReviews;
  final Map<int, int> starCounts; // {5: 142, 4: 28, 3: 5, 2: 1, 1: 0}

  const RatingSummary({
    required this.overallRating,
    required this.totalReviews,
    required this.starCounts,
  });
}
