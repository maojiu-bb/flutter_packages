import 'package:tencent_cos/src/config/cos_config.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_service.dart';

/// Handles object deletion from Tencent Cloud COS.
class CosDelete {
  static CosDelete? _shared;
  static CosDelete get shared => _shared ??= CosDelete._();
  CosDelete._();

  final CosService _cosService = Cos().getDefaultService();

  /// Full bucket name: bucketName-appId.
  String get _bucket => "${CosConfig.BUCKET_NAME}-${CosConfig.COS_APP_ID}";

  /// Deletes a single object at [cosPath].
  Future<void> deleteObject(String cosPath) async {
    await _cosService.deleteObject(_bucket, cosPath);
  }

  /// Deletes an object under a custom folder (e.g. folder "documents", fileName "report.pdf" -> documents/report.pdf).
  /// [folder] is normalized (e.g. "documents" -> "documents/").
  Future<void> deleteInFolder(String folder, String fileName) async {
    final prefix = _folderPrefix(folder);
    await _cosService.deleteObject(_bucket, '$prefix$fileName');
  }

  /// Deletes an image stored under the configured images prefix (see [TencentCosConfig.imagesPrefix]).
  Future<void> deleteImage(String fileName) async {
    await _cosService.deleteObject(_bucket, '${CosConfig.IMAGES_PREFIX}$fileName');
  }

  /// Deletes a video stored under the configured videos prefix (see [TencentCosConfig.videosPrefix]).
  Future<void> deleteVideo(String fileName) async {
    await _cosService.deleteObject(_bucket, '${CosConfig.VIDEOS_PREFIX}$fileName');
  }

  static String _folderPrefix(String folder) {
    final trimmed = folder.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  /// Deletes multiple objects in parallel. Fails fast if any delete throws.
  Future<void> deleteObjects(List<String> cosPaths) async {
    if (cosPaths.isEmpty) return;
    await Future.wait(
      cosPaths.map((path) => _cosService.deleteObject(_bucket, path)),
    );
  }
}
