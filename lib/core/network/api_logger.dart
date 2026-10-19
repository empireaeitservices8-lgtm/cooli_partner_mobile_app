import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Representation of a single logged API call event
class ApiLogEntry {
  final String id;
  final DateTime timestamp;
  final String type; // 'REQUEST', 'RESPONSE', 'ERROR'
  final String method;
  final String url;
  final int? statusCode;
  final int? durationMs;
  final dynamic headers;
  final dynamic body;
  final String? errorMessage;

  ApiLogEntry({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.method,
    required this.url,
    this.statusCode,
    this.durationMs,
    this.headers,
    this.body,
    this.errorMessage,
  });

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get isError => type == 'ERROR' || (statusCode != null && statusCode! >= 400);
}

/// Global stream/list of in-memory logs so the app UI can display them live
class ApiLogBuffer {
  static final List<ApiLogEntry> _logs = [];
  static final ValueNotifier<List<ApiLogEntry>> logsNotifier = ValueNotifier<List<ApiLogEntry>>([]);

  static List<ApiLogEntry> get logs => List.unmodifiable(_logs);

  static void addLog(ApiLogEntry entry) {
    _logs.insert(0, entry);
    if (_logs.length > 200) {
      _logs.removeLast();
    }
    logsNotifier.value = List.from(_logs);
  }

  static void clear() {
    _logs.clear();
    logsNotifier.value = [];
  }
}

/// A comprehensive, high-visibility Dio Console Logger Interceptor
/// Formats and logs all API calls, responses, timings, and errors to the console
class ApiConsoleLogger extends Interceptor {
  final bool enableConsoleLog;

  ApiConsoleLogger({this.enableConsoleLog = true});

  static const String _lineSeparator =
      '──────────────────────────────────────────────────────────────────────────────';

  String _formatJson(dynamic data) {
    if (data == null) return 'null';
    try {
      if (data is String) {
        final parsed = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(parsed);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['request_start_time'] = DateTime.now().millisecondsSinceEpoch;

    final url = options.uri.toString();
    final method = options.method.toUpperCase();

    // Store in live buffer
    ApiLogBuffer.addLog(
      ApiLogEntry(
        id: '${options.extra['request_start_time']}_req',
        timestamp: DateTime.now(),
        type: 'REQUEST',
        method: method,
        url: url,
        headers: options.headers,
        body: options.data,
      ),
    );

    if (enableConsoleLog) {
      debugPrint('\n┌$_lineSeparator');
      debugPrint('│ 🚀 [DIO REQUEST] ── $method $url');
      debugPrint('├$_lineSeparator');

      if (options.queryParameters.isNotEmpty) {
        debugPrint('│ 🔍 Query Params:');
        debugPrint('│   ${_formatJson(options.queryParameters).replaceAll('\n', '\n│   ')}');
      }

      if (options.headers.isNotEmpty) {
        final safeHeaders = Map<String, dynamic>.from(options.headers);
        if (safeHeaders.containsKey('Authorization')) {
          final auth = safeHeaders['Authorization'].toString();
          if (auth.length > 25) {
            safeHeaders['Authorization'] = '${auth.substring(0, 15)}...${auth.substring(auth.length - 8)}';
          }
        }
        debugPrint('│ 📋 Headers:');
        debugPrint('│   ${_formatJson(safeHeaders).replaceAll('\n', '\n│   ')}');
      }

      if (options.data != null) {
        debugPrint('│ 📦 Request Payload:');
        debugPrint('│   ${_formatJson(options.data).replaceAll('\n', '\n│   ')}');
      } else {
        debugPrint('│ 📦 Request Payload: <EMPTY>');
      }

      debugPrint('└$_lineSeparator\n');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['request_start_time'] as int?;
    final durationMs = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;

    final method = response.requestOptions.method.toUpperCase();
    final url = response.requestOptions.uri.toString();
    final statusCode = response.statusCode ?? 200;

    // Store in live buffer
    ApiLogBuffer.addLog(
      ApiLogEntry(
        id: '${DateTime.now().millisecondsSinceEpoch}_res',
        timestamp: DateTime.now(),
        type: 'RESPONSE',
        method: method,
        url: url,
        statusCode: statusCode,
        durationMs: durationMs,
        body: response.data,
      ),
    );

    if (enableConsoleLog) {
      final statusIcon = (statusCode >= 200 && statusCode < 300) ? '✅' : '⚠️';

      debugPrint('\n┌$_lineSeparator');
      debugPrint(
        '│ $statusIcon [DIO RESPONSE: $statusCode] ── $method $url (${durationMs ?? '?'} ms)',
      );
      debugPrint('├$_lineSeparator');

      if (response.data != null) {
        debugPrint('│ 📥 Response Body:');
        debugPrint('│   ${_formatJson(response.data).replaceAll('\n', '\n│   ')}');
      } else {
        debugPrint('│ 📥 Response Body: <EMPTY>');
      }

      debugPrint('└$_lineSeparator\n');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['request_start_time'] as int?;
    final durationMs = startTime != null
        ? DateTime.now().millisecondsSinceEpoch - startTime
        : null;

    final method = err.requestOptions.method.toUpperCase();
    final url = err.requestOptions.uri.toString();
    final statusCode = err.response?.statusCode;

    // Store in live buffer
    ApiLogBuffer.addLog(
      ApiLogEntry(
        id: '${DateTime.now().millisecondsSinceEpoch}_err',
        timestamp: DateTime.now(),
        type: 'ERROR',
        method: method,
        url: url,
        statusCode: statusCode,
        durationMs: durationMs,
        body: err.response?.data,
        errorMessage: err.message,
      ),
    );

    if (enableConsoleLog) {
      debugPrint('\n┌$_lineSeparator');
      debugPrint(
        '│ ❌ [DIO ERROR: ${statusCode ?? 'NETWORK/TIMEOUT'}] ── $method $url (${durationMs ?? '?'} ms)',
      );
      debugPrint('├$_lineSeparator');
      debugPrint('│ ❗ Error Type: ${err.type}');
      debugPrint('│ ❗ Message   : ${err.message}');

      if (err.response?.data != null) {
        final dataStr = err.response!.data.toString().trim();
        final isHtml = dataStr.startsWith('<!DOCTYPE') || dataStr.startsWith('<html') || dataStr.contains('</html>');
        debugPrint('│ 📥 Error Response:');
        if (isHtml) {
          debugPrint('│   [HTML ${statusCode ?? 404} Page - Endpoint route not registered in Django backend URLconf]');
        } else {
          debugPrint('│   ${_formatJson(err.response?.data).replaceAll('\n', '\n│   ')}');
        }
      }

      debugPrint('└$_lineSeparator\n');
    }

    super.onError(err, handler);
  }
}
