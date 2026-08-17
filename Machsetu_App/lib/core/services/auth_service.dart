import 'api_client.dart';
import 'session_store.dart';

/// Authentication against the MachSetu API.
///
/// Registration issues an OTP that must be verified before the account can
/// sign in. Login itself takes no OTP — just an identifier (email OR mobile)
/// and the password.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// Demo code shown on the OTP screen while there is no SMS gateway. The
  /// server also returns the real code as `devOtp` for testing.
  static const String demoOtp = '123456';

  /// Last OTP the server issued, so the UI can surface it in demo mode.
  String? lastIssuedOtp;

  /// Signs in with either an email address or a 10-digit mobile number.
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final result = await ApiClient.instance.post(
      '/api/auth/login',
      body: {'identifier': identifier, 'password': password},
    );

    if (!result.ok) return AuthResult.failure(result.message);

    await SessionStore.instance.saveSession(
      token: result.data['token'] as String,
      user: result.data['user'] as Map<String, dynamic>,
    );
    return const AuthResult.success();
  }

  /// Creates the account and triggers the phone OTP.
  Future<AuthResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final result = await ApiClient.instance.post(
      '/api/auth/register',
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );

    if (!result.ok) return AuthResult.failure(result.message);
    lastIssuedOtp = result.data['devOtp']?.toString();
    return const AuthResult.success();
  }

  /// Requests a fresh registration code.
  Future<String> sendOtp(String phone) async {
    final result = await ApiClient.instance.post(
      '/api/auth/resend-otp',
      body: {'phone': phone},
    );
    lastIssuedOtp = result.data['devOtp']?.toString() ?? demoOtp;
    return lastIssuedOtp!;
  }

  /// Confirms the registration code and starts the session.
  Future<AuthResult> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final result = await ApiClient.instance.post(
      '/api/auth/verify-otp',
      body: {'phone': phone, 'otp': otp},
    );

    if (!result.ok) return AuthResult.failure(result.message);

    await SessionStore.instance.saveSession(
      token: result.data['token'] as String,
      user: result.data['user'] as Map<String, dynamic>,
    );
    return const AuthResult.success();
  }

  /// Changes the password for the signed-in account.
  Future<AuthResult> resetPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await SessionStore.instance.token();
    if (token == null) return const AuthResult.failure('Please sign in again');

    final result = await ApiClient.instance.put(
      '/api/security',
      token: token,
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );

    if (!result.ok) return AuthResult.failure(result.message);
    return const AuthResult.success();
  }
}

class AuthResult {
  const AuthResult.success() : ok = true, message = null;

  const AuthResult.failure(this.message) : ok = false;

  final bool ok;
  final String? message;
}
