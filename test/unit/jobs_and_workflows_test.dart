import 'package:flutter_test/flutter_test.dart';
import 'package:cooli_partner/models/models.dart';
import 'package:cooli_partner/repositories/job_repository.dart';
import 'package:cooli_partner/repositories/ride_repository.dart';
import 'package:cooli_partner/repositories/porter_repository.dart';
import 'package:cooli_partner/repositories/bid_repository.dart';

void main() {
  group('COOLI PARTNER - Workflows & State Machines Tests', () {
    test('Job acceptance removes from available and moves to accepted', () async {
      final jobRepo = MockJobRepository();
      final initialJobs = await jobRepo.getAvailableJobs();
      expect(initialJobs.isNotEmpty, isTrue);

      final targetJobId = initialJobs.first.id;
      final acceptSuccess = await jobRepo.acceptJob(targetJobId);
      expect(acceptSuccess, isTrue);

      final acceptedJobs = await jobRepo.getAcceptedJobs();
      expect(acceptedJobs.any((j) => j.id == targetJobId), isTrue);

      final updatedAvailable = await jobRepo.getAvailableJobs();
      expect(updatedAvailable.any((j) => j.id == targetJobId), isFalse);
    });

    test('Ride progression state transitions execute correctly', () async {
      final rideRepo = MockRideRepository();
      var ride = await rideRepo.getActiveRide();
      expect(ride, isNotNull);

      // Verify OTP to start trip
      final otpSuccess = await rideRepo.verifyOtp('4821');
      expect(otpSuccess, isTrue);

      // Advance to destination
      ride = await rideRepo.updateRideState(RideState.arrivedAtDestination);
      expect(ride.state, RideState.arrivedAtDestination);

      // Complete trip
      ride = await rideRepo.updateRideState(RideState.completed);
      expect(ride.state, RideState.completed);
      expect(ride.endedAt, isNotNull);
    });

    test('Porter workflow PIN verification completes delivery', () async {
      final porterRepo = MockPorterRepository();
      var job = await porterRepo.getActivePorterJob();
      expect(job, isNotNull);

      // Going to pickup
      job = await porterRepo.updatePorterState(PorterState.goingToPickup);
      expect(job.state, PorterState.goingToPickup);

      // Goods loaded
      job = await porterRepo.updatePorterState(PorterState.goodsLoaded);
      expect(job.state, PorterState.goodsLoaded);

      // Verify Drop PIN
      final pinSuccess = await porterRepo.verifyDropPin('7392');
      expect(pinSuccess, isTrue);

      final completedJob = await porterRepo.getActivePorterJob();
      expect(completedJob!.state, PorterState.completed);
    });

    test('Truck bidding and counter-offer acceptance works seamlessly', () async {
      final bidRepo = MockBidRepository();

      // Submit new bid
      final newBid = await bidRepo.submitBid(
        loadId: 'load-001',
        loadTitle: 'Apples 1 Ton',
        routeSummary: 'Kochi → Thrissur',
        customerOfferedPrice: 3200.0,
        yourBidAmount: 3500.0,
      );
      expect(newBid.status, BidStatus.active);
      expect(newBid.yourBidAmount, 3500.0);

      // Accept counter offer on bid-501
      final acceptCounter = await bidRepo.acceptCounterOffer('bid-501');
      expect(acceptCounter, isTrue);

      final bids = await bidRepo.getBids(statusFilter: BidStatus.accepted);
      expect(bids.any((b) => b.id == 'bid-501'), isTrue);
    });
  });
}
