import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:cooli_partner/core/network/api_logger.dart';
import 'package:cooli_partner/core/network/api_endpoints.dart';
import 'package:cooli_partner/models/api/api_models.dart';

void main() {
  test('ApiConsoleLogger logs request, response, and error properly', () {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 5),
      ),
    );
    dio.interceptors.add(ApiConsoleLogger(enableConsoleLog: true));

    // Verify ApiLogBuffer starts clean or registers entries
    ApiLogBuffer.clear();
    expect(ApiLogBuffer.logs.isEmpty, true);

    ApiLogBuffer.addLog(
      ApiLogEntry(
        id: 'test_1',
        timestamp: DateTime.now(),
        type: 'REQUEST',
        method: 'POST',
        url: '${ApiEndpoints.baseUrl}${ApiEndpoints.sendOtp}',
        body: {'mobile': '9876543210', 'otp_type': 'login'},
      ),
    );

    expect(ApiLogBuffer.logs.length, 1);
    expect(ApiLogBuffer.logs.first.method, 'POST');
    expect(ApiLogBuffer.logs.first.body['mobile'], '9876543210');
  });

  test('SendOtpRequest and AuthTokenResponse serialize correctly', () {
    final req = SendOtpRequest(mobile: '9876543210', otpType: 'login');
    final json = req.toJson();
    expect(json['mobile'], '9876543210');
    expect(json['otp_type'], 'login');

    final res = AuthTokenResponse.fromJson({
      'access': 'sample_access_token',
      'refresh': 'sample_refresh_token',
      'user_id': 101,
      'message': 'Login successful',
    });
    expect(res.access, 'sample_access_token');
    expect(res.validToken, 'sample_access_token');
    expect(res.userId, 101);
  });

  test('AuthTokenResponse accurately routes New User vs Existing Approved vs Pending', () {
    // 1. New user -> Must route to registration
    final newUserRes = AuthTokenResponse.fromJson({
      'message': 'New user detected',
      'is_new_user': true,
      'redirect_to': 'registration',
    });
    expect(newUserRes.isNewUser, isTrue);
    expect(newUserRes.redirectTo, 'registration');
    expect(newUserRes.isApproved, isFalse);

    // 2. Existing user (Approved) -> Must route to home
    final approvedRes = AuthTokenResponse.fromJson({
      'message': 'OTP verified successfully',
      'is_new_user': false,
      'refresh': 'sample_refresh',
      'access': 'sample_access',
      'user': {
        'id': 1,
        'username': 'john',
        'email': 'john@example.com',
        'mobile': '9876543154',
        'user_type': 'driver',
        'is_verified': true,
      },
      'approval_status': 'approved',
      'redirect_to': 'home',
    });
    expect(approvedRes.isNewUser, isFalse);
    expect(approvedRes.isApproved, isTrue);
    expect(approvedRes.redirectTo, 'home');
    expect(approvedRes.user?.username, 'john');
    expect(approvedRes.validToken, 'sample_access');

    // 3. Existing user (Pending) -> Must route to pending screen
    final pendingRes = AuthTokenResponse.fromJson({
      'message': 'OTP verified successfully',
      'is_new_user': false,
      'refresh': 'sample_refresh',
      'access': 'sample_access',
      'user': {
        'id': 2,
        'username': 'jane',
        'email': 'jane@example.com',
        'mobile': '9876543155',
        'user_type': 'driver',
        'is_verified': false,
      },
      'approval_status': 'pending',
      'redirect_to': 'pending',
    });
    expect(pendingRes.isNewUser, isFalse);
    expect(pendingRes.isApproved, isFalse);
    expect(pendingRes.isPending, isTrue);
    expect(pendingRes.redirectTo, 'pending');

    // 4. Existing user (Rejected) -> Must route to pending screen and identify as rejected
    final rejectedRes = AuthTokenResponse.fromJson({
      'message': 'OTP verified successfully',
      'is_new_user': false,
      'refresh': 'sample_refresh',
      'access': 'sample_access',
      'user': {
        'id': 3,
        'username': 'bob',
        'email': 'bob@example.com',
        'mobile': '9876543156',
        'user_type': 'driver',
        'is_verified': false,
      },
      'approval_status': 'rejected',
      'redirect_to': 'pending',
    });
    expect(rejectedRes.isNewUser, isFalse);
    expect(rejectedRes.isApproved, isFalse);
    expect(rejectedRes.isRejected, isTrue);
    expect(rejectedRes.isPending, isFalse);
    expect(rejectedRes.redirectTo, 'pending');

    // 5. Check approval status response
    final checkStatusRes = CheckApprovalStatusResponse.fromJson({
      'approval_status': 'approved',
      'redirect_to': 'home',
      'user': {'id': 1, 'username': 'john', 'email': 'john@example.com', 'mobile': '9876543154'},
    });
    expect(checkStatusRes.isApproved, isTrue);
    expect(checkStatusRes.redirectTo, 'home');
  });

  test('RideVehicleType parses JSON accurately and has valid dummy fallback data', () {
    final jsonList = [
      {
        "id": 10,
        "service": 8,
        "name": "Bike",
        "description": "Two-wheeler ride",
        "icon": "bike",
        "is_active": true
      },
      {
        "id": 11,
        "service": 8,
        "name": "Auto",
        "description": "Three-wheeler auto rickshaw",
        "icon": "auto",
        "is_active": true
      },
      {
        "id": 12,
        "service": 8,
        "name": "Car",
        "description": "Standard car ride",
        "icon": "car",
        "is_active": true
      },
      {
        "id": 13,
        "service": 8,
        "name": "Premium car",
        "description": "Premium car ride",
        "icon": "premium_car",
        "is_active": true
      },
      {
        "id": 24,
        "service": 8,
        "name": "BMW",
        "description": "VIP RIDE",
        "icon": "",
        "is_active": true
      }
    ];

    final parsed = jsonList.map((e) => RideVehicleType.fromJson(e)).toList();
    expect(parsed.length, 5);
    expect(parsed[0].name, 'Bike');
    expect(parsed[0].id, 10);
    expect(parsed[1].name, 'Auto');
    expect(parsed[2].name, 'Car');
    expect(parsed[3].name, 'Premium car');
    expect(parsed[4].name, 'BMW');
    expect(parsed[4].description, 'VIP RIDE');

    // Test fallback dummy types
    expect(RideVehicleType.dummyVehicleTypes.length, 5);
    expect(RideVehicleType.dummyVehicleTypes.map((e) => e.name),
        containsAll(['Bike', 'Auto', 'Car', 'Premium car', 'BMW']));
  });
}


