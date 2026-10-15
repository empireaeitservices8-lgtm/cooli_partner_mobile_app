import '../models/models.dart';
import '../services/mock_data.dart';

abstract class EarningsRepository {
  Future<EarningsSummary> getEarningsSummary();
  Future<List<DailyChartDataPoint>> getChartData();
  Future<List<EarningsTransaction>> getTransactions();
  Future<EarningsTransaction?> getTransactionById(String id);
}

class MockEarningsRepository implements EarningsRepository {
  @override
  Future<EarningsSummary> getEarningsSummary() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.earningsSummary;
  }

  @override
  Future<List<DailyChartDataPoint>> getChartData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.weeklyChartPoints;
  }

  @override
  Future<List<EarningsTransaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.recentTransactions;
  }

  @override
  Future<EarningsTransaction?> getTransactionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return MockData.recentTransactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
