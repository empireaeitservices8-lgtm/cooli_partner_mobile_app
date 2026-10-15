import 'package:cooli_partner/models/models.dart';
import 'package:cooli_partner/repositories/auth_repository.dart';
import 'package:cooli_partner/services/mock_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('COOLI PARTNER - Authentication Logic Tests', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = MockAuthRepository();
    });

    test('Send OTP succeeds for valid mobile number', () async {
      final result = await authRepository.sendOtp('+91 98470 12345');
      expect(result, isTrue);
    });

    test('Verify OTP succeeds with standard mock PIN 123456', () async {
      final partner =
          await authRepository.verifyOtp('+91 98470 12345', '123456');
      expect(partner, isNotNull);
      expect(partner!.name, 'Rahul Kumar');
      expect(partner.rating, greaterThan(4.5));
    });

    test('Verify OTP fails for incorrect PIN', () async {
      final partner =
          await authRepository.verifyOtp('+91 98470 12345', '99999');
      expect(partner, isNull);
    });

    test('Partner registration sets initial pending verification status',
        () async {
      final partner = await authRepository.registerPartner(
        name: 'Arun Raj',
        phone: '+91 98460 55432',
        email: 'arun@cooli.in',
        city: 'Thrissur',
        role: PartnerRole.truckDriver,
      );

      expect(partner.name, 'Arun Raj');
      expect(partner.city, 'Thrissur');
      expect(partner.id, startsWith('CP'));
      expect(partner.role, PartnerRole.truckDriver);
      expect(partner.workPreference, WorkPreference.truck);
    });

    test('Registration preserves each selected partner category', () async {
      const preferences = {
        PartnerRole.rider: WorkPreference.rides,
        PartnerRole.porter: WorkPreference.porter,
        PartnerRole.truckDriver: WorkPreference.truck,
        PartnerRole.fleetOwner: WorkPreference.all,
      };

      for (final entry in preferences.entries) {
        final partner = await authRepository.registerPartner(
          name: 'New Partner',
          phone: '+91 90000 00000',
          email: 'partner@cooli.in',
          city: 'Kochi',
          role: entry.key,
        );

        expect(partner.role, entry.key);
        expect(partner.workPreference, entry.value);
      }
    });

    test('4 user categories are supported and correctly configured', () {
      expect(PartnerRole.values.length, 4);
      expect(MockData.allDemoPartners.length, 4);

      final roles = MockData.allDemoPartners.map((p) => p.role).toSet();
      expect(
          roles,
          containsAll([
            PartnerRole.rider,
            PartnerRole.porter,
            PartnerRole.truckDriver,
            PartnerRole.fleetOwner,
          ]));
    });

    test('isRegistered correctly identifies registered vs unregistered numbers', () async {
      expect(await authRepository.isRegistered('+91 98470 12345'), isTrue);
      expect(await authRepository.isRegistered('9745567210'), isTrue);
      expect(await authRepository.isRegistered('+91 99999 88888'), isTrue);
      expect(await authRepository.isRegistered('+91 91111 00000'), isFalse);
    });

    test('isVerificationCompleted distinguishes active partners from pending verification', () async {
      // Pre-verified partner
      expect(await authRepository.isVerificationCompleted('+91 98470 12345'), isTrue);
      // Pre-seeded pending verification demo partner
      expect(await authRepository.isVerificationCompleted('+91 99999 88888'), isFalse);
      // Unregistered partner
      expect(await authRepository.isVerificationCompleted('+91 91111 00000'), isFalse);
    });

    test('completeVerification approves pending partner and transitions to active status', () async {
      // Initially pending
      expect(await authRepository.isVerificationCompleted('+91 99999 88888'), isFalse);

      // Admin / RTO complete verification process
      final verifiedPartner = await authRepository.completeVerification('+91 99999 88888');
      expect(verifiedPartner.status, PartnerStatus.active);
      expect(await authRepository.isVerificationCompleted('+91 99999 88888'), isTrue);
    });
  });
}
