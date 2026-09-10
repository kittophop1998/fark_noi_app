import 'dart:io';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';

/// `MediaPurpose` on the wire — what a confirmed upload may be used for.
enum MediaPurpose {
  profileImage('PROFILE_IMAGE'),
  orderProof('ORDER_PROOF'),
  orderReference('ORDER_REFERENCE'),
  disputeEvidence('DISPUTE_EVIDENCE'),
  kycIdCard('KYC_ID_CARD'),
  homeBanner('HOME_BANNER'),
  storeImage('STORE_IMAGE');

  const MediaPurpose(this.wire);

  final String wire;
}

/// The three-step handshake every real upload in this app goes through:
/// `POST /media/upload-sessions` opens a presigned URL, the bytes go straight
/// to object storage on a bare `PUT`, and `POST /media/{id}/complete` is what
/// turns a PENDING upload into one an order or profile call may reference.
///
/// Nothing here is cached or retried beyond what Dio already does — a failed
/// step means the caller shows the runner their photo did not go through,
/// which is the honest outcome, rather than something silently standing in
/// for it.
class MediaUploadService {
  const MediaUploadService({required this.client});

  final DioClient client;

  Future<String> upload({
    required File file,
    required MediaPurpose purpose,
  }) async {
    final bytes = await file.readAsBytes();
    final contentType = _contentTypeOf(file.path);

    final session = await client.post(
      ApiEndpoints.mediaUploadSessions,
      data: {
        'purpose': purpose.wire,
        'contentType': contentType,
        'byteSize': bytes.length,
      },
    );
    final data = DioClient.unwrap(session);
    final mediaId = data['mediaId'] as String? ?? '';
    final uploadUrl = data['uploadUrl'] as String? ?? '';
    final headers = data['headers'] is Map
        ? (data['headers'] as Map)
            .map((key, value) => MapEntry(key.toString(), value.toString()))
        : const <String, String>{};

    await client.uploadBytes(uploadUrl, bytes: bytes, headers: headers);
    await client.post(ApiEndpoints.mediaComplete(mediaId));
    return mediaId;
  }

  /// One media id per file, uploaded in order. Sequential rather than
  /// parallel: two or three receipt photos is the whole range this is ever
  /// called with, and a clear "photo 2 of 3 failed" beats a burst of requests
  /// against a presigned-URL service that rate-limits per caller.
  Future<List<String>> uploadAll({
    required List<File> files,
    required MediaPurpose purpose,
  }) async {
    final ids = <String>[];
    for (final file in files) {
      ids.add(await upload(file: file, purpose: purpose));
    }
    return ids;
  }

  static String _contentTypeOf(String path) {
    switch (path.toLowerCase().split('.').last) {
      case 'png':
        return 'image/png';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
