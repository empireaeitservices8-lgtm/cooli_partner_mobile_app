import '../models/models.dart';
import '../services/mock_data.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles({Partner? partner});
  Future<Vehicle?> getActiveVehicle({Partner? partner});
  Future<Vehicle> addVehicle(Vehicle vehicle);
  Future<bool> setActiveVehicle(String vehicleId);
}

class MockVehicleRepository implements VehicleRepository {
  final List<Vehicle> _vehicles = List.from(MockData.vehicles);

  @override
  Future<List<Vehicle>> getVehicles({Partner? partner}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (partner == null) return List.from(_vehicles);

    switch (partner.role) {
      case PartnerRole.rider:
        return _vehicles.where((v) =>
          v.type == VehicleType.auto ||
          v.type == VehicleType.bike ||
          v.makeModel.toLowerCase().contains('dzire') ||
          v.partnerId == partner.id
        ).toList();
      case PartnerRole.porter:
        return _vehicles.where((v) =>
          v.type == VehicleType.miniTruck ||
          v.type == VehicleType.pickupTruck ||
          v.partnerId == partner.id
        ).toList();
      case PartnerRole.truckDriver:
        return _vehicles.where((v) =>
          v.type == VehicleType.heavyTruck ||
          v.partnerId == partner.id
        ).toList();
      case PartnerRole.fleetOwner:
        return List.from(_vehicles);
    }
  }

  @override
  Future<Vehicle?> getActiveVehicle({Partner? partner}) async {
    final list = await getVehicles(partner: partner);
    try {
      return list.firstWhere((v) => v.isActive);
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _vehicles.add(vehicle);
    return vehicle;
  }

  @override
  Future<bool> setActiveVehicle(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _vehicles.length; i++) {
      _vehicles[i] = _vehicles[i].copyWith(isActive: _vehicles[i].id == vehicleId);
    }
    return true;
  }
}
