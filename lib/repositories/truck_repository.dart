import '../models/models.dart';
import '../services/mock_data.dart';

abstract class TruckRepository {
  Future<List<TruckLoad>> getAvailableLoads();
  Future<TruckLoad?> getLoadById(String id);
}

class MockTruckRepository implements TruckRepository {
  final List<TruckLoad> _loads = List.from(MockData.truckLoads);

  @override
  Future<List<TruckLoad>> getAvailableLoads() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _loads;
  }

  @override
  Future<TruckLoad?> getLoadById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _loads.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
