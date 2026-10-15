import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'app_providers.dart';

class AuthState {
  final Partner? partner;
  final bool isLoading;
  final String? errorMessage;
  final String? pendingPhone;
  final bool isAuthenticated;

  const AuthState({
    this.partner,
    this.isLoading = false,
    this.errorMessage,
    this.pendingPhone,
    this.isAuthenticated = true, // Default to mock authenticated for immediate testing
  });

  AuthState copyWith({
    Partner? partner,
    bool? isLoading,
    String? errorMessage,
    String? pendingPhone,
    bool? isAuthenticated,
  }) {
    return AuthState(
      partner: partner ?? this.partner,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final authRepo = ref.read(authRepositoryProvider);
    final partner = await authRepo.getCurrentPartner();
    if (partner != null) {
      state = state.copyWith(partner: partner, isAuthenticated: true);
    }
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await ref.read(authRepositoryProvider).sendOtp(phone);
      state = state.copyWith(isLoading: false, pendingPhone: phone);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> isPhoneRegistered(String phone) async {
    return ref.read(authRepositoryProvider).isRegistered(phone);
  }

  Future<bool> isPhoneVerificationCompleted(String phone) async {
    return ref.read(authRepositoryProvider).isVerificationCompleted(phone);
  }

  Future<Partner?> getPartnerByPhone(String phone) async {
    return ref.read(authRepositoryProvider).getPartnerByPhone(phone);
  }

  Future<Partner?> completeVerification(String phone) async {
    state = state.copyWith(isLoading: true);
    try {
      final verifiedPartner = await ref.read(authRepositoryProvider).completeVerification(phone);
      state = state.copyWith(isLoading: false, partner: verifiedPartner);
      return verifiedPartner;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Failed to complete verification.');
      return null;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final phone = state.pendingPhone ?? '+91 98470 12345';
      final partner = await ref.read(authRepositoryProvider).verifyOtp(phone, otp);
      if (partner != null) {
        state = state.copyWith(isLoading: false, partner: partner, isAuthenticated: true);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP. Please enter 123456');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Verification failed. Try again.');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String city,
    required PartnerRole role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final partner = await ref.read(authRepositoryProvider).registerPartner(
            name: name,
            phone: phone,
            email: email,
            city: city,
            role: role,
          );
      state = state.copyWith(isLoading: false, partner: partner, isAuthenticated: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Registration failed.');
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(isAuthenticated: false);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
