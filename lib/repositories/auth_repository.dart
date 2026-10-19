import '../models/models.dart';
import '../services/mock_data.dart';

abstract class AuthRepository {
  Future<bool> sendOtp(String phoneNumber);
  Future<Partner?> verifyOtp(String phoneNumber, String otp);
  Future<Partner?> getCurrentPartner();
  Future<bool> isRegistered(String phoneNumber);
  Future<bool> isVerificationCompleted(String phoneNumber);
  Future<Partner?> getPartnerByPhone(String phoneNumber);
  Future<Partner> completeVerification(String phoneNumber);
  Future<Partner> registerPartner({
    required String name,
    required String phone,
    required String email,
    required String city,
    required PartnerRole role,
  });
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  Partner? _partner = MockData.currentPartner;
  bool _isAuthenticated = true;

  // Registered Partners map keyed by normalized phone digits
  static final Map<String, Partner> _registeredPartners = {
    '9745567210': MockData.riderPartner,
    '9847012345': MockData.porterPartner,
    '9447188301': MockData.truckDriverPartner,
    '9895011990': MockData.fleetOwnerPartner,
    // Demo partner with pending verification
    '9999988888': Partner(
      id: 'CP99014',
      name: 'Anoop Varma',
      phone: '+91 99999 88888',
      email: 'anoop.varma@gmail.com',
      avatarUrl: 'assets/images/driver_avatar.jpg',
      rating: 5.0,
      totalRatings: 0,
      completedJobs: 0,
      isOnline: false,
      status: PartnerStatus.pendingVerification,
      role: PartnerRole.porter,
      workPreference: WorkPreference.porter,
      activeVehicleId: 'veh-001',
      city: 'Kozhikode',
      joinedAt: DateTime(2026, 10, 5),
    ),
  };

  static String _cleanDigits(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  Partner? _findPartner(String phone) {
    final clean = _cleanDigits(phone);
    return _registeredPartners[clean];
  }

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return phoneNumber.isNotEmpty;
  }

  @override
  Future<bool> isRegistered(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _findPartner(phoneNumber) != null;
  }

  @override
  Future<bool> isVerificationCompleted(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final partner = _findPartner(phoneNumber);
    if (partner == null) return false;
    return partner.status == PartnerStatus.active;
  }

  @override
  Future<Partner?> getPartnerByPhone(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _findPartner(phoneNumber);
  }

  @override
  Future<Partner?> verifyOtp(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp == '123456' || otp.length == 6) {
      final existing = _findPartner(phoneNumber);
      if (existing != null) {
        _partner = existing.copyWith(status: PartnerStatus.active);
      } else {
        _partner = MockData.currentPartner.copyWith(phone: phoneNumber, status: PartnerStatus.active);
      }
      _isAuthenticated = true;
      return _partner;
    }
    return null;
  }

  @override
  Future<Partner?> getCurrentPartner() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _isAuthenticated ? _partner : null;
  }

  @override
  Future<Partner> registerPartner({
    required String name,
    required String phone,
    required String email,
    required String city,
    required PartnerRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newPartner = Partner(
      id: 'CP${DateTime.now().millisecondsSinceEpoch % 100000}',
      name: name,
      phone: phone,
      email: email,
      avatarUrl: MockData.currentPartner.avatarUrl,
      rating: 5.0,
      totalRatings: 0,
      completedJobs: 0,
      isOnline: false,
      status: PartnerStatus.active,
      role: role,
      workPreference: switch (role) {
        PartnerRole.rider => WorkPreference.rides,
        PartnerRole.porter => WorkPreference.porter,
        PartnerRole.truckDriver => WorkPreference.truck,
        PartnerRole.fleetOwner => WorkPreference.all,
      },
      city: city,
      joinedAt: DateTime.now(),
    );

    final clean = _cleanDigits(phone);
    _registeredPartners[clean] = newPartner;
    _partner = newPartner;
    _isAuthenticated = true;
    return newPartner;
  }

  @override
  Future<Partner> completeVerification(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final clean = _cleanDigits(phoneNumber);
    Partner? partner = _findPartner(phoneNumber);

    final verifiedPartner = (partner ?? (_partner ?? MockData.currentPartner)).copyWith(
      status: PartnerStatus.active,
      isOnline: true,
    );

    _registeredPartners[clean] = verifiedPartner;
    _partner = verifiedPartner;
    MockData.currentPartner = verifiedPartner;
    return verifiedPartner;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isAuthenticated = false;
    _partner = null;
  }
}
