import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import 'brand_logo.dart';

/// Shared marketplace app bar — logo + wordmark on the left, a notification
/// bell and (optionally) the signed-in user's avatar on the right.
class MachSetuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MachSetuAppBar({
    super.key,
    this.onNotifications,
    this.onAvatarTap,
    this.showAvatar = false,
    this.initials = 'JD',
  });

  final VoidCallback? onNotifications;
  final VoidCallback? onAvatarTap;
  final bool showAvatar;
  final String initials;

  /// Sized to the logo mark itself — no dead space above or below it.
  static const double height = 54;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: height,
      titleSpacing: 12,
      title: const Row(
        children: [
          BrandLogo(size: 52),
          SizedBox(width: 1),
          // Flexible lets the wordmark artwork shrink instead of overflowing
          // when a back button squeezes the title slot.
          Flexible(
            child: BrandTextLogo(
              width: 140,
              assetPath: BrandTextLogo.appBarAsset,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          // Defaults to the notification centre so every screen's bell works
          // without each one wiring it up.
          onPressed: onNotifications ??
              () => Navigator.of(context).pushNamed(AppRoutes.notifications),
          icon: const Badge(
            backgroundColor: AppColors.accent,
            smallSize: 8,
            child: Icon(Icons.notifications_none_rounded),
          ),
        ),
        if (showAvatar) ...[
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.navy,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
        ] else
          const SizedBox(width: 6),
      ],
    );
  }
}
