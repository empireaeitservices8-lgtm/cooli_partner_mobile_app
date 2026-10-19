import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../models/api/api_models.dart';

abstract class DriverApiRepository {
  // Auth
  Future<SendOtpResponse> sendOtp({required String mobile, String otpType = 'login'});
  Future<AuthTokenResponse> verifyOtp({required String mobile, required String otp, String otpType = 'login'});
  Future<DriverProfileModel> registerDriver(DriverRegisterRequest request);
  Future<CheckApprovalStatusResponse> checkApprovalStatus();
  Future<dynamic> approveDriver(dynamic driverId);
  Future<dynamic> rejectDriver(dynamic driverId, {String? reason});
  Future<void> logout();

  // Driver Management
  Future<DriverProfileModel> getDriverProfile();
  Future<DriverProfileModel> updateDriverProfile(dynamic id, Map<String, dynamic> data);
  Future<bool> updateLocation({required double lat, required double lng});
  Future<bool> toggleOnline(bool isOnline);
  Future<DriverDashboardModel> getDashboard();

  // Vehicle Management
  Future<List<RideVehicleType>> getRideVehicleTypes();
  Future<List<VehicleApiModel>> getVehicles();
  Future<VehicleApiModel> addVehicle(VehicleApiModel vehicle);
  Future<VehicleApiModel> updateVehicle(dynamic id, Map<String, dynamic> data);
  Future<bool> updateVehicleStatus(dynamic id, String status);
  Future<bool> deleteVehicle(dynamic id);

  // Bookings
  Future<List<BookingApiModel>> getPendingBookings();
  Future<bool> acceptBooking(dynamic id);
  Future<bool> rejectBooking(dynamic id);
  Future<BookingApiModel> updateBookingStatus(dynamic id, String status);
  Future<List<BookingApiModel>> getBookings();

  // Trips
  Future<List<TripApiModel>> getTrips();
  Future<TripApiModel> updateTripStatus(dynamic id, Map<String, dynamic> data);
  Future<TripApiModel> uploadPod(dynamic id, Map<String, dynamic> podData);

  // Wallet & Earnings
  Future<WalletApiModel> getWallet();
  Future<bool> withdrawEarnings(double amount);
  Future<EarningsSummaryModel> getEarningsSummary();
  Future<List<WalletTransactionModel>> getWalletTransactions();

  // Loads & Quotations
  Future<List<LoadApiModel>> getLoads();
  Future<List<LoadApiModel>> searchLoads({
    required String pickup,
    required String delivery,
    required String vehicleType,
  });
  Future<QuotationApiModel> submitQuotation({required dynamic loadId, required double quotedPrice});
  Future<List<QuotationApiModel>> getQuotations();

  // Notifications
  Future<List<NotificationApiModel>> getNotifications();
  Future<bool> markNotificationRead(dynamic id);
  Future<bool> markAllNotificationsRead();
}

/// Concrete Implementation using DioClient with full console logging
class DriverApiRepositoryImpl implements DriverApiRepository {
  final DioClient _client;

  DriverApiRepositoryImpl({DioClient? client}) : _client = client ?? DioClient();

  // ──────────────────────────── Authentication ────────────────────────────
  @override
  Future<SendOtpResponse> sendOtp({
    required String mobile,
    String otpType = 'login',
  }) async {
    final response = await _client.post(
      ApiEndpoints.sendOtp,
      data: {'mobile': mobile, 'otp_type': otpType},
    );
    return SendOtpResponse.fromJson(response.data);
  }

  @override
  Future<AuthTokenResponse> verifyOtp({
    required String mobile,
    required String otp,
    String otpType = 'login',
  }) async {
    final cleanDigits = mobile.replaceAll(RegExp(r'\D'), '');
    final formattedMobile = cleanDigits.length > 10
        ? cleanDigits.substring(cleanDigits.length - 10)
        : cleanDigits;

    final response = await _client.post(
      ApiEndpoints.verifyOtp,
      data: {
        'mobile': formattedMobile,
        'otp': otp.trim(),
        'otp_type': otpType,
      },
    );

    final resData = response.data;
    final tokenRes = AuthTokenResponse.fromJson(
      resData is Map<String, dynamic> ? resData : <String, dynamic>{},
    );

    // Save tokens if returned
    if (tokenRes.access != null && tokenRes.access!.isNotEmpty) {
      await _client.setTokens(
        accessToken: tokenRes.access!,
        refreshToken: tokenRes.refresh,
      );
    }
    return tokenRes;
  }

