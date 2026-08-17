import 'package:flutter/material.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/session_store.dart';
import '../../../core/theme/app_colors.dart';
import 'notifications.dart';

/// The account's alerts, backed by the notifications API.
///
/// Rows are written by the server whenever something happens — an order
/// placed, a listing approved, a quote received — so the feed is a record of
/// real events. The bundled sample list stands in while offline.
class NotificationStore extends ChangeNotifier {
  NotificationStore._();

  static final NotificationStore instance = NotificationStore._();

  List<AppNotification> _today = NotificationData.today;
  List<AppNotification> _earlier = NotificationData.earlier;
  int _unread = 0;
  bool _loading = false;
  bool _loadedOnce = false;

  List<AppNotification> get today => _today;
  List<AppNotification> get earlier => _earlier;
  int get unread => _unread;
  bool get isLive => _loadedOnce;

  Future<void> load({bool force = false}) async {
    final token = await SessionStore.instance.token();
    if (token == null || _loading || (_loadedOnce && !force)) return;

    // Set without notifying — load() runs from initState.
    _loading = true;

    final result = await ApiClient.instance.get(
      '/api/notifications',
      token: token,
    );
    if (result.ok) {
      final raw = result.data['notifications'];
      if (raw is List) {
        final rows = raw.whereType<Map<String, dynamic>>().toList();
        final now = DateTime.now();

        _today = [
          for (final row in rows)
            if (_isToday(row['createdAt'], now)) _fromJson(row),
        ];
        _earlier = [
          for (final row in rows)
            if (!_isToday(row['createdAt'], now)) _fromJson(row),
        ];
        _unread = result.data['unread'] is int
            ? result.data['unread'] as int
            : 0;
        _loadedOnce = true;
      }
    }

    _loading = false;
    notifyListeners();
  }

  /// Clears the unread stripe once the buyer has seen the list.
  Future<void> markAllRead() async {
    final token = await SessionStore.instance.token();
    if (token == null || _unread == 0) return;

    await ApiClient.instance.put('/api/notifications', token: token);
    _unread = 0;
    notifyListeners();
  }

  static bool _isToday(dynamic value, DateTime now) {
    final at = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (at == null) return false;
    return at.year == now.year && at.month == now.month && at.day == now.day;
  }
}

/* ------------------------------------------------------------- mapping -- */

String _text(dynamic value) => value == null ? '' : value.toString();

/// Icon and tint per event kind, matching the sample feed's visual language.
(IconData, Color) _look(String kind) => switch (kind) {
  'order' => (Icons.local_shipping_outlined, AppColors.success),
  'listing' => (Icons.sell_outlined, AppColors.accent),
  'inquiry' => (Icons.request_quote_outlined, AppColors.brandBlue),
  'account' => (Icons.person_outline, AppColors.brandBlue),
  _ => (Icons.notifications_none, AppColors.navy),
};

/// "12 min ago", "3 h ago", "5 d ago" — the stamp the card prints.
String _stamp(dynamic value) {
  final at = DateTime.tryParse(_text(value))?.toLocal();
  if (at == null) return '';

  final gap = DateTime.now().difference(at);
  if (gap.inMinutes < 1) return 'Just now';
  if (gap.inMinutes < 60) return '${gap.inMinutes} min ago';
  if (gap.inHours < 24) return '${gap.inHours} h ago';
  if (gap.inDays < 7) return '${gap.inDays} d ago';
  return '${(gap.inDays / 7).floor()} w ago';
}

AppNotification _fromJson(Map<String, dynamic> json) {
  final (icon, tint) = _look(_text(json['kind']));
  final image = _text(json['image']);
  final reference = _text(json['reference']);

  return AppNotification(
    title: _text(json['title']),
    body: _text(json['body']),
    stamp: _stamp(json['createdAt']),
    icon: icon,
    tint: tint,
    image: image.isEmpty ? null : image,
    tags: reference.isEmpty ? const [] : [reference],
    unread: json['read'] != true,
  );
}
