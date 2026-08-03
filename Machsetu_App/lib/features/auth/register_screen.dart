import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/primary_button.dart';
import 'otp_verify_screen.dart';
import 'widgets/auth_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  /// Creates the account, then sends an OTP so the phone number can be
  /// verified before the user lands on the marketplace.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms to continue'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final phone = _phone.text.trim();
    final result = await AuthService.instance.register(
      name: _name.text.trim(),
      phone: phone,
      email: _email.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;

    if (!result.ok) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Registration failed')),
      );
      return;
    }

    await AuthService.instance.sendOtp(phone);
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushNamed(
      AppRoutes.otpVerify,
      arguments: OtpArgs(phone: phone, purpose: OtpPurpose.registration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(
            children: [
              const BrandLogo(size: 62),
              const SizedBox(height: 14),
              const BrandWordmark(fontSize: 22),
              const SizedBox(height: 8),
              const BrandTagline(fontSize: 9.5),
              const SizedBox(height: 20),
              AuthCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _name,
                        label: 'Full Name',
                        hint: 'Rajesh Kumar',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: Validators.name,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phone,
                        label: 'Mobile Number',
                        hint: '98765 43210',
                        icon: Icons.phone_iphone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _email,
                        label: 'Email Address',
                        hint: 'you@company.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _password,
                        label: 'Password',
                        hint: 'At least 6 characters',
                        icon: Icons.lock_outline,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirm,
                        label: 'Confirm Password',
                        hint: 'Re-enter password',
                        icon: Icons.lock_reset_outlined,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator:
                            Validators.confirmPassword(() => _password.text),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _acceptedTerms,
                              activeColor: AppColors.navy,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (value) => setState(
                                () => _acceptedTerms = value ?? false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'I agree to the Terms of Trade and Privacy '
                              'Policy of MachSetu.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: 'Create Account',
                        loading: _loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'We will send an OTP to verify your mobile '
                              'number',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already registered?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
