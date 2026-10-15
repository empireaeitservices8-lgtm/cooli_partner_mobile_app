import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/repositories.dart';
import '../services/location_service.dart';

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return MockJobRepository();
});

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return MockRideRepository();
});

final porterRepositoryProvider = Provider<PorterRepository>((ref) {
  return MockPorterRepository();
});

final truckRepositoryProvider = Provider<TruckRepository>((ref) {
  return MockTruckRepository();
});

final bidRepositoryProvider = Provider<BidRepository>((ref) {
  return MockBidRepository();
});

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return MockEarningsRepository();
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return MockVehicleRepository();
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return MockDocumentRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return MockNotificationRepository();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository();
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return MockSupportRepository();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return PartnerLocationService();
});
