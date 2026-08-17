import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Result of an API call — either data, or a message safe to show the user.
class ApiResult {
  const ApiResult.success(this.data)
    : ok = true,
      message = null;

  const ApiResult.failure(this.message) : ok = false, data = const {};

  final bool ok;
  final Map<String, dynamic> data;
  final String? message;
}

/// Thin HTTP client for the MachSetu admin API.
///
/// The base URL can be overridden at build time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:3000
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// Android emulators reach the host machine on 10.0.2.2, not localhost.
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {
      // Platform is unavailable on some targets; fall through to localhost.
    }
    return 'http://localhost:3000';
  }

  static const Duration _timeout = Duration(seconds: 20);

  Future<ApiResult> post(
    String path, {
    Map<String, dynamic> body = const {},
    String? token,
  }) => _send('POST', path, body: body, token: token);

  Future<ApiResult> put(
    String path, {
    Map<String, dynamic> body = const {},
    String? token,
  }) => _send('PUT', path, body: body, token: token);

  Future<ApiResult> get(String path, {String? token}) =>
      _send('GET', path, token: token);

  Future<ApiResult> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final http.Response response;
      switch (method) {
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(_timeout);
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(_timeout);
        default:
          response = await http.get(uri, headers: headers).timeout(_timeout);
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const ApiResult.failure('Unexpected response from the server');
      }
      if (decoded['ok'] == true) {
        return ApiResult.success(decoded);
      }
      return ApiResult.failure(
        decoded['message']?.toString() ?? 'Request failed',
      );
    } catch (error) {
      debugPrint('API $method $path failed: $error');
      return const ApiResult.failure(
        'Could not reach the server. Check your connection and try again.',
      );
    }
  }
}
