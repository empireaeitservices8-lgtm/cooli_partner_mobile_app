import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'app_providers.dart';

enum EarningsTimePeriod {
  today,
  week,
  month,
}

class EarningsState {
  final EarningsSummary summary;
  final List<DailyChartDataPoint> chartPoints;
  final List<EarningsTransaction> transactions;
  final EarningsTimePeriod selectedPeriod;
  final bool isLoading;
  final String? error;

  const EarningsState({
    required this.summary,
    this.chartPoints = const [],
    this.transactions = const [],
    this.selectedPeriod = EarningsTimePeriod.today,
    this.isLoading = false,
    this.error,
  });

  EarningsState copyWith({
    EarningsSummary? summary,
    List<DailyChartDataPoint>? chartPoints,
    List<EarningsTransaction>? transactions,
    EarningsTimePeriod? selectedPeriod,
    bool? isLoading,
    String? error,
  }) {
    return EarningsState(
      summary: summary ?? this.summary,
      chartPoints: chartPoints ?? this.chartPoints,
      transactions: transactions ?? this.transactions,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EarningsNotifier extends StateNotifier<EarningsState> {
  final Ref ref;

  EarningsNotifier(this.ref)
      : super(const EarningsState(summary: MockData.earningsSummary)) {
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(earningsRepositoryProvider);
      final summary = await repo.getEarningsSummary();
      final chartPoints = await repo.getChartData();
      final txns = await repo.getTransactions();
      state = state.copyWith(
        summary: summary,
        chartPoints: chartPoints,
        transactions: txns,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not fetch earnings.');
    }
  }

  void selectPeriod(EarningsTimePeriod period) {
    state = state.copyWith(selectedPeriod: period);
  }
}

final earningsNotifierProvider = StateNotifierProvider<EarningsNotifier, EarningsState>((ref) {
  return EarningsNotifier(ref);
});
