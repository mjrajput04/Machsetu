import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'session_store.dart';

/// Sends seller photos to the admin panel and hands back their public paths.
///
/// Files land in the panel's `/uploads` folder, so the same photo the seller
/// picks is what the sourcing desk and buyers see.
class UploadService {
  UploadService._();

  static final UploadService instance = UploadService._();

  final ImagePicker _picker = ImagePicker();

  /// Opens the gallery and uploads whatever the seller picks.
  ///
  /// Returns the stored paths, or an empty list if they cancelled. [limit]
  /// caps the selection so the wizard's ten-photo rule holds.
  Future<List<String>> pickAndUpload({int limit = 10}) async {
    // No compression and no downscale: a buyer judging a machine needs the
    // full-resolution photo the seller actually took.
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return const [];

    final files = picked.take(limit).toList();
    final uploaded = <String>[];
    for (final file in files) {
      final url = await upload(file);
      if (url != null) uploaded.add(url);
    }
    return uploaded;
  }

  /// Picks a single photo from [source] and uploads it.
  ///
  /// Returns the stored path, or null when they cancelled or the send failed.
  Future<String?> pickOneAndUpload({
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      // A profile photo is only ever shown small, so this one is trimmed.
      imageQuality: 92,
      maxWidth: 1600,
    );
    if (picked == null) return null;
    return upload(picked);
  }

  /// Opens the file browser for a document and uploads what they choose.
  ///
  /// Returns the stored path and the human-readable size, or null on cancel.
  Future<({String url, String name, String size})?>
  pickDocumentAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    final file = picked?.files.singleOrNull;
    if (file == null) return null;

    final bytes = file.bytes;
    if (bytes == null) return null;

    final url = await uploadBytes(bytes, file.name);
    if (url == null) return null;
    return (url: url, name: file.name, size: readableSize(bytes.length));
  }

  /// "1.4 MB", as the document list shows it.
  static String readableSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).round()} KB';
  }

  /// Uploads one already-picked file. Returns null when the send fails.
  Future<String?> upload(XFile file) async =>
      uploadBytes(await file.readAsBytes(), file.name);

  /// Sends raw bytes, whichever picker produced them.
  Future<String?> uploadBytes(Uint8List bytes, String filename) async {
    final token = await SessionStore.instance.token();
    if (token == null) return null;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiClient.baseUrl}/api/upload'),
      )..headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: _contentType(filename),
        ),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final body = await response.stream.bytesToString();
      if (response.statusCode >= 400) return null;

      // The panel answers with { ok: true, url: "/uploads/…" }.
      final match = RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(body);
      return match?.group(1);
    } catch (error) {
      debugPrint('Upload failed: $error');
      return null;
    }
  }

  static MediaType? _contentType(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.pdf')) return MediaType('application', 'pdf');
    return MediaType('image', 'jpeg');
  }
}
