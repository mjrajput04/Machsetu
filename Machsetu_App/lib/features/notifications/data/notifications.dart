import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppNotification {
  const AppNotification({
    required this.title,
    required this.body,
    required this.stamp,
    required this.icon,
    required this.tint,
    this.image,
    this.tags = const [],
    this.primaryAction,
    this.secondaryAction,
    this.unread = false,
  });

  final String title;
  final String body;
  final String stamp;
  final IconData icon;
  final Color tint;

  /// Listing alerts lead with a photo instead of an icon tile.
  final String? image;
  final List<String> tags;
  final String? primaryAction;
  final String? secondaryAction;

  /// Unread rows carry an accent stripe down the left edge.
  final bool unread;
}

/// Static feed until the notifications API is connected.
class NotificationData {
  NotificationData._();

  static const String _photos = 'assets/images/machines';

  static const List<AppNotification> today = [
    AppNotification(
      title: 'Inquiry Approved',
      body: 'Your RFQ for the 5-Axis Vertical Machining Center '
          '(Ref: CNC-8823) has been approved by the vendor.',
      stamp: '10:45 AM',
      icon: Icons.task_alt,
      tint: AppColors.brandBlue,
      primaryAction: 'View Quote',
      secondaryAction: 'Details',
      unread: true,
    ),
    AppNotification(
      title: 'Price Alert: CNC Tools — Pune Hub',
      body: 'A 15% price drop detected on bulk packages of ISO-standard '
          'milling inserts from authorized distributors.',
      stamp: '09:12 AM',
      icon: Icons.trending_down,
      tint: AppColors.danger,
    ),
    AppNotification(
      title: 'New Machine Listing',
      body: 'New Arrivals: Haas VF-2SS Super-Speed Vertical Machining Center '
          '(2022 Model) just added to the marketplace.',
      stamp: '07:30 AM',
      icon: Icons.precision_manufacturing_outlined,
      tint: AppColors.navy,
      image: '$_photos/haas_vf2ss.jpg',
      tags: ['VMC', 'Pre-owned', 'IN STOCK'],
    ),
  ];

  static const List<AppNotification> earlier = [
    AppNotification(
      title: 'Shipment Dispatched from Chennai Warehouse',
      body: 'Order #CNC-2 (Industrial Lubricants) has been picked up by the '
          'freight carrier.',
      stamp: 'Yesterday',
      icon: Icons.local_shipping_outlined,
      tint: AppColors.textSecondary,
    ),
    AppNotification(
      title: 'Stock Alert: Low Inventory',
      body: 'Hydraulic fluid level in Warehouse A is below threshold '
          '(12% remaining).',
      stamp: '2 days ago',
      icon: Icons.inventory_2_outlined,
      tint: AppColors.textSecondary,
    ),
  ];

  static int get unreadCount =>
      today.where((n) => n.unread).length +
      earlier.where((n) => n.unread).length;
}
