import 'package:dio/dio.dart';

/// Standardized API Exception for COOLI Partner
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final String? endpoint;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.endpoint,
  });

  factory ApiException.fromDioError(DioException dioError) {
    final endpoint = dioError.requestOptions.path;
    final statusCode = dioError.response?.statusCode;
    final responseData = dioError.response?.data;

    String extractMessage(dynamic data) {
      if (data == null) return '';
      if (data is String) return data;
      if (data is Map) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        // Check for field-level errors (e.g., {"mobile": ["Invalid phone number"]})
        final buffer = StringBuffer();
        data.forEach((key, value) {
          if (value is List) {
            buffer.writeln('$key: ${value.join(', ')}');
          } else {
            buffer.writeln('$key: $value');
          }
        });
        final joined = buffer.toString().trim();
        if (joined.isNotEmpty) return joined;
      }
      return data.toString();
    }

    final backendMsg = extractMessage(responseData);

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout with the server. Please check your internet connection.',
          statusCode: statusCode,
          endpoint: endpoint,
          data: responseData,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Send timeout. Failed to transmit data within time limit.',
          statusCode: statusCode,
          endpoint: endpoint,
          data: responseData,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Receive timeout. Server took too long to respond.',
          statusCode: statusCode,
          endpoint: endpoint,
          data: responseData,
        );
      case DioExceptionType.badResponse:
        final status = statusCode ?? 0;
        if (backendMsg.isNotEmpty) {
          return ApiException(
            message: backendMsg,
            statusCode: status,
            endpoint: endpoint,
            data: responseData,
          );
        }
        if (status == 400) {
          return ApiException(
            message: 'Bad Request. Please verify your inputs.',
            statusCode: status,
            endpoint: endpoint,
            data: responseData,
          );
        } else if (status == 401) {
          return ApiException(
            message: 'Unauthorized. Please login again.',
            statusCode: status,
            endpoint: endpoint,
            data: responseData,
          );
        } else if (status == 403) {
          return ApiException(
            message: 'Forbidden. You do not have permission for this action.',
            statusCode: status,
            endpoint: endpoint,
            data: responseData,
          );
        } else if (status == 404) {
          return ApiException(
            message: 'Resource not found on server (404).',
            statusCode: status,
            endpoint: endpoint,
            data: responseData,
          );
        } else if (status >= 500) {
          return ApiException(
            message: 'Server error ($status). Please try again later.',
            statusCode: status,
            endpoint: endpoint,
            data: responseData,
          );
        }
        return ApiException(
          message: 'Received unexpected response: status code $status',
          statusCode: status,
          endpoint: endpoint,
          data: responseData,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: statusCode,
          endpoint: endpoint,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Network connection error. Check your internet connection.',
          statusCode: statusCode,
          endpoint: endpoint,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: backendMsg.isNotEmpty
              ? backendMsg
              : (dioError.message ?? 'An unexpected network error occurred.'),
          statusCode: statusCode,
          endpoint: endpoint,
          data: responseData,
        );
    }
  }

  @override
  String toString() => message;
}
