import 'package:tencent_cos/src/config/cos_config.dart';
import 'package:tencent_cos/src/transfer/cos_delete.dart';
import 'package:tencent_cos/src/transfer/cos_download.dart';
import 'package:tencent_cos/src/transfer/cos_upload.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

/// Configuration for the Tencent Cloud COS client.
class TencentCosConfig {
  /// Tencent Cloud APP ID.
  final String appId;

  /// Bucket name (without appId suffix).
  final String bucketName;

  /// Bucket region (e.g. ap-guangzhou).
  final String region;

  /// Whether to use STS temporary credentials.
  final bool useSessionToken;

  /// Whether to use scope-limited STS credentials.
  final bool useScopeLimitToken;

  /// Permanent secret ID (required when not using temporary credentials).
  final String? secretId;

  /// Permanent secret key (required when not using temporary credentials).
  final String? secretKey;

  /// STS server URL for temporary credentials (required when using session token).
  final String? stsUrl;

  /// STS server URL for scope-limited temporary credentials.
  final String? stsScopeLimitUrl;

  /// Whether to enable SDK debug logging.
  final bool isDebuggable;

  /// Folder prefix used by [CosUpload.uploadImageToTencent], [CosDownload.getImageDownloadUrl], [CosDelete.deleteImage]. Default: `images`.
  final String imagesPrefix;

  /// Folder prefix used by [CosUpload.uploadVideoToTencent], [CosDownload.getVideoDownloadUrl], [CosDelete.deleteVideo]. Default: `videos`.
  final String videosPrefix;

  const TencentCosConfig({
    required this.appId,
    required this.bucketName,
    required this.region,
    this.useSessionToken = true,
    this.useScopeLimitToken = false,
    this.secretId,
    this.secretKey,
    this.stsUrl,
    this.stsScopeLimitUrl,
    this.isDebuggable = false,
    this.imagesPrefix = 'images',
    this.videosPrefix = 'videos',
  });
}

/// Tencent Cloud COS client. Must be initialized via [TencentCosClient.initialize] before use.
class TencentCosClient {
  static TencentCosClient? _instance;

  /// Singleton instance. Throws if [initialize] has not been called.
  static TencentCosClient get instance {
    if (_instance == null) {
      throw StateError(
        'TencentCosClient has not been initialized. '
        'Please call TencentCosClient.initialize() first.',
      );
    }
    return _instance!;
  }

  bool _initialized = false;

  /// Initializes the COS client with the given [config]. Safe to call multiple times; re-initialization is skipped.
  static Future<void> initialize(TencentCosConfig config) async {
    if (_instance?._initialized == true) {
      return;
    }

    // 设置配置
    CosConfig.COS_APP_ID = config.appId;
    CosConfig.BUCKET_NAME = config.bucketName;
    CosConfig.PERSIST_BUCKET_REGION = config.region;
    CosConfig.USE_SESSION_TOKEN_CREDENTIAL = config.useSessionToken;
    CosConfig.USE_SCOPE_LIMIT_TOKEN_CREDENTIAL = config.useScopeLimitToken;
    CosConfig.SECRET_ID = config.secretId ?? "";
    CosConfig.SECRET_KEY = config.secretKey ?? "";
    CosConfig.STS_URL = config.stsUrl ?? "";
    CosConfig.STS_SCOPE_LIMIT_URL = config.stsScopeLimitUrl ?? "";
    CosConfig.IS_DEBUGGABLE = config.isDebuggable;
    CosConfig.IMAGES_PREFIX = _normalizeFolderPrefix(config.imagesPrefix);
    CosConfig.VIDEOS_PREFIX = _normalizeFolderPrefix(config.videosPrefix);

    await Cos().initWithPlainSecret(CosConfig.SECRET_ID, CosConfig.SECRET_KEY);
    await Cos().registerDefaultService(CosConfig.serviceConfig);
    await Cos().registerDefaultTransferManger(
      CosConfig.serviceConfig,
      TransferConfig(),
    );

    _instance = TencentCosClient._();
    _instance!._initialized = true;
  }

  TencentCosClient._();

  /// Ensures folder prefix ends with '/' for COS path concatenation (e.g. "images" -> "images/").
  static String _normalizeFolderPrefix(String prefix) {
    final trimmed = prefix.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  /// Upload manager for putting files to COS.
  CosUpload get upload => CosUpload.shared;

  /// Download manager for building download URLs.
  CosDownload get download => CosDownload.shared;

  /// Delete manager for removing objects from COS.
  CosDelete get delete => CosDelete.shared;
}
