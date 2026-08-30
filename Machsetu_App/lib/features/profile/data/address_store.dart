import 'package:flutter/foundation.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/session_store.dart';

/// One saved delivery / installation address.
@immutable
class SavedAddress {
  const SavedAddress({
    this.id = '',
    this.label = 'Address',
    this.contactName = '',
    this.contactPhone = '',
    this.line1 = '',
    this.line2 = '',
    this.landmark = '',
    this.city = '',
    this.state = '',
    this.zip = '',
    this.isDefault = false,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    String text(String key) => json[key]?.toString() ?? '';
    return SavedAddress(
      id: text('id'),
      label: text('label').isEmpty ? 'Address' : text('label'),
      contactName: text('contactName'),
      contactPhone: text('contactPhone'),
      line1: text('line1'),
      line2: text('line2'),
      landmark: text('landmark'),
      city: text('city'),
      state: text('state'),
      zip: text('zip'),
      isDefault: json['isDefault'] == true,
    );
  }

  final String id;
  final String label;
  final String contactName;
  final String contactPhone;
  final String line1;
  final String line2;
  final String landmark;
  final String city;
  final String state;
  final String zip;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
    if (id.isNotEmpty) 'id': id,
    'label': label,
    'contactName': contactName,
    'contactPhone': contactPhone,
    'line1': line1,
    'line2': line2,
    'landmark': landmark,
    'city': city,
    'state': state,
    'zip': zip,
    'isDefault': isDefault,
  };

  /// Single-line rendering for a summary row or an order's shipping block.
  String get oneLine => [
    line1,
    line2,
    landmark,
    city,
    state,
    zip,
  ].where((p) => p.trim().isNotEmpty).join(', ');

  /// Multi-line rendering for the address card.
  String get multiLine {
    final street = [
      line1,
      line2,
      landmark,
    ].where((p) => p.trim().isNotEmpty).join(', ');
    final region = [city, state].where((p) => p.trim().isNotEmpty).join(', ');
    return [
      street,
      [region, zip].where((p) => p.trim().isNotEmpty).join(' - '),
    ].where((p) => p.trim().isNotEmpty).join('\n');
  }
}

/// Result of an address mutation — the refreshed list, or a message to show.
class AddressResult {
  const AddressResult.success(this.addresses) : ok = true, message = null;

  const AddressResult.failure(this.message) : ok = false, addresses = const [];

  final bool ok;
  final List<SavedAddress> addresses;
  final String? message;
}

/// Reads and writes the signed-in user's saved addresses.
///
/// The list is cached in memory so the checkout screen and the addresses page
/// agree without each one hitting the network.
class AddressStore extends ChangeNotifier {
  AddressStore._();

  static final AddressStore instance = AddressStore._();

  static const String _endpoint = '/api/addresses';

  List<SavedAddress> _addresses = const [];
  bool _loaded = false;

  List<SavedAddress> get addresses => List.unmodifiable(_addresses);

  bool get isEmpty => _addresses.isEmpty;

  bool get isLoaded => _loaded;

  /// The address an order should default to, or null when none is saved.
  SavedAddress? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  void _apply(List<dynamic> raw) {
    _addresses = raw
        .whereType<Map<String, dynamic>>()
        .map(SavedAddress.fromJson)
        .toList();
    _loaded = true;
    notifyListeners();
  }

  Future<AddressResult> load({bool force = false}) async {
    if (_loaded && !force) return AddressResult.success(addresses);

    final token = await SessionStore.instance.token();
    if (token == null) return const AddressResult.failure('Please sign in');

    final result = await ApiClient.instance.get(_endpoint, token: token);
    if (!result.ok) return AddressResult.failure(result.message);

    _apply(result.data['addresses'] as List<dynamic>? ?? const []);
    return AddressResult.success(addresses);
  }

  Future<AddressResult> add(SavedAddress address) async {
    final token = await SessionStore.instance.token();
    if (token == null) return const AddressResult.failure('Please sign in');

    final result = await ApiClient.instance.post(
      _endpoint,
      body: address.toJson(),
      token: token,
    );
    if (!result.ok) return AddressResult.failure(result.message);

    _apply(result.data['addresses'] as List<dynamic>? ?? const []);
    return AddressResult.success(addresses);
  }

  Future<AddressResult> update(SavedAddress address) async {
    if (address.id.isEmpty) {
      return const AddressResult.failure('That address cannot be edited');
    }
    final token = await SessionStore.instance.token();
    if (token == null) return const AddressResult.failure('Please sign in');

    final result = await ApiClient.instance.put(
      _endpoint,
      body: address.toJson(),
      token: token,
    );
    if (!result.ok) return AddressResult.failure(result.message);

    _apply(result.data['addresses'] as List<dynamic>? ?? const []);
    return AddressResult.success(addresses);
  }

  /// Promotes [id] to the default without touching its other fields.
  Future<AddressResult> makeDefault(String id) async {
    final token = await SessionStore.instance.token();
    if (token == null) return const AddressResult.failure('Please sign in');

    final result = await ApiClient.instance.put(
      _endpoint,
      body: {'id': id, 'isDefault': true},
      token: token,
    );
    if (!result.ok) return AddressResult.failure(result.message);

    _apply(result.data['addresses'] as List<dynamic>? ?? const []);
    return AddressResult.success(addresses);
  }

  Future<AddressResult> remove(String id) async {
    final token = await SessionStore.instance.token();
    if (token == null) return const AddressResult.failure('Please sign in');

    final result = await ApiClient.instance.delete(
      '$_endpoint?id=$id',
      token: token,
    );
    if (!result.ok) return AddressResult.failure(result.message);

    _apply(result.data['addresses'] as List<dynamic>? ?? const []);
    return AddressResult.success(addresses);
  }

  /// Drops the cache on sign-out so the next account starts clean.
  void reset() {
    _addresses = const [];
    _loaded = false;
    notifyListeners();
  }
}
