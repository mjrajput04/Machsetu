import 'package:flutter/material.dart';

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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: const Row(
        children: [
          BrandLogo(size: 30),
          SizedBox(width: 10),
          BrandWordmark(fontSize: 16, letterSpacing: 0.8),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onNotifications,
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
