import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/api_client.dart';

/// Draws a machine photo no matter where it lives.
///
/// Every uploaded image and document is stored by the panel and served back
/// over `/uploads/…` or `/api/files/<id>`, so the source is worked out from the
/// path instead of at each call site. Bundled assets are only a fallback for
/// when the server cannot be reached.
class AppImage extends StatelessWidget {
  const AppImage(
    this.path, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final String path;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;

  /// Offline copies of the demo catalogue, keyed by the same file names.
  static const String _assetDir = 'assets/images/machines';

  /// Turns a stored path into something an [Image] can load.
  static String resolve(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('assets/')) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) return '${ApiClient.baseUrl}$trimmed';
    // A bare file name is an upload the server serves from /uploads.
    return '${ApiClient.baseUrl}/uploads/$trimmed';
  }

  /// Bundled stand-in for a database photo, matched on the file name.
  static String? _bundled(String path) {
    final name = path.split('/').last.split('?').first;
    if (name.isEmpty || !name.contains('.')) return null;
    return '$_assetDir/$name';
  }

  static bool _isRemote(String resolved) =>
      resolved.startsWith('http://') || resolved.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final source = resolve(path);

    Widget placeholder({bool busy = false}) => Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: busy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.precision_manufacturing, color: Colors.black26),
    );

    // Nothing stored: draw the placeholder rather than asking the image
    // pipeline to load an empty path and fail.
    if (source.isEmpty) return placeholder();

    final onError = errorBuilder ?? (context, error, stack) => placeholder();

    // Decode at roughly the size actually drawn. Seller photos are uploaded at
    // full resolution, and decoding those at native size is what makes long
    // lists stutter and, on cheaper phones, drop images entirely.
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final target = width ?? height;
    final cacheWidth = target == null || !target.isFinite
        ? null
        : math.max(1, (target * ratio).round());

    if (!_isRemote(source)) {
      return Image.asset(
        source,
        fit: fit,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        errorBuilder: onError,
      );
    }

    final fallback = _bundled(path);
    return Image.network(
      source,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.medium,
      // Keeps the previous frame while a new URL loads, instead of flashing.
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder(busy: true),
      // A demo photo the app already ships stands in while offline.
      errorBuilder: fallback == null
          ? onError
          : (context, error, stack) => Image.asset(
              fallback,
              fit: fit,
              width: width,
              height: height,
              cacheWidth: cacheWidth,
              errorBuilder: onError,
            ),
    );
  }
}
