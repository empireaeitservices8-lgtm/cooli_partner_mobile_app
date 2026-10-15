import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'app_providers.dart';

class VehicleState {
  final List<Vehicle> vehicles;
  final Vehicle? activeVehicle;
  final bool isLoading;
  final String? error;

  const VehicleState({
    this.vehicles = const [],
    this.activeVehicle,
    this.isLoading = false,
    this.error,
  });

  VehicleState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? activeVehicle,
    bool? isLoading,
    String? error,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      activeVehicle: activeVehicle ?? this.activeVehicle,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VehicleNotifier extends StateNotifier<VehicleState> {
  final Ref ref;

  VehicleNotifier(this.ref) : super(const VehicleState()) {
    loadVehicles();
  }

  Future<void> loadVehicles([Partner? partnerOverride]) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(vehicleRepositoryProvider);
      final partner = partnerOverride ?? MockData.currentPartner;
      final vehicles = await repo.getVehicles(partner: partner);
      final active = vehicles.isNotEmpty
          ? vehicles.firstWhere((v) => v.isActive, orElse: () => vehicles.first)
          : null;
      state = state.copyWith(
        vehicles: vehicles,
        activeVehicle: active,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not load vehicles.');
    }
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(vehicleRepositoryProvider).addVehicle(vehicle);
      await loadVehicles();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to add vehicle.');
      return false;
    }
  }

  Future<void> setActiveVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true);
    await ref.read(vehicleRepositoryProvider).setActiveVehicle(vehicleId);
    await loadVehicles();
  }
}

final vehicleNotifierProvider = StateNotifierProvider<VehicleNotifier, VehicleState>((ref) {
  return VehicleNotifier(ref);
});
