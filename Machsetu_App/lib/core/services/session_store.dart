import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

/// Persists the signed-in session and the buyer's profile.
///
/// The auth token and the last known profile are cached locally so the app
/// opens straight to the marketplace, then refreshed from the API in the
/// background.
class SessionStore {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  static const String _keyToken = 'machsetu.token';
  static const String _keyUser = 'machsetu.user';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_keyToken) ?? '').isNotEmpty;
  }

  Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyToken);
    return (value == null || value.isEmpty) ? null : value;
  }

  /// Stores the token and profile returned by login or OTP verification.
  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  /// Cached profile. Pass `refresh: true` to pull the latest from the API.
  Future<SessionUser> user({bool refresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (refresh) {
      final auth = prefs.getString(_keyToken);
      if (auth != null && auth.isNotEmpty) {
        final result = await ApiClient.instance.get('/api/profile', token: auth);
        if (result.ok) {
          final fresh = result.data['user'] as Map<String, dynamic>;
          await prefs.setString(_keyUser, jsonEncode(fresh));
          return SessionUser.fromJson(fresh);
        }
      }
    }

    final raw = prefs.getString(_keyUser);
    if (raw == null || raw.isEmpty) return const SessionUser.empty();
    try {
      return SessionUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const SessionUser.empty();
    }
  }

  /// Writes every profile field at once from the edit form.
  Future<String?> saveProfile(SessionUser user) async {
    final auth = await token();
    if (auth == null) return 'Please sign in again';

    final result = await ApiClient.instance.put(
      '/api/profile',
      token: auth,
      body: user.toJson(),
    );
    if (!result.ok) return result.message;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(result.data['user']));
    return null;
  }

  Future<SecuritySettings> security() async {
    final current = await user();
    return SecuritySettings(
      twoFactor: current.twoFactor,
      biometrics: current.biometrics,
      loginAlerts: current.loginAlerts,
    );
  }

  Future<String?> saveSecurity(SecuritySettings settings) async {
    final auth = await token();
    if (auth == null) return 'Please sign in again';

    final result = await ApiClient.instance.put(
      '/api/security',
      token: auth,
      body: {
        'twoFactor': settings.twoFactor,
        'biometrics': settings.biometrics,
        'loginAlerts': settings.loginAlerts,
      },
    );
    if (!result.ok) return result.message;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(result.data['user']));
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}

class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    required this.phone,
    this.avatar = '',
    this.role = '',
    this.company = '',
    this.gstin = '',
    this.pan = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zip = '',
    this.twoFactor = false,
    this.biometrics = false,
    this.loginAlerts = true,
  });

  const SessionUser.empty()
    : name = '',
      email = '',
      phone = '',
      avatar = '',
      role = '',
      company = '',
      gstin = '',
      pan = '',
      address = '',
      city = '',
      state = '',
      zip = '',
      twoFactor = false,
      biometrics = false,
      loginAlerts = true;

  factory SessionUser.fromJson(Map<String, dynamic> json) {
    String text(String key) => json[key]?.toString() ?? '';
    bool flag(String key, {bool fallback = false}) =>
        json[key] is bool ? json[key] as bool : fallback;

    return SessionUser(
      name: text('name'),
      email: text('email'),
      phone: text('phone'),
      avatar: text('avatar'),
      // The API calls it `designation`; the app has always called it `role`.
      role: text('designation'),
      company: text('company'),
      gstin: text('gstin'),
      pan: text('pan'),
      address: text('address'),
      city: text('city'),
      state: text('state'),
      zip: text('zip'),
      twoFactor: flag('twoFactor'),
      biometrics: flag('biometrics'),
      loginAlerts: flag('loginAlerts', fallback: true),
    );
  }

  final String name;
  final String email;
  final String phone;

  /// Uploaded profile photo path; empty until they pick one.
  final String avatar;

  /// Job title, e.g. "Senior Procurement Director".
  final String role;
  final String company;
  final String gstin;
  final String pan;
  final String address;
  final String city;
  final String state;
  final String zip;

  final bool twoFactor;
  final bool biometrics;
  final bool loginAlerts;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'avatar': avatar,
    'designation': role,
    'company': company,
    'gstin': gstin,
    'pan': pan,
    'address': address,
    'city': city,
    'state': state,
    'zip': zip,
  };

  SessionUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    String? company,
    String? gstin,
    String? pan,
    String? address,
    String? city,
    String? state,
    String? zip,
  }) {
    return SessionUser(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      company: company ?? this.company,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      twoFactor: twoFactor,
      biometrics: biometrics,
      loginAlerts: loginAlerts,
    );
  }

  /// Two-letter monogram for the app-bar avatar — "Rajesh Kumar" becomes "RK".
  /// Empty when no name is stored, so callers can pick their own placeholder.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class SecuritySettings {
  const SecuritySettings({
    required this.twoFactor,
    required this.biometrics,
    required this.loginAlerts,
  });

  final bool twoFactor;
  final bool biometrics;
  final bool loginAlerts;

  SecuritySettings copyWith({
    bool? twoFactor,
    bool? biometrics,
    bool? loginAlerts,
  }) {
    return SecuritySettings(
      twoFactor: twoFactor ?? this.twoFactor,
      biometrics: biometrics ?? this.biometrics,
      loginAlerts: loginAlerts ?? this.loginAlerts,
    );
  }
}
