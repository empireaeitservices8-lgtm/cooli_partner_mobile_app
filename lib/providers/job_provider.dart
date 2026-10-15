import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'app_providers.dart';

class JobsState {
  final List<Job> availableJobs;
  final List<Job> acceptedJobs;
  final List<Job> historyJobs;
  final Job? incomingRequest;
  final JobType? selectedFilter;
  final bool isLoading;
  final String? error;

  const JobsState({
    this.availableJobs = const [],
    this.acceptedJobs = const [],
    this.historyJobs = const [],
    this.incomingRequest,
    this.selectedFilter,
    this.isLoading = false,
    this.error,
  });

  JobsState copyWith({
    List<Job>? availableJobs,
    List<Job>? acceptedJobs,
    List<Job>? historyJobs,
    Job? incomingRequest,
    bool clearIncoming = false,
    JobType? selectedFilter,
    bool clearFilter = false,
    bool? isLoading,
    String? error,
  }) {
    return JobsState(
      availableJobs: availableJobs ?? this.availableJobs,
      acceptedJobs: acceptedJobs ?? this.acceptedJobs,
      historyJobs: historyJobs ?? this.historyJobs,
      incomingRequest: clearIncoming ? null : (incomingRequest ?? this.incomingRequest),
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JobsNotifier extends StateNotifier<JobsState> {
  final Ref ref;

  JobsNotifier(this.ref) : super(const JobsState()) {
    loadJobs();
  }

  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final jobRepo = ref.read(jobRepositoryProvider);
      final partner = MockData.currentPartner;

      // Strict role isolation: unless fleetOwner, lock filter to partner's associatedJobType
      final effectiveFilter = partner.role == PartnerRole.fleetOwner
          ? state.selectedFilter
          : partner.role.associatedJobType;

      final available = await jobRepo.getAvailableJobs(filterType: effectiveFilter);
      final accepted = await jobRepo.getAcceptedJobs();
      final history = await jobRepo.getJobHistory(filterType: effectiveFilter);
      state = state.copyWith(
        availableJobs: available,
        acceptedJobs: accepted,
        historyJobs: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load jobs.');
    }
  }

  void setFilter(JobType? filter) {
    if (filter == state.selectedFilter) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(selectedFilter: filter);
    }
    loadJobs();
  }

  void triggerIncomingJob(Job job) {
    state = state.copyWith(incomingRequest: job);
  }

  void dismissIncomingJob() {
    state = state.copyWith(clearIncoming: true);
  }

  Future<bool> acceptJob(String jobId) async {
    final success = await ref.read(jobRepositoryProvider).acceptJob(jobId);
    if (success) {
      dismissIncomingJob();
      await loadJobs();
    }
    return success;
  }

  Future<bool> declineJob(String jobId) async {
    final success = await ref.read(jobRepositoryProvider).declineJob(jobId);
    dismissIncomingJob();
    await loadJobs();
    return success;
  }
}

final jobsNotifierProvider = StateNotifierProvider<JobsNotifier, JobsState>((ref) {
  return JobsNotifier(ref);
});
