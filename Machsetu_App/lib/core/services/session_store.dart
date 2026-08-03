import 'package:shared_preferences/shared_preferences.dart';

/// Persists the signed-in session so reopening the app skips the login screen.
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
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
  }
}

class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

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
