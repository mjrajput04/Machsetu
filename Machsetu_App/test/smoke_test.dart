import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:machsetu_app/core/routes/app_routes.dart';
import 'package:machsetu_app/core/services/shell_tabs.dart';
import 'package:machsetu_app/core/theme/app_theme.dart';
import 'package:machsetu_app/core/utils/currency.dart';
import 'package:machsetu_app/features/checkout/checkout_screen.dart';
import 'package:machsetu_app/features/orders/data/order.dart';
import 'package:machsetu_app/features/orders/order_success_screen.dart';
import 'package:machsetu_app/features/orders/orders_screen.dart';
import 'package:machsetu_app/features/orders/order_tracking_screen.dart';
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
    // Both are process-wide singletons — reset so tests stay independent.
    ShellTabs.go(ShellTabs.home);
    CartStore.instance.clear();
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

    expect(find.text('Procurement Cart'), findsOneWidget);
    expect(find.text('Haas VF-2'), findsOneWidget);
    expect(find.text('HAAS AUTOMATION'), findsOneWidget);
    expect(find.text('₹57,50,000.00'), findsWidgets);
  });

  // Reproduces the numbers on the design's Order Summary exactly.
  test('cart totals match the quote sheet', () {
    final cart = CartStore.instance..clear();
    addTearDown(cart.clear);

    cart.add(
      ProductCatalog.from(
        title: 'VF-2SS Vertical Machining Center',
        brand: 'Haas Automation',
        price: '₹64,995.00',
      ),
    );
    final arm = ProductCatalog.from(
      title: 'M-20iB/25 High-Payload Arm',
      brand: 'Fanuc Robotics',
      price: '₹32,450.00',
    );
    cart
      ..add(arm)
      ..add(arm);

    expect(cart.count, 3);
    expect(Rupees.format(cart.subtotal), '₹1,29,895.00');
    expect(Rupees.format(cart.shipping), '₹4,250.00');
    expect(Rupees.format(cart.brokerage), '₹1,120.00');
    expect(Rupees.format(cart.gst), '₹24,347.70');
    expect(Rupees.format(cart.total), '₹1,59,612.70');
  });

  testWidgets('tapping the featured card body opens the product page', (
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

    // Tap the card's title, not its CTA button.
    await tester.dragUntilVisible(
      find.text('Haas VF-2 Super Speed'),
      find.byType(Scrollable).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Haas VF-2 Super Speed'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
  });

  testWidgets('View Cart from the product page lands on the cart tab', (
    tester,
  ) async {
    CartStore.instance.clear();
    ShellTabs.go(ShellTabs.home);
    addTearDown(() {
      CartStore.instance.clear();
      ShellTabs.go(ShellTabs.home);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MainShell(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Haas VF-2 Super Speed'),
      find.byType(Scrollable).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Haas VF-2 Super Speed'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add to Cart'));
    // Let the snackbar finish sliding in before tapping its action.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('VIEW CART'), findsOneWidget);
    await tester.tap(find.text('VIEW CART'));
    await tester.pumpAndSettle();

    // Back on the shell, showing the cart.
    expect(find.byType(ProductDetailScreen), findsNothing);
    expect(ShellTabs.selected.value, ShellTabs.cart);
    expect(find.text('Procurement Cart'), findsOneWidget);
  });

  testWidgets('checkout mirrors the cart total', (tester) async {
    final cart = CartStore.instance..clear();
    cart.add(
      ProductCatalog.from(
        title: 'VF-2SS Vertical Machining Center',
        brand: 'Haas Automation',
        price: '₹64,995.00',
      ),
    );
    addTearDown(cart.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const CheckoutScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Secure Checkout'), findsOneWidget);
    expect(find.text('Customer Details'), findsOneWidget);

    // Freight is shipping + brokerage, so the total matches the cart page.
    expect(Rupees.format(cart.freight), '₹5,370.00');

    final page = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Place Order'),
      page,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(find.text('Place Order'), findsOneWidget);
    expect(find.text(Rupees.format(cart.total)), findsOneWidget);
  });

  testWidgets('an empty checkout form is rejected', (tester) async {
    final cart = CartStore.instance..clear();
    OrderStore.instance.clear();
    cart.add(
      ProductCatalog.from(
        title: 'Haas VF-2',
        brand: 'Haas Automation',
        price: '₹57,50,000',
      ),
    );
    addTearDown(() {
      cart.clear();
      OrderStore.instance.clear();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const CheckoutScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Place Order'),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();

    // Fields scrolled out of view must still block submission.
    expect(find.byType(OrderSuccessScreen), findsNothing);
    expect(OrderStore.instance.isEmpty, isTrue);
    expect(find.text('Full name is required'), findsOneWidget);
  });

  testWidgets('placing an order shows confirmation, then tracking', (
    tester,
  ) async {
    final cart = CartStore.instance..clear();
    OrderStore.instance.clear();
    cart.add(
      ProductCatalog.from(
        title: 'Haas VF-2',
        brand: 'Haas Automation',
        price: '₹57,50,000',
        equipmentType: 'CNC Precision Lathe',
      ),
    );
    addTearDown(() {
      cart.clear();
      OrderStore.instance.clear();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const CheckoutScreen(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> fill(String label, String value) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, label).last,
        value,
      );
    }

    final page = find.byType(Scrollable).first;
    await fill('e.g. Johnathan Miller', 'Rajesh Kumar');
    await fill('+91 98765-43210', '9876543210');
    await fill('Apex Manufacturing Ltd.', 'Apex Manufacturing');
    await fill('GSTIN-9922883311', 'GSTIN9922883311');
    await fill('Plot 44, Industrial Area Phase II', 'Plot 44');
    await fill('Pune', 'Pune');
    await fill('Maharashtra', 'Maharashtra');
    await fill('48201', '411001');
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Place Order'),
      page,
      const Offset(0, -200),
    );
    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();

    // Confirmation carries the order through, and the cart is consumed.
    expect(find.byType(OrderSuccessScreen), findsOneWidget);
    expect(find.text('Order Submitted Successfully'), findsOneWidget);
    expect(cart.isEmpty, isTrue);
    expect(OrderStore.instance.orders.length, 1);

    final order = OrderStore.instance.orders.first;
    expect(find.text(order.reference), findsOneWidget);

    final successPage = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Track Order'),
      successPage,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(find.text('CNC Precision Lathe'), findsOneWidget);
    expect(find.text('Expedited Freight'), findsOneWidget);

    await tester.tap(find.text('Track Order'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderTrackingScreen), findsOneWidget);
    expect(find.text('Order ${order.trackingId}'), findsOneWidget);
    expect(find.text('Current Status: Inquiry Received'), findsOneWidget);
    expect(find.text('Procurement Progress'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Under Review'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
  });

  testWidgets('orders page splits active inquiries from history', (
    tester,
  ) async {
    OrderStore.instance
      ..clear()
      ..seedDemoOrders();
    addTearDown(OrderStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const OrdersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orders & Inquiries'), findsOneWidget);
    expect(find.text('New Inquiry'), findsOneWidget);
    expect(find.text('ACTIVE INQUIRIES'), findsOneWidget);
    expect(find.text('AX-900 Precision Lathe'), findsOneWidget);
    expect(find.text('Under Review'), findsOneWidget);
    expect(find.text('View Details'), findsWidgets);

    final page = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('ORDER HISTORY'),
      page,
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terraform Gen-SET 500'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Re-order'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
  });

  testWidgets('filtering by status narrows the list', (tester) async {
    OrderStore.instance
      ..clear()
      ..seedDemoOrders();
    addTearDown(OrderStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const OrdersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filter by Status'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(OrderStatus.cancelled.label).last);
    await tester.pumpAndSettle();

    expect(find.text('Laser-Cut V3 Pro'), findsOneWidget);
    expect(find.text('AX-900 Precision Lathe'), findsNothing);
    expect(find.text('ACTIVE INQUIRIES'), findsNothing);
  });

  test('rupee formatting uses Indian digit grouping', () {
    expect(Rupees.format(1596127 / 10), '₹1,59,612.70');
    expect(Rupees.compact(5750000), '₹57,50,000');
    expect(Rupees.compact(999), '₹999');
    expect(Rupees.parse('₹1,15,00,000'), 11500000);
  });
}
