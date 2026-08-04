import 'package:shared_preferences/shared_preferences.dart';

/// Persists the signed-in session and the buyer's profile.
///
/// Backed by SharedPreferences (NSUserDefaults / SharedPreferences /
/// localStorage), so it survives app restarts on mobile and browser reloads on
/// web. Swap the stored flag for a real auth token once the API is live —
/// and move the token to secure storage before shipping to production.
class SessionStore {
  SessionStore._();

  static final SessionStore instance = SessionStore._();

  static const String _keyLoggedIn = 'machsetu.logged_in';
  static const String _keyName = 'machsetu.user_name';
  static const String _keyEmail = 'machsetu.user_email';
  static const String _keyPhone = 'machsetu.user_phone';
  static const String _keyRole = 'machsetu.user_role';
  static const String _keyCompany = 'machsetu.user_company';
  static const String _keyGstin = 'machsetu.user_gstin';
  static const String _keyAddress = 'machsetu.user_address';
  static const String _keyCity = 'machsetu.user_city';
  static const String _keyState = 'machsetu.user_state';
  static const String _keyZip = 'machsetu.user_zip';

  static const String _keyTwoFactor = 'machsetu.security_2fa';
  static const String _keyBiometrics = 'machsetu.security_biometrics';
  static const String _keyLoginAlerts = 'machsetu.security_login_alerts';

  /// SharedPreferences keeps its own in-memory instance after the first load,
  /// so this stays cheap without a second cache layer here.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<void> save({String? name, String? email, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    if (name != null) await prefs.setString(_keyName, name);
    if (email != null) await prefs.setString(_keyEmail, email);
    if (phone != null) await prefs.setString(_keyPhone, phone);
  }

  Future<SessionUser> user() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionUser(
      name: prefs.getString(_keyName) ?? '',
      email: prefs.getString(_keyEmail) ?? '',
      phone: prefs.getString(_keyPhone) ?? '',
      role: prefs.getString(_keyRole) ?? '',
      company: prefs.getString(_keyCompany) ?? '',
      gstin: prefs.getString(_keyGstin) ?? '',
      address: prefs.getString(_keyAddress) ?? '',
      city: prefs.getString(_keyCity) ?? '',
      state: prefs.getString(_keyState) ?? '',
      zip: prefs.getString(_keyZip) ?? '',
    );
  }

  /// Writes every profile field at once from the edit form.
  Future<void> saveProfile(SessionUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, user.name);
    await prefs.setString(_keyEmail, user.email);
    await prefs.setString(_keyPhone, user.phone);
    await prefs.setString(_keyRole, user.role);
    await prefs.setString(_keyCompany, user.company);
    await prefs.setString(_keyGstin, user.gstin);
    await prefs.setString(_keyAddress, user.address);
    await prefs.setString(_keyCity, user.city);
    await prefs.setString(_keyState, user.state);
    await prefs.setString(_keyZip, user.zip);
  }

  Future<SecuritySettings> security() async {
    final prefs = await SharedPreferences.getInstance();
    return SecuritySettings(
      twoFactor: prefs.getBool(_keyTwoFactor) ?? false,
      biometrics: prefs.getBool(_keyBiometrics) ?? false,
      loginAlerts: prefs.getBool(_keyLoginAlerts) ?? true,
    );
  }

  Future<void> saveSecurity(SecuritySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTwoFactor, settings.twoFactor);
    await prefs.setBool(_keyBiometrics, settings.biometrics);
    await prefs.setBool(_keyLoginAlerts, settings.loginAlerts);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      _keyLoggedIn,
      _keyName,
      _keyEmail,
      _keyPhone,
      _keyRole,
      _keyCompany,
      _keyGstin,
      _keyAddress,
      _keyCity,
      _keyState,
      _keyZip,
    ]) {
      await prefs.remove(key);
    }
  }
}

class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    required this.phone,
    this.role = '',
    this.company = '',
    this.gstin = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zip = '',
  });

  final String name;
  final String email;
  final String phone;
  final String role;
  final String company;
  final String gstin;
  final String address;
  final String city;
  final String state;
  final String zip;

  SessionUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? company,
    String? gstin,
    String? address,
    String? city,
    String? state,
    String? zip,
  }) {
    return SessionUser(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      company: company ?? this.company,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
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
