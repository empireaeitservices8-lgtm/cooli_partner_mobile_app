import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'app_providers.dart';
import 'vehicle_provider.dart';

class PartnerState {
  final Partner partner;
  final bool isLoading;
  final String? error;

  const PartnerState({
    required this.partner,
    this.isLoading = false,
    this.error,
  });

  PartnerState copyWith({
    Partner? partner,
    bool? isLoading,
    String? error,
  }) {
    return PartnerState(
      partner: partner ?? this.partner,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PartnerNotifier extends StateNotifier<PartnerState> {
  final Ref ref;

  PartnerNotifier(this.ref) : super(PartnerState(partner: MockData.currentPartner)) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      state = state.copyWith(partner: profile);
    } catch (_) {}
  }

  Future<void> toggleOnlineStatus() async {
    final nextStatus = !state.partner.isOnline;
    // Optimistic update
    state = state.copyWith(partner: state.partner.copyWith(isOnline: nextStatus));
    try {
      await ref.read(profileRepositoryProvider).setOnlineStatus(nextStatus);
    } catch (_) {
      // Revert if error
      state = state.copyWith(partner: state.partner.copyWith(isOnline: !nextStatus));
    }
  }

  Future<void> switchPartner(Partner partner) async {
    MockData.currentPartner = partner;
    state = state.copyWith(partner: partner);
    await ref.read(vehicleNotifierProvider.notifier).loadVehicles(partner);
    if (partner.activeVehicleId != null) {
      ref.read(vehicleNotifierProvider.notifier).setActiveVehicle(partner.activeVehicleId!);
    }
  }

  Future<void> setWorkPreference(WorkPreference pref) async {
    state = state.copyWith(partner: state.partner.copyWith(workPreference: pref));
    try {
      await ref.read(profileRepositoryProvider).updateProfile(workPreference: pref);
    } catch (_) {}
  }

  Future<void> updateProfile({String? name, String? email, String? city}) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await ref.read(profileRepositoryProvider).updateProfile(
            name: name,
            email: email,
            city: city,
          );
      state = state.copyWith(partner: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not update profile');
    }
  }
}

final partnerNotifierProvider = StateNotifierProvider<PartnerNotifier, PartnerState>((ref) {
  return PartnerNotifier(ref);
});

// Shortcut provider for online status
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(partnerNotifierProvider).partner.isOnline;
});
