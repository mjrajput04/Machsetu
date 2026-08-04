import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ActivityLog {
  const ActivityLog({
    required this.title,
    required this.detail,
    required this.stamp,
    required this.icon,
    required this.color,
  });

  final String title;
  final String detail;
  final String stamp;
  final IconData icon;
  final Color color;
}

/// Demo account details until the profile API is connected. The display name
/// is overridden by the stored session when the user registered with one.
class ProfileData {
  ProfileData._();

  static const String role = 'Senior Procurement Director';
  static const String company = 'Aerotech Solutions Inc.';
  static const String memberId = 'ID: MS-88291-P';
  static const String verification = 'Verified GST Registered Enterprise';
  static const String fallbackName = 'Marcus V. Sterling';

  static const int activeOrders = 12;
  static const String activeOrdersNote =
      '9 pending/scheduled orders from engineering team';

  static const List<ActivityLog> logs = [
    ActivityLog(
      title: 'Quote Requested',
      detail: 'High-speed spindle assembly #BXG-115',
      stamp: '2 hours ago',
      icon: Icons.request_quote_outlined,
      color: AppColors.accent,
    ),
    ActivityLog(
      title: 'Security Update',
      detail: 'Password successfully updated',
      stamp: 'Yesterday',
      icon: Icons.check_circle_outline,
      color: AppColors.brandBlue,
    ),
  ];
}
