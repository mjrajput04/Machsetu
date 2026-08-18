import 'dart:convert';

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

/// Thin HTTP client for the MachSetu API.
///
/// Every build — debug or release — talks to the live marketplace, so an APK
/// handed to anyone works the moment it is installed. Point it somewhere else
/// only when you mean to:
///
///   flutter run --dart-define=API_BASE_URL=http://localhost:3000
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000   (emulator)
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// The deployed marketplace.
  static const String production = 'https://machsetu.com';

  static String get baseUrl =>
      _override.isEmpty ? production : _override;

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
