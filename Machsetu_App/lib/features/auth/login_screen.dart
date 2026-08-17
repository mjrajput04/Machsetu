import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/primary_button.dart';
import 'widgets/auth_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final result = await AuthService.instance.login(
      identifier: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.ok) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                // Keeps the whole page optically centred, yet still
                // scrollable once the keyboard is up.
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: BrandLogo(size: 120)),
                    // No gap: both PNGs carry their own padding, so the mark
                    // and the wordmark read as one lockup.
                    const Center(child: BrandTextLogo(width: 250)),
                    const SizedBox(height: 28),
                    AuthCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navy,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppTextField(
                              controller: _email,
                              label: 'Email Address or Mobile Number',
                              hint: 'you@company.com or 98765 43210',
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: Validators.loginIdentifier,
                            ),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _password,
                              label: 'Password',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscure: true,
                              textInputAction: TextInputAction.done,
                              validator: Validators.password,
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.brandBlue,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.forgotPassword),
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 18),
                            PrimaryButton(
                              label: 'Login',
                              loading: _loading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),
                            // scaleDown keeps the prompt and the link on a
                            // single line on narrow handsets.
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.brandBlue,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () => Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.register),
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
