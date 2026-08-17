import 'package:flutter/material.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/session_store.dart';
import '../../cart/data/cart_store.dart';
import '../../product/data/product.dart';
import 'order.dart';

/// Talks to the orders API on the seller's behalf.
///
/// Placing an order and reading the history both go through here, so the
/// Orders tab shows what the sourcing desk actually has on file rather than
/// whatever this device happens to remember.
class OrderApi {
  OrderApi._();

  /// Sends the cart to the desk.
  ///
  /// Returns the order reference on success, or the message to show the buyer
  /// when it could not be filed.
  static Future<({String? reference, String? error})> place(
    CartStore cart, {
    required String destination,
    Map<String, dynamic> customer = const {},
  }) async {
    final token = await SessionStore.instance.token();
    if (token == null) {
      return (reference: null, error: 'Sign in to place an order');
    }

    final result = await ApiClient.instance.post(
      '/api/orders',
      token: token,
      body: {
        'destination': destination,
        // Everything the buyer typed on the checkout form, so the desk can
        // raise the invoice and book the freight without chasing them.
        'customer': customer,
        'subtotal': cart.subtotal,
        'freight': cart.freight,
        'gst': cart.gst,
        'total': cart.total,
        'items': [
          for (final item in cart.items)
            {
              'productId': item.product.id,
              'title': item.product.title,
              'brand': item.product.brand,
              'equipmentType': item.product.equipmentType,
              'image': item.product.images.isEmpty
                  ? null
                  : item.product.images.first,
              'unitPrice': item.product.amount,
              'quantity': item.quantity,
            },
        ],
      },
    );

    if (!result.ok) return (reference: null, error: result.message);
    return (reference: result.data['reference']?.toString(), error: null);
  }

  /// Everything this buyer has ordered, newest first.
  static Future<List<Order>?> mine() async {
    final token = await SessionStore.instance.token();
    if (token == null) return null;

    final result = await ApiClient.instance.get('/api/orders', token: token);
    if (!result.ok) return null;

    final raw = result.data['orders'];
    if (raw is! List) return null;
    return raw.whereType<Map<String, dynamic>>().map(_fromJson).toList();
  }
}

/* ------------------------------------------------------------- mapping -- */

String _text(dynamic value) => value == null ? '' : value.toString();

double _amount(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

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

String _date(dynamic value) {
  final parsed = DateTime.tryParse(_text(value));
  if (parsed == null) return _text(value);
  return '${_months[parsed.month - 1]} '
      '${parsed.day.toString().padLeft(2, '0')}, ${parsed.year}';
}

/// The desk's stage names, mapped onto the badge the app already draws.
OrderStatus _statusFrom(String stage) => switch (stage) {
  'Inquiry Received' => OrderStatus.inquiryReceived,
  'Under Review' => OrderStatus.underReview,
  'Broker Contacting You' => OrderStatus.brokerContact,
  'Order Confirmed' || 'Price Confirmed' || 'Machine Reserved' =>
    OrderStatus.confirmed,
  'Delivered' => OrderStatus.delivered,
  'Cancelled' => OrderStatus.cancelled,
  _ => OrderStatus.underReview,
};

Order _fromJson(Map<String, dynamic> json) {
  final rawItems = json['items'];
  final customer = json['customer'] is Map<String, dynamic>
      ? json['customer'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final items = <CartItem>[
    if (rawItems is List)
      for (final item in rawItems.whereType<Map<String, dynamic>>())
        CartItem(
          product: ProductCatalog.from(
            title: _text(item['title']),
            brand: _text(item['brand']),
            price: '₹${_amount(item['unitPrice']).round()}',
            equipmentType: _text(item['equipmentType']),
            id: _text(item['productId']),
            image: _text(item['image']).isEmpty ? null : _text(item['image']),
          ),
          quantity: item['quantity'] is int ? item['quantity'] as int : 1,
        ),
  ];

  final image = _text(json['image']);

  return Order(
    reference: _text(json['id']),
    placedOn: _date(json['placedOn']),
    title: _text(json['machine']),
    status: _statusFrom(_text(json['stage'])),
    location: _text(json['destination']),
    items: items,
    subtotal: _amount(json['subtotal']),
    freight: _amount(json['freight']),
    gst: _amount(json['gst']),
    total: _amount(json['amount']),
    equipmentType: _text(json['equipmentType']),
    logisticsMode: _text(json['logisticsMode']),
    thumbnail: image.isEmpty ? null : image,
    note: _text(json['note']).isEmpty ? null : _text(json['note']),
    stageIndex: json['stageIndex'] is int ? json['stageIndex'] as int : 1,
    deliveryAddress: _text(json['deliveryAddress']),
    contactName: _text(customer['name']),
    contactPhone: _text(customer['phone']),
    contactCompany: _text(customer['company']),
    contactGstin: _text(customer['gstin']),
    stages: OrderStore.instance.timelineStages(),
    icon: Icons.precision_manufacturing,
  );
}
