import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// White form card with the navy accent bar along its top edge.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 8, color: AppColors.navy),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: child,
          ),
        ],
      ),
    );
  }
}
