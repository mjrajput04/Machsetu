import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:machsetu_app/core/routes/app_routes.dart';
import 'package:machsetu_app/features/auth/forgot_password_screen.dart';
import 'package:machsetu_app/features/auth/login_screen.dart';
import 'package:machsetu_app/features/auth/register_screen.dart';
import 'package:machsetu_app/features/home/main_shell.dart';
import 'package:machsetu_app/main.dart';

void main() {
  testWidgets('splash shows the brand and moves on to login', (tester) async {
    await tester.pumpWidget(const MachSetuApp());

    expect(find.text('SYNCING GLOBAL NODES...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });

  testWidgets('login validates its fields before submitting', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const LoginScreen(),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('valid credentials land on the marketplace shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const LoginScreen(),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'you@company.com'),
      'buyer@machsetu.in',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '••••••••'),
      'secret123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('auth links stay reachable at phone width', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532); // ~390x844 logical
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const LoginScreen(),
      ),
    );

    await tester.tap(find.widgetWithText(TextButton, 'Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(ForgotPasswordScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Register'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
