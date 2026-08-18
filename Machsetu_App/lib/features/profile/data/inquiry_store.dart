import 'package:flutter/material.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/session_store.dart';
import 'inquiries.dart';

/// The buyer's RFQs, backed by the inquiries API.
class InquiryStore extends ChangeNotifier {
  InquiryStore._();

  static final InquiryStore instance = InquiryStore._();

  List<Inquiry> _all = const [];
  bool _loading = false;
  bool _loadedOnce = false;

  List<Inquiry> get all => _all;
  List<Inquiry> get open => _all.where((i) => i.isOpen).toList();
  List<Inquiry> get closed => _all.where((i) => !i.isOpen).toList();
  bool get isLive => _loadedOnce;

  /// Fills the list without a round trip. Tests only.
  @visibleForTesting
  void seed(List<Inquiry> rows) {
    _all = rows;
    _loadedOnce = true;
  }

  Future<void> load({bool force = false}) async {
    final token = await SessionStore.instance.token();
    if (token == null || _loading || (_loadedOnce && !force)) return;

    // Set without notifying — load() runs from initState.
    _loading = true;

    final result = await ApiClient.instance.get(
      '/api/inquiries',
      token: token,
    );
    if (result.ok) {
      final raw = result.data['inquiries'];
      if (raw is List) {
        _all = raw.whereType<Map<String, dynamic>>().map(_fromJson).toList();
        _loadedOnce = true;
      }
    }

    _loading = false;
    notifyListeners();
  }
}

/* ------------------------------------------------------------- mapping -- */

String _text(dynamic value) => value == null ? '' : value.toString();

/// Console status strings mapped onto the app's own lifecycle.
InquiryStatus _statusFrom(String value) => switch (value) {
  'Quote Received' => InquiryStatus.quoted,
  'Negotiating' => InquiryStatus.negotiating,
  'Closed' || 'Lost' => InquiryStatus.closed,
  'Expired' => InquiryStatus.expired,
  _ => InquiryStatus.awaitingQuote,
};

/// Indian lakh/crore grouping, matching every other price in the app.
String? _price(dynamic value) {
  final digits = _text(value).replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  if (digits.length <= 3) return '₹$digits';

  final last3 = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '₹${groups.join(',')},$last3';
}

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "2026-08-17" reads as "Aug 17, 2026" on the card.
String _date(dynamic value) {
  final raw = _text(value);
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return '${_months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
}

Inquiry _fromJson(Map<String, dynamic> json) {
  final specs = json['specs'];
  final image = _text(json['image']);

  return Inquiry(
    reference: _text(json['id']),
    machine: _text(json['machine']),
    brand: _text(json['brand']),
    submittedOn: _date(json['raisedOn']),
    status: _statusFrom(_text(json['status'])),
    specs: specs is List
        ? specs.map(_text).where((s) => s.isNotEmpty).toList()
        : const [],
    quotedPrice: _price(json['quoted']),
    responseNote: _text(json['responseNote']).isEmpty
        ? null
        : _text(json['responseNote']),
    image: image.isEmpty ? null : image,
  );
}
