import 'package:flutter/material.dart';

import '../services/api_client.dart';

/// Draws a machine photo no matter where it lives.
///
/// Every uploaded image and document is stored in the database and served
/// back through `/api/files/<id>`, so the source is worked out from the path
/// instead of at each call site. Bundled assets are only a fallback for when
/// the server cannot be reached.
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
    if (path.isEmpty) return path;
    if (path.startsWith('assets/')) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '${ApiClient.baseUrl}$path';
    return path;
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

    Widget placeholder() => Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.precision_manufacturing, color: Colors.black26),
    );

    final onError =
        errorBuilder ?? (context, error, stack) => placeholder();

    if (!_isRemote(source)) {
      return Image.asset(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: onError,
      );
    }

    final fallback = _bundled(path);
    return Image.network(
      source,
      fit: fit,
      width: width,
      height: height,
      // A demo photo the app already ships stands in while offline.
      errorBuilder: fallback == null
          ? onError
          : (context, error, stack) => Image.asset(
              fallback,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: onError,
            ),
    );
  }
}
