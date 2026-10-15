import 'package:flutter_test/flutter_test.dart';
import 'package:cooli_partner/models/models.dart';
import 'package:cooli_partner/repositories/earnings_repository.dart';
import 'package:cooli_partner/repositories/vehicle_repository.dart';
import 'package:cooli_partner/repositories/document_repository.dart';

void main() {
  group('COOLI PARTNER - Earnings, Vehicles & Documents Tests', () {
    test('Earnings calculations and transactions integrity check', () async {
      final repo = MockEarningsRepository();
      final summary = await repo.getEarningsSummary();

      expect(summary.totalGross, greaterThan(summary.netEarnings));
      expect(summary.totalGross - summary.commissionDeducted + summary.bonuses, equals(summary.netEarnings));
      expect(summary.todayEarnings, 2450.0);
    });

    test('Add vehicle and switch active carrier vehicle', () async {
      final vehicleRepo = MockVehicleRepository();
      final initialVehicles = await vehicleRepo.getVehicles();
      expect(initialVehicles.length, greaterThanOrEqualTo(2));

      // Add 3rd vehicle
      final newVeh = Vehicle(
        id: 'veh-new-99',
        partnerId: 'CP10245',
        type: VehicleType.miniTruck,
        makeModel: 'Ashok Leyland Bada Dost',
        registrationNumber: 'KL 07 ZZ 9999',
        capacity: '2.0 Ton',
        fuelType: 'Diesel',
        verificationState: VehicleVerificationState.pending,
        rcNumber: 'KL07ZZ99991122',
        insuranceExpiry: DateTime(2028, 1, 1),
        fitnessExpiry: DateTime(2028, 1, 1),
      );

      await vehicleRepo.addVehicle(newVeh);
      final updated = await vehicleRepo.getVehicles();
      expect(updated.any((v) => v.id == 'veh-new-99'), isTrue);

      // Switch active vehicle
      await vehicleRepo.setActiveVehicle('veh-002');
      final active = await vehicleRepo.getActiveVehicle();
      expect(active!.id, 'veh-002');
    });

    test('Document upload status is marked pending for audit', () async {
      final docRepo = MockDocumentRepository();
      final uploaded = await docRepo.uploadDocument(
        type: DocumentType.panCard,
        title: 'Permanent Account Number',
        documentNumber: 'ABCDE1234F',
      );

      expect(uploaded.status, DocumentStatus.pending);
      expect(uploaded.documentNumber, 'ABCDE1234F');
    });
  });
}
