import 'package:flutter/material.dart';

import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_verify_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/home/main_shell.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/listings/machine_listing_screen.dart';
import '../../features/product/data/product.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerify = '/otp-verify';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String machines = '/machines';
  static const String product = '/product';
  static const String checkout = '/checkout';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen(), settings);
      case login:
        return _slide(const LoginScreen(), settings);
      case register:
        return _slide(const RegisterScreen(), settings);
      case forgotPassword:
        return _slide(const ForgotPasswordScreen(), settings);
      case otpVerify:
        return _slide(
          OtpVerifyScreen(args: settings.arguments as OtpArgs),
          settings,
        );
      case resetPassword:
        return _slide(
          ResetPasswordScreen(phone: settings.arguments as String),
          settings,
        );
      case home:
        return _fade(const MainShell(), settings);
      case machines:
        return _slide(const MachineListingScreen(), settings);
      case checkout:
        return _slide(const CheckoutScreen(), settings);
      case product:
        return _slide(
          ProductDetailScreen(product: settings.arguments as Product),
          settings,
        );
      default:
        return _fade(const SplashScreen(), settings);
    }
  }

  static Route<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  static Route<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
