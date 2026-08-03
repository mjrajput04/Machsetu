import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:machsetu_app/core/routes/app_routes.dart';
import 'package:machsetu_app/core/theme/app_theme.dart';
import 'package:machsetu_app/features/home/main_shell.dart';
import 'package:machsetu_app/features/cart/data/cart_store.dart';
import 'package:machsetu_app/features/listings/machine_listing_screen.dart';
import 'package:machsetu_app/features/product/data/product.dart';
import 'package:machsetu_app/features/product/product_detail_screen.dart';
import 'package:machsetu_app/features/product/widgets/product_hero.dart';

void main() {
  // Phone-sized viewport so overflow assertions reflect a real handset.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
    expect(find.text('₹1,15,00,000'), findsOneWidget);
  });

  testWidgets('View All Manifests opens the machine listing page', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MainShell(),
      ),
    );
    await tester.pumpAndSettle();

    // Home's ListView builds lazily, so scroll the section header into view.
    final homeList = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('View All Manifests →'),
      homeList,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    expect(find.text('₹58,50,000'), findsOneWidget);

    await tester.tap(find.text('View All Manifests →'));
    await tester.pumpAndSettle();

    expect(find.byType(MachineListingScreen), findsOneWidget);
    expect(find.text('CNC Machines'), findsOneWidget);
    expect(find.text('Haas VF-2'), findsOneWidget);
    expect(find.text('₹57,50,000'), findsOneWidget);

    // The chip row scrolls horizontally, so bring "Lathes" on screen first.
    await tester.dragUntilVisible(
      find.text('Lathes'),
      find.byType(Scrollable).first,
      const Offset(-120, 0),
    );
    await tester.pumpAndSettle();

    // Filtering to Lathes drops the milling machines, leaving a short enough
    // list that the footer button is on screen.
    await tester.tap(find.text('Lathes'));
    await tester.pumpAndSettle();

    expect(find.text('Quick Turn 250'), findsOneWidget);
    expect(find.text('Puma GT2100'), findsOneWidget);
    expect(find.text('Haas VF-2'), findsNothing);

    await tester.dragUntilVisible(
      find.text('Load More Results'),
      find.byType(Scrollable).last,
      const Offset(0, -150),
    );
    expect(find.text('Load More Results'), findsOneWidget);
  });

  testWidgets('tapping a listing opens the product page and fills the cart', (
    tester,
  ) async {
    CartStore.instance.clear();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MachineListingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'View Details').first);
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    // Header carries the tapped card's own data through.
    expect(find.text('Haas VF-2'), findsOneWidget);
    // The brand line is a Text.rich, so it needs rich-text matching.
    expect(
      find.textContaining('Haas Automation', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('₹57,50,000'), findsOneWidget);
    expect(find.text('PRECISION SERIES'), findsOneWidget);
    expect(find.byType(ProductHero), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Cart'));
    await tester.pumpAndSettle();

    expect(CartStore.instance.count, 1);

    // A second tap bumps the quantity rather than duplicating the line.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Cart'));
    await tester.pumpAndSettle();

    expect(CartStore.instance.count, 2);
    expect(CartStore.instance.items.length, 1);
  });

  testWidgets('the cart tab lists what was added', (tester) async {
    CartStore.instance
      ..clear()
      ..add(
        ProductCatalog.from(
          title: 'Haas VF-2',
          brand: 'Haas Automation',
          price: '₹57,50,000',
        ),
      );
    addTearDown(CartStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const MainShell()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.text('Haas VF-2'), findsOneWidget);
    expect(find.text('₹57,50,000'), findsOneWidget);
    expect(find.text('PLACE INQUIRY'), findsOneWidget);
  });
}
