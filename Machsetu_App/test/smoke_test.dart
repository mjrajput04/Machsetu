import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:machsetu_app/core/routes/app_routes.dart';
import 'package:machsetu_app/core/services/catalogue_service.dart';
import 'package:machsetu_app/core/services/session_store.dart';
import 'package:machsetu_app/core/services/settings_service.dart';
import 'package:machsetu_app/core/services/shell_tabs.dart';
import 'package:machsetu_app/core/theme/app_theme.dart';
import 'package:machsetu_app/core/utils/currency.dart';
import 'package:machsetu_app/features/cart/data/cart_store.dart';
import 'package:machsetu_app/features/checkout/checkout_screen.dart';
import 'package:machsetu_app/features/home/data/machines.dart';
import 'package:machsetu_app/features/home/main_shell.dart';
import 'package:machsetu_app/features/listings/machine_listing_screen.dart';
import 'package:machsetu_app/features/notifications/data/notification_store.dart';
import 'package:machsetu_app/features/notifications/data/notifications.dart';
import 'package:machsetu_app/features/notifications/notifications_screen.dart';
import 'package:machsetu_app/features/orders/data/order.dart';
import 'package:machsetu_app/features/orders/order_success_screen.dart';
import 'package:machsetu_app/features/orders/order_tracking_screen.dart';
import 'package:machsetu_app/features/orders/orders_screen.dart';
import 'package:machsetu_app/features/product/data/product.dart';
import 'package:machsetu_app/features/product/product_detail_screen.dart';
import 'package:machsetu_app/features/product/widgets/product_hero.dart';
import 'package:machsetu_app/features/profile/data/inquiries.dart';
import 'package:machsetu_app/features/profile/data/inquiry_store.dart';
import 'package:machsetu_app/features/profile/edit_profile_screen.dart';
import 'package:machsetu_app/features/profile/my_inquiries_screen.dart';
import 'package:machsetu_app/features/profile/profile_screen.dart';
import 'package:machsetu_app/features/profile/security_screen.dart';
import 'package:machsetu_app/features/sell/data/sell_options.dart';
import 'package:machsetu_app/features/sell/data/sell_store.dart';
import 'package:machsetu_app/features/sell/listing_details_screen.dart';
import 'package:machsetu_app/features/sell/my_listings_screen.dart';
import 'package:machsetu_app/features/sell/sell_machine_screen.dart';
import 'package:machsetu_app/features/sell/submission_status_screen.dart';
import 'package:machsetu_app/features/support/help_support_screen.dart';
import 'package:machsetu_app/features/support/terms_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:machsetu_app/core/services/upload_service.dart';

