import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import 'api_exceptions.dart';
import 'api_logger.dart';

/// Centralized Dio Network Client with Interceptors, Token Refresh, and Console Logging
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  static const String _prefAccessToken = 'cooli_access_token';
  static const String _prefRefreshToken = 'cooli_refresh_token';

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1. Auth Interceptor: attaches Bearer token & handles 401 Refresh
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          // Check if this endpoint should NOT pass Bearer token
          final isPublic = options.path == ApiEndpoints.rideVehicleTypes ||
              options.path == ApiEndpoints.sendOtp ||
              options.path == ApiEndpoints.verifyOtp ||
              options.path == ApiEndpoints.refreshToken ||
              options.extra['requiresAuth'] == false ||
              options.headers['no-auth'] == true;

          if (isPublic) {
            options.headers.remove('Authorization');
            options.headers.remove('no-auth');
          } else if (_accessToken != null &&
              _accessToken!.isNotEmpty &&
              !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 Unauthorized by attempting token refresh
          if (error.response?.statusCode == 401 &&
              _refreshToken != null &&
              _refreshToken!.isNotEmpty &&
              error.requestOptions.path != ApiEndpoints.refreshToken) {
            try {
              final newAccessToken = await _refreshAccessToken();
              if (newAccessToken != null) {
                // Retry the original request with the new token
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              // Refresh failed, proceed with error
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 2. High-visibility Console Logger Interceptor
    dio.interceptors.add(ApiConsoleLogger(enableConsoleLog: true));

    // Load persisted tokens on startup
    _loadTokensFromStorage();
  }

  Future<void> _loadTokensFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_prefAccessToken);
      _refreshToken = prefs.getString(_prefRefreshToken);
    } catch (_) {}
  }

  Future<void> setTokens({required String accessToken, String? refreshToken}) async {
    _accessToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefAccessToken, accessToken);
      if (refreshToken != null) {
        await prefs.setString(_prefRefreshToken, refreshToken);
      }
    } catch (_) {}
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefAccessToken);
      await prefs.remove(_prefRefreshToken);
    } catch (_) {}
  }

  Future<String?> _refreshAccessToken() async {
    try {
      // Use a separate Dio instance without interceptors to avoid looping
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          headers: {'Content-Type': 'application/json'},
        ),
      );
      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh': _refreshToken},
      );
      if (response.statusCode == 200 && response.data != null) {
        final newAccess = response.data['access'] ?? response.data['token'];
        if (newAccess != null) {
          _accessToken = newAccess.toString();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefAccessToken, _accessToken!);
          return _accessToken;
        }
      }
    } catch (_) {
      await clearTokens();
    }
    return null;
  }

  // Generic Request Wrappers with automatic ApiException handling
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
