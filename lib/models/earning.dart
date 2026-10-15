import 'job.dart';

class EarningsSummary {
  final double totalGross;
  final double netEarnings;
  final double commissionDeducted;
  final double bonuses;
  final int completedTrips;
  final double onlineHours;
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;

  const EarningsSummary({
    required this.totalGross,
    required this.netEarnings,
    required this.commissionDeducted,
    required this.bonuses,
    required this.completedTrips,
    required this.onlineHours,
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
  });
}

class DailyChartDataPoint {
  final String dayName; // "Mon", "Tue", etc.
  final double amount;
  final int tripCount;

  const DailyChartDataPoint({
    required this.dayName,
    required this.amount,
    required this.tripCount,
  });
}

class EarningsTransaction {
  final String id;
  final String jobId;
  final JobType jobType;
  final String title;
  final String routeSummary;
  final double grossAmount;
  final double commissionAmount;
  final double netAmount;
  final double? tipAmount;
  final String paymentMethod; // "Online Wallet", "Cash Collected", "UPI"
  final DateTime timestamp;

  const EarningsTransaction({
    required this.id,
    required this.jobId,
    required this.jobType,
    required this.title,
    required this.routeSummary,
    required this.grossAmount,
    required this.commissionAmount,
    required this.netAmount,
    this.tipAmount,
    required this.paymentMethod,
    required this.timestamp,
  });
}
