import 'dart:async';

/// Mock authentication backend.
///
/// Every call simulates network latency so the UI can exercise its loading
/// states. Swap the bodies for real API calls when the backend is ready.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// Any OTP typed by the tester is accepted, but this is the "sent" code.
  static const String demoOtp = '123456';

  final Map<String, String> _otpStore = {};

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 1200));

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await _latency();
    if (password.length < 6) {
      return const AuthResult.failure('Incorrect email or password');
    }
    return const AuthResult.success();
  }

  Future<AuthResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    await _latency();
    return const AuthResult.success();
  }

  /// Sends an OTP to [phone]. Returns the code so the demo UI can show it.
  Future<String> sendOtp(String phone) async {
    await _latency();
    _otpStore[phone] = demoOtp;
    return demoOtp;
  }

  Future<AuthResult> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await _latency();
    final expected = _otpStore[phone] ?? demoOtp;
    if (otp != expected) {
      return const AuthResult.failure('The code you entered is incorrect');
    }
    return const AuthResult.success();
  }

  Future<AuthResult> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    await _latency();
    _otpStore.remove(phone);
    return const AuthResult.success();
  }
}

class AuthResult {
  const AuthResult.success()
      : ok = true,
        message = null;

  const AuthResult.failure(this.message) : ok = false;

  final bool ok;
  final String? message;
}
