import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/catalogue_service.dart';
import '../../core/services/session_store.dart';
import '../../core/services/settings_service.dart';
import '../notifications/data/notification_store.dart';
import '../orders/data/order.dart';
import '../../core/services/shell_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../cart/cart_screen.dart';
import '../cart/data/cart_store.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'home_screen.dart';

/// Bottom-navigation container that hosts the marketplace tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _index = ShellTabs.selected.value;

  @override
  void initState() {
    super.initState();
    ShellTabs.selected.addListener(_onTabRequested);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    ShellTabs.selected.removeListener(_onTabRequested);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back to the app is the moment to pick up anything the sourcing
    // desk changed while it was in the background.
    if (state == AppLifecycleState.resumed) _refresh(force: true);
  }

  /// Everything the desk can change behind the buyer's back.
  void _refresh({bool force = false}) {
    SettingsService.instance.load(force: force);
    CatalogueService.instance.load(force: force);
    OrderStore.instance.loadMine(force: force);
    NotificationStore.instance.load(force: force);
  }

  /// Another screen asked for a tab — e.g. "View Cart" from the product page.
  void _onTabRequested() {
    if (!mounted) return;
    setState(() => _index = ShellTabs.selected.value);
  }

  void _select(int index) {
    ShellTabs.selected.value = index;
    setState(() => _index = index);
    // Cheap: the services skip the call while their last copy is still fresh.
    _refresh();
  }

  static const List<_TabItem> _tabs = [
    _TabItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _TabItem(Icons.search, Icons.search, 'Search'),
    _TabItem(Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
    _TabItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
    _TabItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  DateTime? _lastBackPress;

  /// Back gesture / arrow / hardware button never drops straight out of the
  /// app: any other tab returns to Home first, and leaving from Home needs a
  /// second press so it can't happen by accident.
  void _onBack() {
    if (_index != ShellTabs.home) {
      _select(ShellTabs.home);
      return;
    }

    final now = DateTime.now();
    final last = _lastBackPress;
    if (last == null || now.difference(last) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }
    SystemNavigator.pop();
  }

  /// Drops the stored session so the next launch starts at login again.
  Future<void> _logout() async {
    await SessionStore.instance.clear();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: _buildShell(context),
    );
  }

  Widget _buildShell(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          const CartScreen(),
          const OrdersScreen(),
          ProfileScreen(onLogout: _logout),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              heroTag: 'home-list-machine-fab',
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.sellMachine),
              tooltip: 'Sell your machine',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => _select(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _TabIcon(
                            icon: i == _index
                                ? _tabs[i].active
                                : _tabs[i].inactive,
                            selected: i == _index,
                            // Index 2 is the Cart tab.
                            showCartCount: i == 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: i == _index
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: i == _index
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tab glyph that carries the live cart count on the Cart tab.
class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.selected,
    required this.showCartCount,
  });

  final IconData icon;
  final bool selected;
  final bool showCartCount;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      icon,
      size: 22,
      color: selected ? AppColors.accent : AppColors.textSecondary,
    );

    if (!showCartCount) return glyph;

    return ListenableBuilder(
      listenable: CartStore.instance,
      builder: (context, child) {
        final count = CartStore.instance.count;
        if (count == 0) return child!;
        return Badge(
          label: Text('$count'),
          backgroundColor: AppColors.accent,
          child: child,
        );
      },
      child: glyph,
    );
  }
}

class _TabItem {
  const _TabItem(this.inactive, this.active, this.label);

  final IconData inactive;
  final IconData active;
  final String label;
}
