import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/session_store.dart';
import '../../core/services/shell_tabs.dart';
import '../../core/theme/app_colors.dart';
import '../cart/cart_screen.dart';
import '../cart/data/cart_store.dart';
import '../orders/orders_screen.dart';
import '../search/search_screen.dart';
import 'home_screen.dart';

/// Bottom-navigation container that hosts the marketplace tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = ShellTabs.selected.value;

  @override
  void initState() {
    super.initState();
    ShellTabs.selected.addListener(_onTabRequested);
  }

  @override
  void dispose() {
    ShellTabs.selected.removeListener(_onTabRequested);
    super.dispose();
  }

  /// Another screen asked for a tab — e.g. "View Cart" from the product page.
  void _onTabRequested() {
    if (!mounted) return;
    setState(() => _index = ShellTabs.selected.value);
  }

  void _select(int index) {
    ShellTabs.selected.value = index;
    setState(() => _index = index);
  }

  static const List<_TabItem> _tabs = [
    _TabItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _TabItem(Icons.search, Icons.search, 'Search'),
    _TabItem(Icons.shopping_cart_outlined, Icons.shopping_cart, 'Cart'),
    _TabItem(Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
    _TabItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  /// Drops the stored session so the next launch starts at login again.
  Future<void> _logout() async {
    await SessionStore.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          const CartScreen(),
          const OrdersScreen(),
          _ProfileTab(onLogout: _logout),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              heroTag: 'home-list-machine-fab',
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('List a machine — coming soon')),
              ),
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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.bannerGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Industrial Partner',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Verified buyer • Since 2026',
                        style: TextStyle(fontSize: 12.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final item in const [
            (Icons.business_outlined, 'Company Details'),
            (Icons.favorite_border, 'Saved Machines'),
            (Icons.local_shipping_outlined, 'Logistics Partners'),
            (Icons.help_outline, 'Help & Support'),
          ])
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: Icon(item.$1, color: AppColors.navy, size: 20),
                title: Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.$2} — coming soon')),
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onLogout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
