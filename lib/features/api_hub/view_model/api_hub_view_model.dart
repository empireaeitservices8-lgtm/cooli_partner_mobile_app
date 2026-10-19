import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/api/api_models.dart';
import '../../../providers/app_providers.dart';
import '../../../repositories/api/driver_api_repository.dart';

/// State representing API Live Hub
class ApiHubState {
  final bool isLoading;
  final String? activeEndpoint;
  final dynamic lastData;
  final int? lastStatusCode;
  final int? lastDurationMs;
  final String? errorMessage;
  final String? accessToken;
  final bool isOnline;
  final DriverProfileModel? profile;
  final DriverDashboardModel? dashboard;
  final List<VehicleApiModel> vehicles;
  final List<BookingApiModel> pendingBookings;
  final List<TripApiModel> trips;
  final WalletApiModel? wallet;
  final List<LoadApiModel> loads;

  const ApiHubState({
    this.isLoading = false,
    this.activeEndpoint,
    this.lastData,
    this.lastStatusCode,
    this.lastDurationMs,
    this.errorMessage,
    this.accessToken,
    this.isOnline = false,
    this.profile,
    this.dashboard,
    this.vehicles = const [],
    this.pendingBookings = const [],
    this.trips = const [],
    this.wallet,
    this.loads = const [],
  });

  ApiHubState copyWith({
    bool? isLoading,
    String? activeEndpoint,
    dynamic lastData,
    int? lastStatusCode,
    int? lastDurationMs,
    String? errorMessage,
    String? accessToken,
    bool? isOnline,
    DriverProfileModel? profile,
    DriverDashboardModel? dashboard,
    List<VehicleApiModel>? vehicles,
    List<BookingApiModel>? pendingBookings,
    List<TripApiModel>? trips,
    WalletApiModel? wallet,
    List<LoadApiModel>? loads,
    bool clearError = false,
  }) {
    return ApiHubState(
      isLoading: isLoading ?? this.isLoading,
      activeEndpoint: activeEndpoint ?? this.activeEndpoint,
      lastData: lastData ?? this.lastData,
      lastStatusCode: lastStatusCode ?? this.lastStatusCode,
      lastDurationMs: lastDurationMs ?? this.lastDurationMs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      accessToken: accessToken ?? this.accessToken,
      isOnline: isOnline ?? this.isOnline,
      profile: profile ?? this.profile,
      dashboard: dashboard ?? this.dashboard,
      vehicles: vehicles ?? this.vehicles,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      trips: trips ?? this.trips,
      wallet: wallet ?? this.wallet,
      loads: loads ?? this.loads,
    );
  }
}

/// ViewModel for executing and observing APIs
class ApiHubViewModel extends StateNotifier<ApiHubState> {
  final DriverApiRepository _repo;
  final DioClient _dioClient;

  ApiHubViewModel(this._repo, this._dioClient)
      : super(ApiHubState(accessToken: _dioClient.accessToken));

  Future<void> sendOtp({
    required String mobile,
    String otpType = 'login',
  }) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Send OTP (/api/send-otp/)',
      clearError: true,
    );
    try {
      final res = await _repo.sendOtp(mobile: mobile, otpType: otpType);
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: {'success': res.success, 'message': res.message, 'raw': res.data},
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> verifyOtp({
    required String mobile,
    required String otp,
    String otpType = 'login',
  }) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Verify OTP (/api/verify-otp/)',
      clearError: true,
    );
    try {
      final res = await _repo.verifyOtp(mobile: mobile, otp: otp, otpType: otpType);
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: {
          'access_token': res.access,
          'refresh_token': res.refresh,
          'user_id': res.userId,
          'message': res.message ?? 'Login Successful',
          'raw': res.rawData,
        },
        accessToken: res.access ?? _dioClient.accessToken,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> registerDriver(DriverRegisterRequest req) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Register Driver (/api/register/driver/)',
      clearError: true,
    );
    try {
      final res = await _repo.registerDriver(req);
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: res.toJson(),
        profile: res,
        lastStatusCode: 201,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> fetchProfile() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Get Profile (/api/drivers/)',
      clearError: true,
    );
    try {
      final res = await _repo.getDriverProfile();
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: res.toJson(),
        profile: res,
        isOnline: res.isOnline,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> toggleOnline(bool isOnline) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Toggle Online (/api/drivers/toggle_online/)',
      clearError: true,
    );
    try {
      final res = await _repo.toggleOnline(isOnline);
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: {'is_online': res},
        isOnline: res,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> updateLocation(double lat, double lng) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Update Location (/api/drivers/update_location/)',
      clearError: true,
    );
    try {
      final res = await _repo.updateLocation(lat: lat, lng: lng);
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: {'location_updated': res, 'lat': lat, 'lng': lng},
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> fetchDashboard() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Driver Dashboard (/api/drivers/dashboard/)',
      clearError: true,
    );
    try {
      final res = await _repo.getDashboard();
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: {
          'total_trips': res.totalTrips,
          'total_earnings': res.totalEarnings,
          'rating': res.rating,
          'is_online': res.isOnline,
          'pending_requests': res.pendingRequests,
          'raw': res.raw,
        },
        dashboard: res,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> fetchVehicles() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Get Vehicles (/api/vehicles/)',
      clearError: true,
    );
    try {
      final res = await _repo.getVehicles();
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: res.map((e) => e.toJson()).toList(),
        vehicles: res,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> addVehicle(VehicleApiModel vehicle) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Add Vehicle (/api/vehicles/)',
      clearError: true,
    );
    try {
      final res = await _repo.addVehicle(vehicle);
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: res.toJson(),
        vehicles: [...state.vehicles, res],
        lastStatusCode: 201,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> fetchPendingBookings() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Pending Bookings (/api/bookings/pending_requests/)',
      clearError: true,
    );
    try {
      final res = await _repo.getPendingBookings();
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: res.map((e) => e.toJson()).toList(),
        pendingBookings: res,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> acceptBooking(dynamic id) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Accept Booking (/api/bookings/$id/accept/)',
      clearError: true,
    );
    try {
      final res = await _repo.acceptBooking(id);
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: {'accepted': res, 'booking_id': id},
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> fetchTrips() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Get Trips (/api/trips/)',
      clearError: true,
    );
    try {
      final res = await _repo.getTrips();
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: res.map((e) => e.toJson()).toList(),
        trips: res,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> fetchWallet() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Get Wallet (/api/wallets/my_wallet/)',
      clearError: true,
    );
    try {
      final res = await _repo.getWallet();
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: {'balance': res.balance, 'currency': res.currency, 'raw': res.raw},
        wallet: res,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  Future<void> fetchLoads() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    state = state.copyWith(
      isLoading: true,
      activeEndpoint: 'Get Loads (/api/loads/)',
      clearError: true,
    );
    try {
      final res = await _repo.getLoads();
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        lastData: res.map((e) => e.toJson()).toList(),
        loads: res,
        lastStatusCode: 200,
        lastDurationMs: duration,
      );
    } catch (e) {
      final duration = DateTime.now().millisecondsSinceEpoch - start;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastStatusCode: 400,
        lastDurationMs: duration,
      );
    }
  }

  void setManualToken(String token) {
    _dioClient.setTokens(accessToken: token);
    state = state.copyWith(accessToken: token);
  }
}

/// Riverpod provider for ApiHubViewModel
final apiHubViewModelProvider =
    StateNotifierProvider<ApiHubViewModel, ApiHubState>((ref) {
  final repo = ref.watch(driverApiRepositoryProvider);
  final dioClient = ref.watch(dioClientProvider);
  return ApiHubViewModel(repo, dioClient);
});
