import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/machsetu_app_bar.dart';
import 'data/order.dart';

/// Order pipeline — open inquiries on top, closed orders underneath.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  /// null shows everything; otherwise only orders in this status.
  OrderStatus? _filter;

  void _todo(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — coming soon')),
    );
  }

  List<Order> _apply(List<Order> orders) {
    final filter = _filter;
    if (filter == null) return orders;
    return orders.where((o) => o.status == filter).toList();
  }

  Future<void> _pickFilter() async {
    final selected = await showModalBottomSheet<Object?>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        // The status list is taller than a default sheet on short screens.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filter by Status',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, size: 20),
              title: const Text('All statuses'),
              selected: _filter == null,
              selectedColor: AppColors.accent,
              onTap: () => Navigator.of(sheetContext).pop('all'),
            ),
            for (final status in OrderStatus.values)
              ListTile(
                leading: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: status.foreground,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(status.label),
                selected: _filter == status,
                selectedColor: AppColors.accent,
                onTap: () => Navigator.of(sheetContext).pop(status),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (selected == null) return;
    setState(() => _filter = selected == 'all' ? null : selected as OrderStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MachSetuAppBar(
        onNotifications: () => _todo('Notifications'),
        onAvatarTap: () => _todo('Profile'),
        showAvatar: true,
      ),
      body: ListenableBuilder(
        listenable: OrderStore.instance,
        builder: (context, _) {
          final store = OrderStore.instance;
          final active = _apply(store.active);
          final history = _apply(store.history);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              const Text(
                'Orders & Inquiries',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage your industrial equipment procurement pipeline.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _FilterButton(
                    label: _filter?.label ?? 'Filter by Status',
                    active: _filter != null,
                    onTap: _pickFilter,
                    onClear: _filter == null
                        ? null
                        : () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        minimumSize: const Size.fromHeight(46),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.machines),
                      icon: const Icon(Icons.add, size: 19),
                      label: const Text(
                        'New Inquiry',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              if (active.isEmpty && history.isEmpty)
                _NoOrders(filtered: _filter != null)
              else ...[
                if (active.isNotEmpty) ...[
                  const _SectionLabel('ACTIVE INQUIRIES', showDot: true),
                  const SizedBox(height: 14),
                  for (final order in active) ...[
                    _OrderCard(
                      order: order,
                      onPrimary: () => Navigator.of(context).pushNamed(
                        AppRoutes.orderTracking,
                        arguments: order,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const SizedBox(height: 14),
                ],
                if (history.isNotEmpty) ...[
                  const _SectionLabel('ORDER HISTORY'),
                  const SizedBox(height: 14),
                  for (final order in history) ...[
                    _OrderCard(
                      order: order,
                      onPrimary: () => order.status == OrderStatus.delivered
                          ? _todo('Re-order ${order.title}')
                          : OrderStore.instance.remove(order),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.showDot = false});

  final String text;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showDot) ...[
          Container(
            height: 8,
            width: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: EdgeInsets.only(left: 16, right: active ? 8 : 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.border.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.accentDark : AppColors.textSecondary,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.close,
                    size: 17,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onPrimary});

  final Order order;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final closed = order.status.isClosed;

    final (actionLabel, actionIcon) = switch (order.status) {
      OrderStatus.delivered => ('Re-order', Icons.refresh),
      OrderStatus.cancelled => ('Archive', Icons.archive_outlined),
      _ => ('View Details', Icons.chevron_right),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(order: order),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        order.title,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: closed &&
                                  order.status == OrderStatus.delivered
                              ? AppColors.textPrimary
                              : AppColors.brandBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StatusPill(status: order.status),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _Meta(
                      icon: Icons.calendar_today_outlined,
                      label: order.placedOn,
                    ),
                    if (order.note != null)
                      _Meta(
                        icon: order.status == OrderStatus.cancelled
                            ? Icons.info_outline
                            : Icons.verified_outlined,
                        label: order.note!,
                      )
                    else
                      _Meta(
                        icon: Icons.place_outlined,
                        label: order.location,
                      ),
                  ],
                ),
                if (!closed) ...[
                  const SizedBox(height: 8),
                  _Meta(
                    icon: Icons.tag,
                    label: order.reference.replaceFirst('#', ''),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: onPrimary,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: closed ? AppColors.textSecondary : AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    actionIcon,
                    size: 17,
                    color: closed ? AppColors.textSecondary : AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final image = order.thumbnail;

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        height: 58,
        width: 58,
        child: image == null
            ? _fallback()
            : Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.machineGradient),
      child: Icon(
        order.icon,
        size: 24,
        color: AppColors.navy.withValues(alpha: 0.4),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.5,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: status.foreground,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _NoOrders extends StatelessWidget {
  const _NoOrders({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 34,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            filtered ? 'Nothing in this status' : 'No orders yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              filtered
                  ? 'Try a different status filter.'
                  : 'Placed inquiries appear here so you can track every '
                        'milestone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
