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

  /// The code the server echoes back as `devOtp` while it has no SMS gateway
  /// configured, so the OTP screen can show it. Null once real SMS is live —
  /// the code then only ever reaches the user's phone.
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
  ///
  /// Fails with the server's reason when the code could not be sent — for
  /// example when "Resend" is tapped again too quickly.
  Future<AuthResult> sendOtp(String phone) async {
    final result = await ApiClient.instance.post(
      '/api/auth/resend-otp',
      body: {'phone': phone},
    );
    if (!result.ok) return AuthResult.failure(result.message);
    lastIssuedOtp = result.data['devOtp']?.toString();
    return const AuthResult.success();
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

  /// Short-lived proof that the phone was just verified for a password
  /// reset. Only the reset-password call accepts it.
  String? _resetToken;

  /// "Forgot password" step 1: sends a reset code to the account's mobile.
  /// Also used by the OTP screen's "Resend" while resetting.
  Future<AuthResult> requestPasswordReset(String phone) async {
    final result = await ApiClient.instance.post(
      '/api/auth/forgot-password',
      body: {'phone': phone},
    );
    if (!result.ok) return AuthResult.failure(result.message);
    lastIssuedOtp = result.data['devOtp']?.toString();
    return const AuthResult.success();
  }

  /// "Forgot password" step 2: checks the reset code.
  Future<AuthResult> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    final result = await ApiClient.instance.post(
      '/api/auth/verify-reset-otp',
      body: {'phone': phone, 'otp': otp},
    );
    if (!result.ok) return AuthResult.failure(result.message);
    _resetToken = result.data['resetToken']?.toString();
    return const AuthResult.success();
  }

  /// "Forgot password" step 3: sets the new password. No old password is
  /// needed — the verified reset code is the proof.
  Future<AuthResult> setNewPassword(String newPassword) async {
    final token = _resetToken;
    if (token == null) {
      return const AuthResult.failure(
        'Your reset session expired. Please request a new code.',
      );
    }

    final result = await ApiClient.instance.post(
      '/api/auth/reset-password',
      body: {'resetToken': token, 'password': newPassword},
    );
    if (!result.ok) return AuthResult.failure(result.message);
    _resetToken = null;
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
