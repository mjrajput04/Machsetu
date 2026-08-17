import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/shell_tabs.dart';
import '../../core/theme/app_colors.dart';
import 'data/order.dart';

/// Confirmation shown once an order leaves the checkout.
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  void _backToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ShellTabs.go(ShellTabs.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Confirmation is a dead end until the buyer picks an action, so the
      // system back gesture behaves like "Back to Home".
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _backToHome(context);
        },
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
            children: [
              const Center(child: _SuccessBadge()),
              const SizedBox(height: 34),
              const Text(
                'Order Submitted Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 20),
              _ReferencePill(reference: order.reference),
              const SizedBox(height: 26),
              _ThankYouCard(order: order),
              const SizedBox(height: 30),
              _FactRow(
                icon: Icons.precision_manufacturing_outlined,
                label: 'EQUIPMENT TYPE',
                value: order.equipmentType,
              ),
              const SizedBox(height: 12),
              _FactRow(
                icon: Icons.local_shipping_outlined,
                label: 'LOGISTICS MODE',
                value: order.logisticsMode,
              ),
              const SizedBox(height: 34),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.orderTracking, arguments: order),
                icon: const Icon(Icons.track_changes, size: 20),
                label: const Text(
                  'Track Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: AppColors.navy,
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _backToHome(context),
                icon: const Icon(Icons.home_outlined, size: 20),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 44),
              const _TrustFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navy disc inside a soft halo, with dial ticks around the rim.
class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      width: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
          CustomPaint(size: const Size(168, 168), painter: _TickPainter()),
          Container(
            height: 144,
            width: 144,
            decoration: BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 62,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.steelLight.withValues(alpha: 0.9)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    // Four short arcs at the diagonals, like a machined dial.
    for (var i = 0; i < 4; i++) {
      canvas.drawArc(rect, (0.55 + i * 1.5708), 0.46, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReferencePill extends StatelessWidget {
  const _ReferencePill({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'ORDER REFERENCE:',
              style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              reference,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThankYouCard extends StatelessWidget {
  const _ThankYouCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 15,
            height: 1.7,
            color: AppColors.textPrimary,
          ),
          children: const [
            TextSpan(
              text:
                  'Thank you for choosing MachSetu. Your request has been '
                  'queued for fulfillment. A specialized industrial broker '
                  'will review your technical requirements and contact you '
                  'within ',
            ),
            TextSpan(
              text: '24 hours',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: ' to finalize logistics.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.scaffold,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: AppColors.navy),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
            child: _TrustItem(
              icon: Icons.shield_outlined,
              label: 'ISO 9001\nCERTIFIED',
            ),
          ),
          Container(width: 1, color: AppColors.border),
          const Expanded(
            child: _TrustItem(
              icon: Icons.lock_outline,
              label: 'ENCRYPTED\nMANIFEST',
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
