import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/otp_input.dart';
import '../../core/widgets/primary_button.dart';
import 'widgets/auth_card.dart';

enum OtpPurpose {
  /// Verifying the phone number entered while creating an account.
  registration,

  /// Verifying ownership of the number before setting a new password.
  resetPassword,
}

class OtpArgs {
  const OtpArgs({required this.phone, required this.purpose, this.name});

  final String phone;
  final OtpPurpose purpose;

  /// Carried over from registration so the verified session knows who the
  /// user is (drives the app-bar monogram).
  final String? name;
}

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.args});

  final OtpArgs args;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  static const int _resendSeconds = 30;

  String _code = '';
  bool _loading = false;
  bool _resending = false;
  bool _hasError = false;
  int _secondsLeft = _resendSeconds;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _ticker?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  String get _maskedPhone {
    final p = widget.args.phone;
    if (p.length < 4) return p;
    return '+91 ${'*' * (p.length - 4)}${p.substring(p.length - 4)}';
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (_code.length != 6) {
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the complete 6-digit code')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _hasError = false;
    });

    final result = await AuthService.instance.verifyOtp(
      phone: widget.args.phone,
      otp: _code,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.ok) {
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Verification failed')),
      );
      return;
    }

    switch (widget.args.purpose) {
      case OtpPurpose.registration:
        await SessionStore.instance.save(
          phone: widget.args.phone,
          name: widget.args.name,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile number verified. Welcome to MachSetu!'),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      case OtpPurpose.resetPassword:
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.resetPassword,
          arguments: widget.args.phone,
        );
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _resending) return;
    setState(() => _resending = true);
    await AuthService.instance.sendOtp(widget.args.phone);
    if (!mounted) return;
    setState(() => _resending = false);
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('A new code was sent to $_maskedPhone')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRegistration = widget.args.purpose == OtpPurpose.registration;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isRegistration ? 'Verify Your Number' : 'Enter OTP',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'We sent a 6-digit verification code to ',
                    ),
                    TextSpan(
                      text: _maskedPhone,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OtpInput(
                      hasError: _hasError,
                      onChanged: (value) => setState(() {
                        _code = value;
                        _hasError = false;
                      }),
                      onCompleted: (_) => _verify(),
                    ),
                    const SizedBox(height: 20),
                    // Demo helper — remove once a real SMS gateway is wired up.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Demo mode — use code ${AuthService.demoOtp}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: isRegistration ? 'Verify & Continue' : 'Verify OTP',
                      loading: _loading,
                      onPressed: _verify,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: _resending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : _secondsLeft > 0
                              ? Text(
                                  'Resend code in 00:'
                                  '${_secondsLeft.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : TextButton(
                                  onPressed: _resend,
                                  child: const Text('Resend Code'),
                                ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Change mobile number'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
