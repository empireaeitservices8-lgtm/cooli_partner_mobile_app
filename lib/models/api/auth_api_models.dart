library;

/// Authentication & Driver Profile API Models matching CoolieDriver Backend

class SendOtpRequest {
  final String mobile;
  final String otpType; // e.g. 'login', 'register'

  SendOtpRequest({required this.mobile, this.otpType = 'login'});

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'otp_type': otpType,
      };
}

class SendOtpResponse {
  final bool success;
  final String message;
  final dynamic data;

  SendOtpResponse({required this.success, required this.message, this.data});

  factory SendOtpResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return SendOtpResponse(
        success: json['success'] ?? true,
        message: json['message'] ?? json['detail'] ?? 'OTP sent successfully',
        data: json,
      );
    }
    return SendOtpResponse(success: true, message: json.toString(), data: json);
  }
}

class VerifyOtpRequest {
  final String mobile;
  final String otp;
  final String otpType;

  VerifyOtpRequest({
    required this.mobile,
    required this.otp,
    this.otpType = 'login',
  });

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'otp': otp,
        'otp_type': otpType,
      };
}

class UserModel {
  final int? id;
  final String username;
  final String email;
  final String mobile;
  final String userType;
  final String? profilePhoto;
  final String? address;
  final bool isVerified;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.mobile,
    this.userType = 'driver',
    this.profilePhoto,
    this.address,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? 'driver',
      profilePhoto: json['profile_photo']?.toString(),
      address: json['address']?.toString(),
      isVerified: json['is_verified'] == true,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'mobile': mobile,
        'user_type': userType,
        'profile_photo': profilePhoto,
        'address': address,
        'is_verified': isVerified,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class AuthTokenResponse {
  final String? access;
  final String? refresh;
  final String? token;
  final int? userId;
  final String? message;
  final bool isNewUser;
  final String? approvalStatus;
  final String? redirectTo;
  final UserModel? user;
  final Map<String, dynamic>? rawData;

  AuthTokenResponse({
    this.access,
    this.refresh,
    this.token,
    this.userId,
    this.message,
    this.isNewUser = false,
    this.approvalStatus,
    this.redirectTo,
    this.user,
    this.rawData,
  });

  String get validToken => access ?? token ?? '';
  bool get isApproved =>
      approvalStatus == 'approved' || redirectTo == 'home';
  bool get isPending =>
      approvalStatus == 'pending' ||
      (redirectTo == 'pending' && approvalStatus != 'rejected');
  bool get isRejected => approvalStatus == 'rejected';

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final user =
        userJson is Map<String, dynamic> ? UserModel.fromJson(userJson) : null;
    final isNew = json['is_new_user'] == true;
    final approval = json['approval_status']?.toString().toLowerCase();
    final redirect = json['redirect_to']?.toString().toLowerCase();

    return AuthTokenResponse(
      access: json['access'] ?? json['token'] ?? json['access_token'],
      refresh: json['refresh'] ?? json['refresh_token'],
      token: json['token'] ?? json['access'],
      userId: user?.id ??
          (json['user_id'] is int
              ? json['user_id']
              : int.tryParse(json['user_id']?.toString() ?? '')),
      message: json['message'] ?? json['detail'],
      isNewUser: isNew,
      approvalStatus: approval,
      redirectTo: redirect,
      user: user,
      rawData: json,
    );
  }
}

class CheckApprovalStatusResponse {
  final String approvalStatus;
  final String redirectTo;
  final UserModel? user;
  final DriverProfileModel? driver;
  final Map<String, dynamic>? rawData;

  CheckApprovalStatusResponse({
    required this.approvalStatus,
    required this.redirectTo,
    this.user,
    this.driver,
    this.rawData,
  });

  bool get isApproved =>
      approvalStatus == 'approved' || redirectTo == 'home';
  bool get isPending =>
      approvalStatus == 'pending' ||
      (redirectTo == 'pending' && approvalStatus != 'rejected');
  bool get isRejected => approvalStatus == 'rejected';

  factory CheckApprovalStatusResponse.fromJson(Map<String, dynamic> json) {
    return CheckApprovalStatusResponse(
      approvalStatus:
          json['approval_status']?.toString().toLowerCase() ?? 'pending',
      redirectTo: json['redirect_to']?.toString().toLowerCase() ?? 'pending',
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
      driver: json['driver'] is Map<String, dynamic>
          ? DriverProfileModel.fromJson(json['driver'])
          : null,
      rawData: json,
    );
  }
}

