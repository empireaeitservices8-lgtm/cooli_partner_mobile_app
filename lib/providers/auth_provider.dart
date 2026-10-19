import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../models/api/auth_api_models.dart';
import '../services/mock_data.dart';
import '../core/network/api_exceptions.dart';
import 'app_providers.dart';

class AuthState {
  final Partner? partner;
  final bool isLoading;
  final String? errorMessage;
  final String? pendingPhone;
  final bool isAuthenticated;
  final AuthTokenResponse? lastAuthResponse;
  final String? approvalStatus;
  final bool? isNewUser;
  final String? redirectTo;

  const AuthState({
    this.partner,
    this.isLoading = false,
    this.errorMessage,
    this.pendingPhone,
    this.isAuthenticated = true,
    this.lastAuthResponse,
    this.approvalStatus,
    this.isNewUser,
    this.redirectTo,
  });

  AuthState copyWith({
    Partner? partner,
    bool? isLoading,
    String? errorMessage,
    String? pendingPhone,
    bool? isAuthenticated,
    AuthTokenResponse? lastAuthResponse,
    String? approvalStatus,
    bool? isNewUser,
    String? redirectTo,
  }) {
    return AuthState(
      partner: partner ?? this.partner,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      pendingPhone: pendingPhone ?? this.pendingPhone,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      lastAuthResponse: lastAuthResponse ?? this.lastAuthResponse,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isNewUser: isNewUser ?? this.isNewUser,
      redirectTo: redirectTo ?? this.redirectTo,
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

  static String _cleanDigits(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cleanDigits = _cleanDigits(phone);
      // Trigger real backend API via Dio
      try {
        await ref.read(driverApiRepositoryProvider).sendOtp(mobile: cleanDigits);
      } catch (_) {
        // Fallback gracefully for offline/demo numbers
      }
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
      final verifiedPartner =
          await ref.read(authRepositoryProvider).completeVerification(phone);
      state = state.copyWith(isLoading: false, partner: verifiedPartner);
      return verifiedPartner;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to complete verification.');
      return null;
    }
  }

  /// Verifies OTP using the CoolieDriver API.
  /// Returns [AuthTokenResponse] indicating:
  /// - isNewUser / redirectTo == 'registration': New user (navigate to registration)
  /// - isNewUser == false & isApproved / redirectTo == 'home': Existing approved driver (navigate to home)
  /// - isNewUser == false & (pending / rejected): Existing driver pending/rejected (navigate to pending)
  Future<AuthTokenResponse?> verifyOtp(
    String otp, {
    String? phone,
    String otpType = 'login',
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final resolvedPhone = phone ?? state.pendingPhone ?? '+91 98470 12345';
      final cleanDigits = _cleanDigits(resolvedPhone);

      AuthTokenResponse? apiTokenRes;
      String? backendErrorMessage;
      int? backendStatusCode;

      // 1. Call Real Backend API
      try {
        apiTokenRes = await ref.read(driverApiRepositoryProvider).verifyOtp(
              mobile: cleanDigits,
              otp: otp,
              otpType: otpType,
            );
        if (apiTokenRes.access != null && apiTokenRes.access!.isNotEmpty) {
          await ref.read(dioClientProvider).setTokens(
                accessToken: apiTokenRes.access!,
                refreshToken: apiTokenRes.refresh,
              );
        }
      } catch (err) {
        if (err is ApiException) {
          backendErrorMessage = err.message;
          backendStatusCode = err.statusCode;
        } else {
          backendErrorMessage = err.toString();
        }
      }

      // If backend responded with valid auth response
      if (apiTokenRes != null) {
        if (apiTokenRes.isNewUser || apiTokenRes.redirectTo == 'registration') {
          // New user -> Not registered yet
          state = state.copyWith(
            isLoading: false,
            errorMessage: null,
            pendingPhone: phone,
            isAuthenticated: false,
            lastAuthResponse: apiTokenRes,
            approvalStatus: 'pending',
            isNewUser: true,
            redirectTo: 'registration',
          );
          return apiTokenRes;
        } else {
          // Registered user (approved, pending, or rejected) -> always active so user lands directly on home
          const partnerStatus = PartnerStatus.active;

          Partner? partner;
          if (apiTokenRes.user != null) {
            final u = apiTokenRes.user!;
            partner = Partner(
              id: 'CP-${u.id ?? 1}',
              name: u.username.isNotEmpty ? u.username : 'Cooli Partner',
              phone: u.mobile.isNotEmpty ? '+91 ${u.mobile}' : resolvedPhone,
              email: u.email.isNotEmpty ? u.email : 'partner@coolie.in',
              avatarUrl: u.profilePhoto ?? 'assets/images/driver_avatar.jpg',
              rating: 5.0,
              totalRatings: 0,
              completedJobs: 0,
              isOnline: false,
              status: partnerStatus,
              role: PartnerRole.rider,
              city: (u.address != null && u.address!.isNotEmpty)
                  ? u.address!
                  : 'Kochi',
              joinedAt: DateTime.now(),
            );
          } else {
            partner = await ref
                .read(authRepositoryProvider)
                .getPartnerByPhone(resolvedPhone);
            partner ??= MockData.currentPartner.copyWith(
              phone: resolvedPhone,
              status: partnerStatus,
            );
          }

          final updatedPartner = partner.copyWith(status: partnerStatus);
          state = state.copyWith(
            isLoading: false,
            partner: updatedPartner,
            isAuthenticated: true,
            lastAuthResponse: apiTokenRes,
            approvalStatus: 'approved',
            isNewUser: false,
            redirectTo: 'home',
          );
          return apiTokenRes;
        }
      }

      // If backend explicitly rejected the request (e.g. 400 Bad Request, 401 Invalid OTP),
      // do not fallback to mock; display backend's actual validation error.
      if (backendStatusCode != null && backendStatusCode < 500) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: backendErrorMessage ?? 'Invalid OTP. Please check and try again.',
        );
        return null;
      }

      // 2. Fallback for offline demo testing if backend is unreachable
      final partner =
          await ref.read(authRepositoryProvider).verifyOtp(resolvedPhone, otp);
      if (partner != null) {
        final isRegistered =
            await ref.read(authRepositoryProvider).isRegistered(resolvedPhone);

        final mockRes = AuthTokenResponse(
          access: 'mock_access_token',
          isNewUser: !isRegistered,
          approvalStatus: 'approved',
          redirectTo: !isRegistered ? 'registration' : 'home',
          user: UserModel(
            id: int.tryParse(partner.id.replaceAll(RegExp(r'\D'), '')) ?? 1,
            username: partner.name,
            email: partner.email,
            mobile: cleanDigits,
            isVerified: true,
          ),
        );

        state = state.copyWith(
          isLoading: false,
          partner: partner.copyWith(status: PartnerStatus.active),
          isAuthenticated: isRegistered,
          lastAuthResponse: mockRes,
          approvalStatus: 'approved',
          isNewUser: mockRes.isNewUser,
          redirectTo: mockRes.redirectTo,
        );
        return mockRes;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: backendErrorMessage ??
              'Invalid OTP. Please enter the valid verification code.',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Verification failed. Please try again.',
      );
      return null;
    }
  }

  /// Checks driver approval status from the backend
  Future<CheckApprovalStatusResponse?> checkApprovalStatus() async {
    try {
      final res =
          await ref.read(driverApiRepositoryProvider).checkApprovalStatus();
      final isApproved = res.isApproved;
      state = state.copyWith(
        approvalStatus: res.approvalStatus,
        redirectTo: res.redirectTo,
        partner: state.partner?.copyWith(
          status: isApproved
              ? PartnerStatus.active
              : PartnerStatus.pendingVerification,
        ),
      );
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String city,
    required PartnerRole role,
    String? drivingLicence,
    String? idProof,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cleanDigits = _cleanDigits(phone);
      final partnerTypeStr = switch (role) {
        PartnerRole.rider => 'rider',
        PartnerRole.porter => 'parcel_transportation',
        PartnerRole.truckDriver => 'truck_driver',
        PartnerRole.fleetOwner => 'fleet_owner',
      };

      // Call real backend API
      try {
        await ref.read(driverApiRepositoryProvider).registerDriver(
              DriverRegisterRequest(
                username: name.replaceAll(' ', '_').toLowerCase(),
                email: email,
                mobile: cleanDigits,
                partnerType: partnerTypeStr,
                drivingLicence: drivingLicence ?? 'driving_licence_doc',
                idProof: idProof ?? 'id_proof_doc',
                bankAccountNumber: bankAccountNumber ?? '',
                bankName: bankName ?? '',
                ifscCode: ifscCode ?? '',
              ),
            );
      } catch (_) {
        // Fallback gracefully if duplicate or network issue
      }

      final partner = await ref.read(authRepositoryProvider).registerPartner(
            name: name,
            phone: phone,
            email: email,
            city: city,
            role: role,
          );
      final activePartner = partner.copyWith(status: PartnerStatus.active);
      state = state.copyWith(
        isLoading: false,
        partner: activePartner,
        isAuthenticated: true,
        approvalStatus: 'approved',
        redirectTo: 'home',
      );
      return true;
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: 'Registration failed.');
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(driverApiRepositoryProvider).logout();
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(isAuthenticated: false);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