  @override
  Future<DriverProfileModel> registerDriver(DriverRegisterRequest request) async {
    final response = await _client.post(
      ApiEndpoints.registerDriver,
      data: request.toJson(),
    );
    final data = response.data;
    return DriverProfileModel.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<CheckApprovalStatusResponse> checkApprovalStatus() async {
    final response = await _client.get(ApiEndpoints.checkApprovalStatus);
    final data = response.data;
    return CheckApprovalStatusResponse.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }

  @override
  Future<dynamic> approveDriver(dynamic driverId) async {
    final response = await _client.post(
      ApiEndpoints.approveDriver(driverId),
      data: {},
    );
    return response.data;
  }

  @override
  Future<dynamic> rejectDriver(dynamic driverId, {String? reason}) async {
    final response = await _client.post(
      ApiEndpoints.rejectDriver(driverId),
      data: reason != null && reason.isNotEmpty ? {'reason': reason} : {},
    );
    return response.data;
  }

  @override
  Future<void> logout() async {
    await _client.clearTokens();
  }

  // ──────────────────────── Driver Management ────────────────────────────
  @override
  Future<DriverProfileModel> getDriverProfile() async {
    final response = await _client.get(ApiEndpoints.drivers);
    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return DriverProfileModel.fromJson(data.first);
    } else if (data is Map<String, dynamic>) {
      return DriverProfileModel.fromJson(data);
    }
    throw Exception('Empty driver profile response');
  }

  @override
  Future<DriverProfileModel> updateDriverProfile(
    dynamic id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put(
      ApiEndpoints.driverById(id),
      data: data,
    );
    return DriverProfileModel.fromJson(response.data);
  }

