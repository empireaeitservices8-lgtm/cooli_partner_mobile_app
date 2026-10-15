import '../models/models.dart';
import '../services/mock_data.dart';

abstract class ProfileRepository {
  Future<Partner> getProfile();
  Future<Partner> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? city,
    WorkPreference? workPreference,
  });
  Future<bool> setOnlineStatus(bool isOnline);
  Future<BankAccount> getBankAccount();
  Future<BankAccount> updateBankAccount(BankAccount account);
  Future<RatingSummary> getRatingSummary();
  Future<List<PartnerReview>> getReviews();
}

class MockProfileRepository implements ProfileRepository {
  Partner _partner = MockData.currentPartner;
  BankAccount _bankAccount = MockData.primaryBankAccount;

  @override
  Future<Partner> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _partner;
  }

  @override
  Future<Partner> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? city,
    WorkPreference? workPreference,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _partner = _partner.copyWith(
      name: name,
      email: email,
      phone: phone,
      city: city,
      workPreference: workPreference,
    );
    return _partner;
  }

  @override
  Future<bool> setOnlineStatus(bool isOnline) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _partner = _partner.copyWith(isOnline: isOnline);
    return _partner.isOnline;
  }

  @override
  Future<BankAccount> getBankAccount() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _bankAccount;
  }

  @override
  Future<BankAccount> updateBankAccount(BankAccount account) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _bankAccount = account;
    return _bankAccount;
  }

  @override
  Future<RatingSummary> getRatingSummary() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockData.ratingSummary;
  }

  @override
  Future<List<PartnerReview>> getReviews() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.recentReviews;
  }
}
