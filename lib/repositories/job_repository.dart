import '../models/models.dart';
import '../services/mock_data.dart';

abstract class JobRepository {
  Future<List<Job>> getAvailableJobs({JobType? filterType});
  Future<List<Job>> getAcceptedJobs();
  Future<List<Job>> getJobHistory({JobType? filterType});
  Future<Job?> getJobById(String id);
  Future<bool> acceptJob(String jobId);
  Future<bool> declineJob(String jobId);
}

class MockJobRepository implements JobRepository {
  final List<Job> _jobs = List.from(MockData.availableJobs);
  final List<Job> _accepted = [];
  final List<Job> _history = [];

  @override
  Future<List<Job>> getAvailableJobs({JobType? filterType}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (filterType == null) {
      return _jobs.where((j) => j.status == JobStatus.available).toList();
    }
    return _jobs.where((j) => j.status == JobStatus.available && j.type == filterType).toList();
  }

  @override
  Future<List<Job>> getAcceptedJobs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _accepted;
  }

  @override
  Future<List<Job>> getJobHistory({JobType? filterType}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_history.isEmpty) {
      // Seed initial history
      _history.addAll([
        Job(
          id: 'hist-01',
          type: JobType.ride,
          status: JobStatus.completed,
          pickup: MockData.locKochi,
          destination: MockData.locErnakulam,
          distanceKm: 12.4,
          estimatedMinutes: 28,
          grossFare: 420.0,
          netEarnings: 380.0,
          customerName: 'Anand Nair',
          customerPhone: '+91 94471 20984',
          customerRating: 4.8,
          vehicleRequired: 'Hatchback',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Job(
          id: 'hist-02',
          type: JobType.porter,
          status: JobStatus.completed,
          pickup: MockData.locKochi,
          destination: MockData.locKakkanad,
          distanceKm: 16.8,
          estimatedMinutes: 38,
          grossFare: 950.0,
          netEarnings: 850.0,
          customerName: 'TechSolutions Hub',
          customerPhone: '+91 98460 77123',
          customerRating: 4.9,
          vehicleRequired: 'Tata Ace',
          packageDetails: 'Electronics & Servers',
          weightKg: 120.0,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Job(
          id: 'hist-03',
          type: JobType.truck,
          status: JobStatus.completed,
          pickup: MockData.locKochi,
          destination: MockData.locThrissur,
          distanceKm: 78.5,
          estimatedMinutes: 120,
          grossFare: 3900.0,
          netEarnings: 3500.0,
          customerName: 'Kerala Agro Exporters',
          customerPhone: '+91 97455 33412',
          customerRating: 4.8,
          vehicleRequired: 'Mini Truck',
          packageDetails: 'Fresh produce crates',
          weightKg: 1000.0,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          completedAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ]);
    }

    if (filterType == null) return _history;
    return _history.where((j) => j.type == filterType).toList();
  }

  @override
  Future<Job?> getJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      try {
        return _accepted.firstWhere((j) => j.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<bool> acceptJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      final updated = _jobs[index].copyWith(
        status: JobStatus.accepted,
        acceptedAt: DateTime.now(),
      );
      _jobs.removeAt(index);
      _accepted.add(updated);
      return true;
    }
    return false;
  }

  @override
  Future<bool> declineJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _jobs.removeWhere((j) => j.id == jobId);
    return true;
  }
}
