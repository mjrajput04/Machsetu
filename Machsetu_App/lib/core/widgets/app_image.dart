import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/api_client.dart';

/// Draws a machine photo no matter where it lives.
///
/// Every uploaded image is stored by the panel and served back over
/// `/uploads/…` or `/api/files/<id>`, so the source is worked out from the path
/// instead of at each call site.
///
/// A photo that will not load falls back to a neutral placeholder and never to
/// another machine's picture: substituting a lookalike would show a buyer
/// equipment that is not the one they are looking at.
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

  static bool _isRemote(String resolved) =>
      resolved.startsWith('http://') || resolved.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final source = resolve(path);

    // Deliberately static: a grid of spinning indicators is noisier than a
    // quiet block, and a continuous animation never lets a test settle.
    Widget placeholder({bool busy = false}) => Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: busy
          ? null
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
      errorBuilder: onError,
    );
  }
}
