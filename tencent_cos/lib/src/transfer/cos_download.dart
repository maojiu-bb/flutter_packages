import 'package:tencent_cos/src/config/cos_config.dart';

/// Builds download URLs for objects in Tencent Cloud COS.
class CosDownload {
  static CosDownload? _shared;
  static CosDownload get shared => _shared ??= CosDownload._();
  CosDownload._();

  /// Base URL for the configured bucket (bucketName-appId.cos.region.myqcloud.com).
  String get _baseUrl {
    final bucket = "${CosConfig.BUCKET_NAME}-${CosConfig.COS_APP_ID}";
    final region = CosConfig.PERSIST_BUCKET_REGION;
    return "https://$bucket.cos.$region.myqcloud.com";
  }

  /// Returns the full download URL for an object at [cosPath].
  String getDownloadUrl(String cosPath) {
    return "$_baseUrl/$cosPath";
  }

  /// Returns the download URL for an object under a custom folder (e.g. folder "documents", fileName "report.pdf" -> documents/report.pdf).
  /// [folder] is normalized (e.g. "documents" -> "documents/").
  String getDownloadUrlInFolder(String folder, String fileName) {
    final prefix = _folderPrefix(folder);
    return "$_baseUrl/$prefix$fileName";
  }

  /// Returns the download URL for an image under the configured images prefix (see [TencentCosConfig.imagesPrefix]).
  String getImageDownloadUrl(String fileName) {
    return "$_baseUrl/${CosConfig.IMAGES_PREFIX}$fileName";
  }

  /// Returns the download URL for a video under the configured videos prefix (see [TencentCosConfig.videosPrefix]).
  String getVideoDownloadUrl(String fileName) {
    return "$_baseUrl/${CosConfig.VIDEOS_PREFIX}$fileName";
  }

  static String _folderPrefix(String folder) {
    final trimmed = folder.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
