import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';

/// Internal COS configuration used by the underlying SDK.
/// Values are set from [TencentCosConfig] during [TencentCosClient.initialize].
class CosConfig {
  /// Tencent Cloud APP ID.
  static String COS_APP_ID = "";

  /// Bucket name (without appId suffix).
  static String BUCKET_NAME = "";

  /// Whether to use STS session (temporary) credentials.
  static bool USE_SESSION_TOKEN_CREDENTIAL = true;

  /// Whether to use scope-limited STS credentials.
  static bool USE_SCOPE_LIMIT_TOKEN_CREDENTIAL = false;

  /// Permanent secret ID (required when not using session token).
  static String SECRET_ID = "";

  /// Permanent secret key (required when not using session token).
  static String SECRET_KEY = "";

  /// STS server URL for temporary credentials.
  static String STS_URL = "";

  /// STS server URL for scope-limited temporary credentials.
  static String STS_SCOPE_LIMIT_URL = "";

  /// Bucket region (e.g. ap-guangzhou).
  static String PERSIST_BUCKET_REGION = "";

  /// Whether SDK debug logging is enabled.
  static bool IS_DEBUGGABLE = false;

  /// Folder prefix for "image" convenience methods (e.g. images/). Set from [TencentCosConfig.imagesPrefix].
  static String IMAGES_PREFIX = 'images/';

  /// Folder prefix for "video" convenience methods (e.g. videos/). Set from [TencentCosConfig.videosPrefix].
  static String VIDEOS_PREFIX = 'videos/';

  static CosXmlServiceConfig? _serviceConfig;

  /// Lazily-created service config used by Cos().
  static CosXmlServiceConfig get serviceConfig {
    _serviceConfig ??= CosXmlServiceConfig(
      region: PERSIST_BUCKET_REGION,
      isDebuggable: IS_DEBUGGABLE,
    );
    return _serviceConfig!;
  }
}