  @override
  Future<bool> updateLocation({required double lat, required double lng}) async {
    final response = await _client.post(
      ApiEndpoints.updateLocation,
      data: {'lat': lat.toString(), 'lng': lng.toString()},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> toggleOnline(bool isOnline) async {
    final response = await _client.post(
      ApiEndpoints.toggleOnline,
      data: {'is_online': isOnline},
    );
    if (response.data is Map && response.data['is_online'] != null) {
      return response.data['is_online'] == true;
    }
    return isOnline;
  }

  @override
  Future<DriverDashboardModel> getDashboard() async {
    final response = await _client.get(ApiEndpoints.driverDashboard);
    return DriverDashboardModel.fromJson(
      response.data is Map<String, dynamic> ? response.data : <String, dynamic>{},
    );
  }

  // ──────────────────────── Vehicle Management ───────────────────────────
  @override
  Future<List<RideVehicleType>> getRideVehicleTypes() async {
    try {
      final response = await _client.get(
        ApiEndpoints.rideVehicleTypes,
        options: Options(
          extra: {'requiresAuth': false},
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final data = response.data;
      if (response.statusCode == 200 && data is List && data.isNotEmpty) {
        return data
            .map((e) => RideVehicleType.fromJson(
                e is Map<String, dynamic> ? e : <String, dynamic>{}))
            .where((vt) => vt.isActive)
            .toList();
      }
    } catch (_) {
      // Fallback gracefully to API dummy data
    }
    return RideVehicleType.dummyVehicleTypes;
  }

  @override
  Future<List<VehicleApiModel>> getVehicles() async {
    final response = await _client.get(ApiEndpoints.vehicles);
    final data = response.data;
    if (data is List) {
      return data.map((e) => VehicleApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<VehicleApiModel> addVehicle(VehicleApiModel vehicle) async {
    final response = await _client.post(
      ApiEndpoints.vehicles,
      data: vehicle.toJson(),
    );
    return VehicleApiModel.fromJson(response.data);
  }

  @override
  Future<VehicleApiModel> updateVehicle(dynamic id, Map<String, dynamic> data) async {
    final response = await _client.put(
      ApiEndpoints.vehicleById(id),
      data: data,
    );
    return VehicleApiModel.fromJson(response.data);
  }

  @override
  Future<bool> updateVehicleStatus(dynamic id, String status) async {
    final response = await _client.post(
      ApiEndpoints.updateVehicleStatus(id),
      data: {'status': status},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> deleteVehicle(dynamic id) async {
    final response = await _client.delete(ApiEndpoints.vehicleById(id));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ─────────────────────────── Bookings ──────────────────────────────────
  @override
  Future<List<BookingApiModel>> getPendingBookings() async {
    final response = await _client.get(ApiEndpoints.pendingBookings);
    final data = response.data;
    if (data is List) {
      return data.map((e) => BookingApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<bool> acceptBooking(dynamic id) async {
    final response = await _client.post(ApiEndpoints.acceptBooking(id));
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> rejectBooking(dynamic id) async {
    final response = await _client.post(ApiEndpoints.rejectBooking(id));
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<BookingApiModel> updateBookingStatus(dynamic id, String status) async {
    final response = await _client.post(
      ApiEndpoints.updateBookingStatus(id),
      data: {'status': status},
    );
    return BookingApiModel.fromJson(response.data);
  }

  @override
  Future<List<BookingApiModel>> getBookings() async {
    final response = await _client.get(ApiEndpoints.bookings);
    final data = response.data;
    if (data is List) {
      return data.map((e) => BookingApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // ──────────────────────────── Trips ────────────────────────────────────
  @override
  Future<List<TripApiModel>> getTrips() async {
    final response = await _client.get(ApiEndpoints.trips);
    final data = response.data;
    if (data is List) {
      return data.map((e) => TripApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<TripApiModel> updateTripStatus(dynamic id, Map<String, dynamic> data) async {
    final response = await _client.post(
      ApiEndpoints.updateTripStatus(id),
      data: data,
    );
    return TripApiModel.fromJson(response.data);
  }

  @override
  Future<TripApiModel> uploadPod(dynamic id, Map<String, dynamic> podData) async {
    final response = await _client.post(
      ApiEndpoints.uploadPod(id),
      data: podData,
    );
    return TripApiModel.fromJson(response.data);
  }

  // ──────────────────────── Wallet & Earnings ────────────────────────────
  @override
  Future<WalletApiModel> getWallet() async {
    final response = await _client.get(ApiEndpoints.myWallet);
    return WalletApiModel.fromJson(
      response.data is Map<String, dynamic> ? response.data : <String, dynamic>{},
    );
  }

  @override
  Future<bool> withdrawEarnings(double amount) async {
    final response = await _client.post(
      ApiEndpoints.withdrawWallet,
      data: {'amount': amount.toStringAsFixed(2)},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<EarningsSummaryModel> getEarningsSummary() async {
    final response = await _client.get(ApiEndpoints.earningsSummary);
    return EarningsSummaryModel.fromJson(
      response.data is Map<String, dynamic> ? response.data : <String, dynamic>{},
    );
  }

  @override
  Future<List<WalletTransactionModel>> getWalletTransactions() async {
    final response = await _client.get(ApiEndpoints.walletTransactions);
    final data = response.data;
    if (data is List) {
      return data.map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // ──────────────────────── Loads & Quotations ───────────────────────────
  @override
  Future<List<LoadApiModel>> getLoads() async {
    final response = await _client.get(ApiEndpoints.loads);
    final data = response.data;
    if (data is List) {
      return data.map((e) => LoadApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<LoadApiModel>> searchLoads({
    required String pickup,
    required String delivery,
    required String vehicleType,
  }) async {
    final response = await _client.get(
      ApiEndpoints.searchLoads(
        pickup: pickup,
        delivery: delivery,
        vehicleType: vehicleType,
      ),
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => LoadApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<QuotationApiModel> submitQuotation({
    required dynamic loadId,
    required double quotedPrice,
  }) async {
    final response = await _client.post(
      ApiEndpoints.quotations,
      data: {'load': loadId, 'quoted_price': quotedPrice.toStringAsFixed(2)},
    );
    return QuotationApiModel.fromJson(response.data);
  }

  @override
  Future<List<QuotationApiModel>> getQuotations() async {
    final response = await _client.get(ApiEndpoints.quotations);
    final data = response.data;
    if (data is List) {
      return data.map((e) => QuotationApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // ───────────────────────── Notifications ───────────────────────────────
  @override
  Future<List<NotificationApiModel>> getNotifications() async {
    final response = await _client.get(ApiEndpoints.notifications);
    final data = response.data;
    if (data is List) {
      return data.map((e) => NotificationApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<bool> markNotificationRead(dynamic id) async {
    final response = await _client.post(ApiEndpoints.markNotificationRead(id));
    return response.statusCode == 200;
  }

  @override
  Future<bool> markAllNotificationsRead() async {
    final response = await _client.post(ApiEndpoints.markAllNotificationsRead);
    return response.statusCode == 200;
  }
}
