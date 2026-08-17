import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_image.dart';
import 'data/notification_store.dart';
import 'data/notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _store = NotificationStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
    _store.load(force: true);
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  void _todo(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _store.markAllRead,
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          const Text(
            'Notification Center',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your industrial procurement alerts and machine status.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const _GroupLabel('TODAY'),
          const SizedBox(height: 12),
          for (final item in _store.today) ...[
            _NotificationCard(
              item: item,
              onAction: (label) => _todo(context, label),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 14),
          const _GroupLabel('EARLIER'),
          const SizedBox(height: 12),
          for (final item in _store.earlier) ...[
            _NotificationCard(
              item: item,
              onAction: (label) => _todo(context, label),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11.5,
        letterSpacing: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onAction});

  final AppNotification item;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final image = item.image;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        // Unread rows get an accent edge so they read at a glance.
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (item.unread) Container(width: 4, color: AppColors.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (image != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: SizedBox(
                          height: 118,
                          width: double.infinity,
                          child: AppImage(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _iconTile(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (image == null) ...[
                          _iconTile(),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.stamp,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in item.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.scaffold,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (item.primaryAction != null) ...[
                      const SizedBox(height: 14),
                      // Wrap so the secondary action drops to a second line
                      // instead of overflowing on narrow handsets.
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => onAction(item.primaryAction!),
                            child: Text(
                              item.primaryAction!,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (item.secondaryAction != null)
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                              ),
                              onPressed: () => onAction(item.secondaryAction!),
                              child: Text(item.secondaryAction!),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconTile() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: item.tint.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(item.icon, size: 20, color: item.tint),
    );
  }
}