class DriverRegisterRequest {
  final String username;
  final String email;
  final String mobile;
  final String partnerType; // rider, parcel_transportation, truck_driver, fleet_owner
  final String drivingLicence;
  final String idProof;
  final String bankAccountNumber;
  final String bankName;
  final String ifscCode;

  DriverRegisterRequest({
    required this.username,
    required this.email,
    required this.mobile,
    this.partnerType = 'rider',
    this.drivingLicence = 'driving_licence_doc',
    this.idProof = 'id_proof_doc',
    this.bankAccountNumber = '',
    this.bankName = '',
    this.ifscCode = '',
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'mobile': mobile,
        'partner_type': partnerType,
        'driving_licence': drivingLicence,
        'id_proof': idProof,
        'bank_account_number': bankAccountNumber,
        'bank_name': bankName,
        'ifsc_code': ifscCode,
      };
}

class DriverProfileModel {
  final dynamic id;
  final String username;
  final String email;
  final String mobile;
  final String? partnerType;
  final String? verificationStatus;
  final String? drivingLicence;
  final String? idProof;
  final String? bankAccountNumber;
  final String? bankName;
  final String? ifscCode;
  final bool isOnline;
  final double? lat;
  final double? lng;
  final double rating;
  final int totalTrips;

  DriverProfileModel({
    this.id,
    required this.username,
    required this.email,
    required this.mobile,
    this.partnerType,
    this.verificationStatus,
    this.drivingLicence,
    this.idProof,
    this.bankAccountNumber,
    this.bankName,
    this.ifscCode,
    this.isOnline = false,
    this.lat,
    this.lng,
    this.rating = 0.0,
    this.totalTrips = 0,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    final userPart = json['user'] is Map<String, dynamic> ? json['user'] : null;
    return DriverProfileModel(
      id: json['id'],
      username: json['username'] ??
          userPart?['username'] ??
          json['name'] ??
          '',
      email: json['email'] ?? userPart?['email'] ?? '',
      mobile: json['mobile'] ??
          userPart?['mobile'] ??
          json['phone'] ??
          '',
      partnerType: json['partner_type']?.toString(),
      verificationStatus: json['verification_status']?.toString(),
      drivingLicence: json['driving_licence']?.toString(),
      idProof: json['id_proof']?.toString(),
      bankAccountNumber: json['bank_account_number']?.toString(),
      bankName: json['bank_name']?.toString(),
      ifscCode: json['ifsc_code']?.toString(),
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      lat: json['current_location_lat'] != null
          ? double.tryParse(json['current_location_lat'].toString())
          : (json['lat'] != null
              ? double.tryParse(json['lat'].toString())
              : null),
      lng: json['current_location_lng'] != null
          ? double.tryParse(json['current_location_lng'].toString())
          : (json['lng'] != null
              ? double.tryParse(json['lng'].toString())
              : null),
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      totalTrips:
          int.tryParse(json['total_trips']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'mobile': mobile,
        'partner_type': partnerType,
        'verification_status': verificationStatus,
        'driving_licence': drivingLicence,
        'id_proof': idProof,
        'bank_account_number': bankAccountNumber,
        'bank_name': bankName,
        'ifsc_code': ifscCode,
        'is_online': isOnline,
        'lat': lat,
        'lng': lng,
        'rating': rating,
        'total_trips': totalTrips,
      };
}


class DriverDashboardModel {
  final int totalTrips;
  final double totalEarnings;
  final double rating;
  final bool isOnline;
  final int pendingRequests;
  final Map<String, dynamic>? raw;

  DriverDashboardModel({
    this.totalTrips = 0,
    this.totalEarnings = 0.0,
    this.rating = 5.0,
    this.isOnline = false,
    this.pendingRequests = 0,
    this.raw,
  });

  factory DriverDashboardModel.fromJson(Map<String, dynamic> json) {
    return DriverDashboardModel(
      totalTrips: int.tryParse(json['total_trips']?.toString() ?? '0') ??
          int.tryParse(json['completed_trips']?.toString() ?? '0') ??
          0,
      totalEarnings: double.tryParse(json['total_earnings']?.toString() ?? '0.0') ??
          double.tryParse(json['earnings']?.toString() ?? '0.0') ??
          0.0,
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      pendingRequests: int.tryParse(json['pending_requests']?.toString() ?? '0') ??
          int.tryParse(json['pending_count']?.toString() ?? '0') ??
          0,
      raw: json,
    );
  }
}
