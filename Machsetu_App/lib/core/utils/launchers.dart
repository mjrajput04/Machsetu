import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hands an action off to the phone: dialler, mail client, WhatsApp, browser.
///
/// Every helper reports failure through a snackbar rather than failing
/// silently, so a device without a mail client says so instead of doing
/// nothing when the user taps.
class Launchers {
  Launchers._();

  /// Digits only, with the country code India uses.
  static String _msisdn(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '91$digits';
    return digits;
  }

  static Future<void> call(BuildContext context, String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    await _open(
      context,
      Uri.parse('tel:$digits'),
      'No dialler available on this device',
    );
  }

  static Future<void> email(
    BuildContext context,
    String address, {
    String subject = '',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      query: [
        if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
        if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
      ].join('&'),
    );
    await _open(context, uri, 'No email app is set up on this device');
  }

  /// Opens a WhatsApp conversation, falling back to the browser build.
  static Future<void> whatsapp(
    BuildContext context,
    String phone, {
    String message = '',
  }) async {
    final target = _msisdn(phone);
    final query = message.isEmpty
        ? ''
        : '?text=${Uri.encodeComponent(message)}';
    final uri = Uri.parse('https://wa.me/$target$query');
    await _open(context, uri, 'Could not open WhatsApp');
  }

  static Future<void> url(BuildContext context, String href) async {
    final uri = Uri.tryParse(href);
    if (uri == null) {
      _toast(context, 'That link is not valid');
      return;
    }
    await _open(context, uri, 'Could not open that link');
  }

  /// Copies [value] and confirms it, for share actions with nowhere to go.
  static Future<void> copy(
    BuildContext context,
    String value, {
    String label = 'Copied to clipboard',
  }) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    _toast(context, label);
  }

  static Future<void> _open(
    BuildContext context,
    Uri uri,
    String failureMessage,
  ) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) _toast(context, failureMessage);
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