void main() {
  // Phone-sized viewport so overflow assertions reflect a real handset.
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Both are process-wide singletons — reset so tests stay independent.
    ShellTabs.go(ShellTabs.home);
    CartStore.instance.clear();

    // The app ships no sample data any more, so a test that needs a
    // catalogue, an inquiry or an alert to work with puts one there itself.
    CatalogueService.instance.seed(MachineData.all);
    SettingsService.instance.seed(
      categories: [
        for (final (_, name) in MachineData.categories)
          if (name != MachineData.allCategory) name,
      ],
    );
    InquiryStore.instance.seed(InquiryData.all);
    NotificationStore.instance.seed(
      today: NotificationData.today,
      earlier: NotificationData.earlier,
    );
    OrderStore.instance
      ..clear()
      ..seedDemoOrders();
    SellStore.instance
      ..clear()
      ..seedDemoListings();
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
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
    // Search cards are built from the same catalogue the home tab shows.
    expect(find.text('DMG MORI DMU 50'), findsOneWidget);
    expect(find.text('₹1,45,00,000'), findsOneWidget);
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

    expect(find.text('₹1,45,00,000'), findsOneWidget);

    await tester.tap(find.text('View All Manifests →'));
    await tester.pumpAndSettle();

    expect(find.byType(MachineListingScreen), findsOneWidget);
    expect(find.text('DMG MORI DMU 50'), findsOneWidget);
    expect(find.text('₹1,45,00,000'), findsOneWidget);

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

    expect(find.text('Mazak QUICK TURN 250MY'), findsOneWidget);
    expect(find.text('Doosan PUMA 2600SY'), findsOneWidget);
    // Filtering to Lathes drops every machining centre.
    expect(find.text('DMG MORI DMU 50'), findsNothing);

    // Three lathes fit in one page, so there is nothing more to load and the
    // footer button is correctly absent.
    expect(find.textContaining('Load '), findsNothing);
  });

  testWidgets('the listing page pages through a long catalogue', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MachineListingScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 15 machines, 8 to a page: the footer offers the remaining 7.
    await tester.dragUntilVisible(
      find.textContaining('Load '),
      find.byType(Scrollable).last,
      const Offset(0, -200),
    );
    expect(find.text('Load 7 more'), findsOneWidget);

    await tester.tap(find.text('Load 7 more'));
    await tester.pumpAndSettle();

    // Everything is on screen now, so the button is gone.
    expect(find.textContaining('Load '), findsNothing);
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
    // Header carries the tapped card's own data through — the first card on
    // the listing page is the first machine in the catalogue.
    expect(find.text('DMG MORI DMU 50'), findsOneWidget);
    // The brand line is a Text.rich, so it needs rich-text matching. It also
    // repeats in the Machine Details table, hence findsWidgets.
    expect(find.textContaining('DMG MORI', findRichText: true), findsWidgets);
    expect(find.text('₹1,45,00,000'), findsOneWidget);
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

    // Fees are percentages of the goods value, set on the admin Settings
    // page; offline the app falls back to 0.5 / 1.5 / 18 percent.
    final rates = SettingsService.instance.commercials;

    expect(cart.count, 3);
    expect(Rupees.format(cart.subtotal), '₹1,29,895.00');
    expect(cart.shipping, closeTo(129895 * rates.shippingRate / 100, 0.001));
    expect(cart.brokerage, closeTo(129895 * rates.brokerageRate / 100, 0.001));
    expect(
      cart.gst,
      closeTo((cart.subtotal + cart.freight) * rates.gstRate / 100, 0.001),
    );
    expect(cart.total, closeTo(cart.subtotal + cart.freight + cart.gst, 0.001));
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
      find.text('DMG MORI DMU 50'),
      find.byType(Scrollable).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('DMG MORI DMU 50'));
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
      find.text('DMG MORI DMU 50'),
      find.byType(Scrollable).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('DMG MORI DMU 50'));
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
    expect(cart.freight, closeTo(cart.shipping + cart.brokerage, 0.001));
    expect(cart.freight, greaterThan(0));

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

  testWidgets('the bell opens the notification centre', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MainShell(),
      ),
    );
    await tester.pumpAndSettle();

    // Every tab in the IndexedStack has an app bar, so target the visible one.
    await tester.tap(find.byIcon(Icons.notifications_none_rounded).first);
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.text('Notification Center'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Inquiry Approved'), findsOneWidget);
    expect(find.text('View Quote'), findsOneWidget);
  });

  testWidgets('profile links reach help and terms', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: ProfileScreen(onLogout: () async {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account Settings'), findsOneWidget);
    // The header shows identity only now — no demo persona, designation,
    // company, member ID or GST badge.
    expect(find.text('MachSetu User'), findsOneWidget);
    expect(find.text('Senior Procurement Director'), findsNothing);
    expect(find.text('Aerotech Solutions Inc.'), findsNothing);
    expect(find.textContaining('MS-88291'), findsNothing);
    expect(find.textContaining('Verified GST'), findsNothing);
    // Addresses have their own page in the menu.
    expect(find.text('My Addresses'), findsOneWidget);

    // Sell Your Machine opens the listings page, not the form.
    await tester.tap(find.text('Sell Your Machine'));
    await tester.pumpAndSettle();
    expect(find.byType(MyListingsScreen), findsOneWidget);
    expect(find.byType(SellMachineScreen), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    final page = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Help & Support'),
      page,
      const Offset(0, -160),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Help & Support'));
    await tester.pumpAndSettle();
    expect(find.byType(HelpSupportScreen), findsOneWidget);
    expect(find.text('How can we help?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Terms & Conditions'),
      find.byType(Scrollable).first,
      const Offset(0, -160),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();
    expect(find.byType(TermsScreen), findsOneWidget);
    expect(find.text('Terms of Trade'), findsOneWidget);
  });

  testWidgets('edit profile owns identity only, with a locked email', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const EditProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Change Photo'), findsOneWidget);
    expect(find.text('Your Details'), findsOneWidget);

    // Company, GST and the single address block moved off this form.
    expect(find.text('Company'), findsNothing);
    expect(find.text('GST / Tax Identification Number'), findsNothing);
    expect(find.text('Delivery Address'), findsNothing);
    expect(find.text('Designation'), findsNothing);

    // Addresses are a page of their own now, reachable from here.
    expect(find.text('My Addresses'), findsOneWidget);

    // Email is shown but cannot be edited — it is the account key.
    final email = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'you@company.com').last,
    );
    expect(email.enabled, isNot(false));
    expect(
      find.text('Your email is your login and cannot be changed here.'),
      findsOneWidget,
    );

    // The monogram tracks whatever is typed into the name.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Your name').last,
      'Rajesh Kumar',
    );
    await tester.pumpAndSettle();
    expect(find.text('RK'), findsOneWidget);
  });

  testWidgets('my inquiries filters open and closed RFQs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MyInquiriesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Requests for Quotation'), findsOneWidget);
    expect(find.text('RFQ-4471'), findsOneWidget);
    expect(find.text('Quote Received'), findsOneWidget);
    expect(find.text('₹1,12,50,000'), findsOneWidget);

    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();

    expect(find.text('RFQ-4402'), findsOneWidget);
    expect(find.text('RFQ-4471'), findsNothing);
  });

  testWidgets('security toggles persist and sessions can be revoked', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const SecurityScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account Security'), findsOneWidget);
    expect(find.text('Two-Factor Authentication'), findsOneWidget);

    // Login alerts default on, 2FA and biometrics off. Persistence now runs
    // through the API, so this asserts the switch itself flips.
    expect((await SessionStore.instance.security()).twoFactor, isFalse);

    final before = tester.widget<Switch>(find.byType(Switch).first);
    expect(before.value, isFalse);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final after = tester.widget<Switch>(find.byType(Switch).first);
    expect(after.value, isTrue);

    final page = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Chrome • Windows 11'),
      page,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Revoke').first);
    await tester.pumpAndSettle();

    expect(find.text('Sign out this device?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Out'));
    await tester.pumpAndSettle();

    expect(find.text('Chrome • Windows 11'), findsNothing);
  });

  testWidgets('the sell wizard blocks a blank submission', (tester) async {
    SellStore.instance.clear();
    addTearDown(SellStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const SellMachineScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Step 1: Details'), findsOneWidget);

    // Next with nothing filled must not move off Details.
    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();

    expect(find.text('Step 1: Details'), findsOneWidget);
    expect(find.text('Upload Images'), findsNothing);
    expect(
      find.textContaining('required fields still need filling'),
      findsOneWidget,
    );
    expect(find.text('Contact name is required'), findsOneWidget);

    // Nothing reached the store.
    expect(SellStore.instance.listings, isEmpty);
  });

  testWidgets('the wizard advances once the required fields are filled', (
    tester,
  ) async {
    SellStore.instance.clear();
    addTearDown(SellStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const SellMachineScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final page = find.byType(Scrollable).first;

    Future<void> fill(String hint, String value) async {
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, hint).last,
        260,
        scrollable: page,
        maxScrolls: 120,
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, hint).last, value);
      await tester.pumpAndSettle();
    }

    await fill('e.g. Pappu Singh', 'Rajesh Kumar');
    await fill('84015 03169', '9876543210');

    // Category is a tick list, not a text field.
    await tester.scrollUntilVisible(find.text('VMC'), 260, scrollable: page);
    await tester.pumpAndSettle();
    await tester.tap(find.text('VMC'));
    await tester.pumpAndSettle();

    await fill('e.g. Haas', 'Haas Automation');
    await fill('e.g. VF-2', 'VF-2SS');
    // Two fields share the 'YYYY' hint (Manufacturing and Installation
    // Year); the first in tree order is the one the gate requires.
    await tester.scrollUntilVisible(
      find.widgetWithText(TextField, 'YYYY').first,
      260,
      scrollable: page,
      maxScrolls: 120,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'YYYY').first,
      '2021',
    );
    await tester.pumpAndSettle();

    await fill('City, State', 'Pune, MH');

    // Price sits in the next card down; reveal the section first so the lazy
    // list has built it before the finder runs.
    await tester.scrollUntilVisible(
      find.text('Commercial Information'),
      260,
      scrollable: page,
      maxScrolls: 120,
    );
    await tester.pumpAndSettle();
    await fill('e.g. 1500000', '7050000');

    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();

    // Details cleared, so the wizard moves on.
    expect(find.text('Upload Images'), findsOneWidget);

    // A listing still needs a photo before it can go further.
    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();
    expect(find.text('Documents Checklist'), findsNothing);
    expect(find.text('Add at least one photo of the machine'), findsWidgets);
  });

  testWidgets('submission status toggles to the timeline and tracks', (
    tester,
  ) async {
    SellStore.instance
      ..clear()
      ..seedDemoListings();
    addTearDown(SellStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: SubmissionStatusScreen(
          listing: SellStore.instance.listings.first,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Timeline View'));
    await tester.pumpAndSettle();
    expect(find.text('Listing Submitted'), findsOneWidget);
    expect(find.text('Broker Review Completed'), findsOneWidget);

    await tester.tap(find.text('Track Submission'));
    await tester.pumpAndSettle();

    expect(find.byType(ListingDetailsScreen), findsOneWidget);
    expect(find.text('Live on Marketplace'), findsWidgets);
    expect(find.text('Technical Specifications'), findsOneWidget);
  });

  testWidgets('my listings searches and filters the seller inventory', (
    tester,
  ) async {
    SellStore.instance
      ..clear()
      ..seedDemoListings();
    addTearDown(SellStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MyListingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Listings'), findsOneWidget);
    expect(find.text('Haas VF-2SS'), findsOneWidget);

    // Search first — it narrows to a single card without any scrolling.
    await tester.enterText(find.byType(TextField).first, 'doosan');
    await tester.pumpAndSettle();

    expect(find.text('Doosan Puma 2600SY'), findsOneWidget);
    expect(find.text('Haas VF-2SS'), findsNothing);
    expect(find.text('Sold'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.text('Haas VF-2SS'), findsOneWidget);

    // Then the status chip. Scrolling the row disposes the chips behind it,
    // so this is the last interaction in the test.
    await tester.ensureVisible(find.text('Pending Review').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pending Review').first);
    await tester.pumpAndSettle();

    expect(find.text('Mazak Integrex i-200ST'), findsOneWidget);
    expect(find.text('Haas VF-2SS'), findsNothing);
  });

  testWidgets('back from any tab returns to Home instead of exiting', (
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

    for (final tab in ['Search', 'Cart', 'Orders', 'Profile']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(ShellTabs.selected.value, isNot(ShellTabs.home));

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      // Back lands on Home and the shell is still mounted.
      expect(ShellTabs.selected.value, ShellTabs.home);
      expect(find.byType(MainShell), findsOneWidget);
    }

    // From Home the first press warns instead of leaving.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Press back again to exit'), findsOneWidget);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('the sell form carries every registration section through', (
    tester,
  ) async {
    SellStore.instance.clear();
    addTearDown(SellStore.instance.clear);
    UploadService.overrideInstance(_StubUploads());
    addTearDown(UploadService.resetInstance);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const SellMachineScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final page = find.byType(Scrollable).first;

    // The form is a lazy list, so scroll forward until each target builds.
    // Everything below runs strictly top-to-bottom for that reason.
    Future<void> reveal(Finder finder) async {
      await tester.scrollUntilVisible(finder, 260, scrollable: page);
      await tester.pumpAndSettle();
    }

    Future<void> fill(String hint, String value) async {
      await reveal(find.widgetWithText(TextField, hint).last);
      await tester.enterText(find.widgetWithText(TextField, hint).last, value);
      await tester.pumpAndSettle();
    }

    // Section 1 — seller information.
    expect(find.text('Seller Information'), findsOneWidget);
    await fill('e.g. Pappu Singh', 'Pappu Singh');
    await fill('84015 03169', '9876543210');
    await fill('24AAACF1234K1ZV', '24aaacf1234k1zv');

    // Section 2 — category tick boxes and detail fields.
    await reveal(find.text('Machine Details'));
    await reveal(find.text('VMC'));
    await tester.tap(find.text('VMC'));
    await tester.pumpAndSettle();
    await fill('e.g. Haas', 'Haas Automation');
    await fill('e.g. VF-2', 'VF-2SS');
    // Manufacturing Year shares its hint with Installation Year and comes
    // first in tree order.
    await reveal(find.widgetWithText(TextField, 'YYYY').first);
    await tester.enterText(
      find.widgetWithText(TextField, 'YYYY').first,
      '2021',
    );
    await tester.pumpAndSettle();
    await fill('e.g. Fanuc 31i-B', 'Fanuc 31i-B');
    await fill('e.g. 3 Axis', '3 Axis');
    await fill('City, State', 'Pune, MH');

    // Section 3 — the Negotiable Yes/No pair is the first on the card.
    await reveal(find.text('Commercial Information'));
    await fill('e.g. 1500000', '7050000');
    await reveal(find.text('Negotiable'));
    await tester.tap(find.text('Yes').first);
    await tester.pumpAndSettle();

    // Section 4 — specifications.
    await reveal(find.text('Machine Specifications'));
    await fill('e.g. 914 x 356 mm', '914 x 356 mm');

    // Details are complete, so the wizard moves on.
    await tester.tap(find.text('Next Step'));
    await tester.pumpAndSettle();
    expect(find.text('Upload Images'), findsOneWidget);

    // One photo: the tile opens a camera/gallery sheet, then the stubbed
    // picker returns a path.
    await tester.tap(find.text('Tap to upload'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    // Images -> Docs -> Review.
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();
    }

    final confirmRow = find.textContaining('I hereby declare');
    final reviewPage = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(confirmRow, 300, scrollable: reviewPage);
    await tester.drag(reviewPage, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(confirmRow);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit for Verification'));
    await tester.pumpAndSettle();

    final listing = SellStore.instance.listings.single;
    expect(listing.seller.name, 'Pappu Singh');
    expect(listing.seller.gstNumber, '24AAACF1234K1ZV');
    expect(listing.category, contains('VMC'));
    expect(listing.controller, 'Fanuc 31i-B');
    expect(listing.numberOfAxis, '3 Axis');
    expect(listing.commercial.negotiable, isTrue);
    expect(listing.specifications.tableSize, '914 x 356 mm');
  });

  testWidgets('listing details shows every registration section', (
    tester,
  ) async {
    SellStore.instance
      ..clear()
      ..seedDemoListings();
    addTearDown(SellStore.instance.clear);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: ListingDetailsScreen(listing: SellStore.instance.listings.first),
      ),
    );
    await tester.pumpAndSettle();

    final page = find.byType(Scrollable).first;
    for (final section in [
      'Machine Details',
      'Machine Specifications',
      'Commercial Information',
      'Inspection Report',
      'Seller Information',
      'Required Photos',
    ]) {
      await tester.dragUntilVisible(
        find.text(section),
        page,
        const Offset(0, -260),
      );
      expect(find.text(section), findsOneWidget);
    }

    // Spot-check values from each section.
    expect(find.text('Haas Next Gen Control'), findsOneWidget);
    expect(find.text('Pappu Singh'), findsOneWidget);
  });

  test('the sell form exposes every field from the registration sheet', () {
    final draft = MachineDraft()
      ..sellerName = 'A'
      ..companyName = 'B'
      ..mobile = '9876543210'
      ..whatsapp = '9876543210'
      ..email = 'a@b.in'
      ..gstNumber = 'GST'
      ..panNumber = 'PAN'
      ..address = 'Addr'
      ..city = 'City'
      ..state = 'State'
      ..pincode = '360021'
      ..negotiable = true
      ..gstAvailable = false
      ..ownerType = 'Dealer'
      ..tableSize = 'T';

    expect(draft.sellerInfo.rows.length, 11);
    expect(draft.commercialInfo.rows.length, 7);
    expect(draft.machineSpecs.rows.length, 11);
    expect(draft.commercialInfo.rows, contains(('Negotiable', 'Yes')));
    expect(draft.commercialInfo.rows, contains(('GST Available', 'No')));
    // Untouched Yes/No pairs stay blank rather than defaulting to No.
    expect(draft.commercialInfo.rows, contains(('Tax Invoice Available', '')));

    // Category tick boxes fold the free-text "Other" value in.
    draft.categories.addAll(['CNC', 'Other']);
    draft.categoryOther = 'Broaching';
    expect(draft.category, 'CNC • Broaching');

    // Checklists cover the printed form exactly.
    expect(SellOptions.requiredPhotos.length, 15);
    expect(SellOptions.documentTypes.length, 10);
    expect(SellOptions.inspectionPoints.length, 12);
  });

  test('the catalogue holds 15 machines, 3 in every category', () {
    expect(MachineData.all.length, 15);

    // "All" is a filter, not a category a machine belongs to.
    final categories = MachineData.categories
        .map((c) => c.$2)
        .where((c) => c != MachineData.allCategory);
    expect(categories.length, 5);

    for (final category in categories) {
      expect(
        MachineData.forCategory(category).length,
        3,
        reason: '$category should hold exactly 3 machines',
      );
    }
    expect(MachineData.forCategory(MachineData.allCategory).length, 15);

    // Every entry carries real detail rather than placeholders.
    for (final m in MachineData.all) {
      expect(m.images, isNotEmpty, reason: '${m.title} needs a photo');
      expect(m.machineDetails.length, greaterThanOrEqualTo(8));
      expect(m.specifications.length, greaterThanOrEqualTo(8));
      expect(m.overview.length, greaterThanOrEqualTo(2));
      expect(m.features, isNotEmpty);
      expect(m.price, startsWith('₹'));
    }
  });

  testWidgets('home category chips filter the featured list', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const MainShell(),
      ),
    );
    await tester.pumpAndSettle();

    // The chip row sits below the fold, so it is not built until scrolled to.
    await tester.scrollUntilVisible(
      find.text('ACTIVE CATEGORIES'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // "All" leads the chip row, so the whole catalogue shows first.
    expect(find.text('All'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Lathes'),
      find.byType(Scrollable).at(1),
      const Offset(-140, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lathes'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('3 machines available'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('3 machines available'), findsOneWidget);
    expect(find.text('Mazak QUICK TURN 250MY'), findsOneWidget);
    expect(find.text('DMG MORI DMU 50'), findsNothing);
  });

  testWidgets('the product page shows that machine\'s real specifications', (
    tester,
  ) async {
    final machine = MachineData.all.firstWhere(
      (m) => m.title == 'Sodick AG400L',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: ProductDetailScreen(product: ProductCatalog.fromMachine(machine)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sodick AG400L'), findsOneWidget);
    expect(find.text('₹58,00,000'), findsOneWidget);
    // Appears as the series chip and again in the quick-facts grid.
    expect(find.text('EDM'), findsWidgets);

    final page = find.byType(Scrollable).first;

    // Hero cards pull real figures out of this machine's own spec table, so
    // the controller shows up both there and in Machine Details.
    await tester.scrollUntilVisible(
      find.text('Sodick LN2W').first,
      280,
      scrollable: page,
    );
    expect(find.text('Sodick LN2W'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Linear motor, all axes').first,
      280,
      scrollable: page,
    );
    expect(find.text('Linear motor, all axes'), findsOneWidget);
    expect(find.text('±15° / 80 mm'), findsOneWidget);
  });

  test('rupee formatting uses Indian digit grouping', () {
    expect(Rupees.format(1596127 / 10), '₹1,59,612.70');
    expect(Rupees.compact(5750000), '₹57,50,000');
    expect(Rupees.compact(999), '₹999');
    expect(Rupees.parse('₹1,15,00,000'), 11500000);
  });
}

/// Stands in for the gallery/camera picker, which a widget test cannot drive.
class _StubUploads extends UploadService {
  _StubUploads() : super.forTesting();

  @override
  Future<UploadOutcome> pickAndUpload({
    int limit = 10,
    ImageSource source = ImageSource.gallery,
  }) async => const UploadOutcome(paths: ['/uploads/test-machine.jpg']);

  @override
  Future<({String url, String name, String size})?>
  pickDocumentAndUpload() async =>
      (url: '/uploads/test-doc.pdf', name: 'test-doc.pdf', size: '12 KB');
}
