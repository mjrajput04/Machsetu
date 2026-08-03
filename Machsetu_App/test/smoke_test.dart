import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:machsetu_app/core/theme/app_theme.dart';
import 'package:machsetu_app/features/home/main_shell.dart';

void main() {
  // Phone-sized viewport so overflow assertions reflect a real handset.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(1080, 2340);
    view.devicePixelRatio = 3.0;
  });

  testWidgets('home and search tabs render without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const MainShell()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Industrial Partner'), findsOneWidget);
    expect(find.text('Featured Machines'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('RECENT SEARCHES'), findsOneWidget);
    expect(find.text('DMG Mori CMX 1100 V'), findsOneWidget);
    expect(
      find.text('142 results for "Vertical Machining Center"'),
      findsOneWidget,
    );
  });
}
