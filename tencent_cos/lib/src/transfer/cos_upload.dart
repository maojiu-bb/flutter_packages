import 'package:flutter/foundation.dart';
import 'package:tencent_cos/src/config/cos_config.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';

/// Handles file uploads to Tencent Cloud COS.
class CosUpload {
  static CosUpload? _shared;
  static CosUpload get shared => _shared ??= CosUpload._();
  CosUpload._();

  final CosTransferManger _transferManager = Cos().getDefaultTransferManger();

  /// Full bucket name: bucketName-appId.
  String get _bucket => "${CosConfig.BUCKET_NAME}-${CosConfig.COS_APP_ID}";

  /// Normalizes folder to a COS path prefix (e.g. "documents" -> "documents/").
  static String _folderPrefix(String folder) {
    final trimmed = folder.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  /// Called when an upload fails (client or service exception).
  void _failCallback(Object? clientException, Object? serviceException) {
    if (clientException != null && kDebugMode) {
      print("COS client exception: ${clientException.toString()}");
    }
    if (serviceException != null && kDebugMode) {
      print("COS service exception: ${serviceException.toString()}");
    }
  }

  /// Called when transfer state changes.
  void _stateCallback(Object state) {
    if (kDebugMode) {
      print("COS upload state: $state");
    }
  }

  /// Called with upload progress (complete / target).
  void _progressCallback(int complete, int target) {
    if (kDebugMode && target > 0) {
      final progress = (complete / target * 100).toInt();
      print("COS upload progress: $progress%");
    }
  }

  /// Called when multipart upload is initialized (uploadId for resume).
  void _initMultipleUploadCallback(
    String bucket,
    String cosKey,
    String uploadId,
  ) {
    // uploadId can be stored for resume; currently unused.
    assert(bucket.isNotEmpty && cosKey.isNotEmpty && uploadId.isNotEmpty);
  }

  /// Uploads a file to an arbitrary COS path (no images/videos prefix).
  Future<void> uploadFile({
    required String cosPath,
    required String srcPath,
    required void Function(String uploadUrl) successUpload,
    void Function(String error)? failUpload,
  }) async {
    await _transferManager.upload(
      _bucket,
      cosPath,
      filePath: srcPath,
      resultListener: ResultListener(
        (result, cosXmlResult) {
          successUpload(result!["accessUrl"]!);
        },
        (clientException, serviceException) {
          _failCallback(clientException, serviceException);
          failUpload?.call(
            clientException?.toString() ??
                serviceException?.toString() ??
                "Upload failed",
          );
        },
      ),
      stateCallback: _stateCallback,
      progressCallBack: _progressCallback,
      initMultipleUploadCallback: _initMultipleUploadCallback,
    );
  }

  /// Uploads a file to a custom folder prefix. Use [folder] e.g. "documents", "avatars"; it will be normalized (e.g. "documents/").
  Future<void> uploadToFolder({
    required String folder,
    required String cosPath,
    required String srcPath,
    required void Function(String uploadUrl) successUpload,
    void Function(String error)? failUpload,
  }) async {
    final prefix = _folderPrefix(folder);
    await _transferManager.upload(
      _bucket,
      '$prefix$cosPath',
      filePath: srcPath,
      resultListener: ResultListener(
        (result, cosXmlResult) {
          successUpload(result!["accessUrl"]!);
        },
        (clientException, serviceException) {
          _failCallback(clientException, serviceException);
          failUpload?.call(
            clientException?.toString() ??
                serviceException?.toString() ??
                "Upload failed",
          );
        },
      ),
      stateCallback: _stateCallback,
      progressCallBack: _progressCallback,
      initMultipleUploadCallback: _initMultipleUploadCallback,
    );
  }

  /// Uploads an image to COS under the configured images prefix (see [TencentCosConfig.imagesPrefix]).
  Future<void> uploadImageToTencent({
    required String cosPath,
    required String srcPath,
    required void Function(String uploadUrl) successUpload,
    void Function(String error)? failUpload,
  }) async {
    await _transferManager.upload(
      _bucket,
      '${CosConfig.IMAGES_PREFIX}$cosPath',
      filePath: srcPath,
      resultListener: ResultListener(
        (result, cosXmlResult) {
          successUpload(result!["accessUrl"]!);
        },
        (clientException, serviceException) {
          _failCallback(clientException, serviceException);
          failUpload?.call(
            clientException?.toString() ??
                serviceException?.toString() ??
                "Upload failed",
          );
        },
      ),
      stateCallback: _stateCallback,
      progressCallBack: _progressCallback,
      initMultipleUploadCallback: _initMultipleUploadCallback,
    );
  }

  /// Uploads a video to COS under the configured videos prefix (see [TencentCosConfig.videosPrefix]).
  Future<void> uploadVideoToTencent(
    String cosPath,
    String srcPath,
    void Function(String uploadUrl) successUpload, {
    void Function(String error)? failUpload,
  }) async {
    await _transferManager.upload(
      _bucket,
      '${CosConfig.VIDEOS_PREFIX}$cosPath',
      filePath: srcPath,
      resultListener: ResultListener(
        (result, cosXmlResult) {
          successUpload(result!["accessUrl"]!);
        },
        (clientException, serviceException) {
          _failCallback(clientException, serviceException);
          failUpload?.call(
            clientException?.toString() ??
                serviceException?.toString() ??
                "Upload failed",
          );
        },
      ),
      stateCallback: _stateCallback,
      progressCallBack: _progressCallback,
      initMultipleUploadCallback: _initMultipleUploadCallback,
    );
  }

  /// Uploads one image and one video in parallel; completes when both finish.
  Future<void> uploadImageAndVideoToTencent(
    String imageCosPath,
    String imageSrcPath,
    String videoCosPath,
    String videoSrcPath,
    void Function(String uploadImageUrl, String uploadVideoUrl) successUpload, {
    void Function(String error)? failUpload,
  }) async {
    final urls = <String, String>{};

    void onSuccess(String url, String type) {
      urls[type] = url;
      if (urls.containsKey("uploadImageUrl") &&
          urls.containsKey("uploadVideoUrl")) {
        successUpload(urls["uploadImageUrl"]!, urls["uploadVideoUrl"]!);
      }
    }

    void onFail(Object? clientException, Object? serviceException) {
      _failCallback(clientException, serviceException);
      failUpload?.call(
        clientException?.toString() ??
            serviceException?.toString() ??
            "Upload failed",
      );
    }

    await Future.wait([
      _transferManager.upload(
        _bucket,
        '${CosConfig.IMAGES_PREFIX}$imageCosPath',
        filePath: imageSrcPath,
        resultListener: ResultListener(
          (result, cosXmlResult) {
            onSuccess(result!["accessUrl"]!, 'uploadImageUrl');
          },
          onFail,
        ),
        stateCallback: _stateCallback,
        progressCallBack: _progressCallback,
        initMultipleUploadCallback: _initMultipleUploadCallback,
      ),
      _transferManager.upload(
        _bucket,
        '${CosConfig.VIDEOS_PREFIX}$videoCosPath',
        filePath: videoSrcPath,
        resultListener: ResultListener(
          (result, cosXmlResult) {
            onSuccess(result!["accessUrl"]!, 'uploadVideoUrl');
          },
          onFail,
        ),
        stateCallback: _stateCallback,
        progressCallBack: _progressCallback,
        initMultipleUploadCallback: _initMultipleUploadCallback,
      ),
    ]);
  }

  /// Uploads multiple files to a custom folder in parallel. [pathList] entries use keys "cosPath" and "srcPath".
  /// [successUpload] is called once all succeed; if any fails, [failUpload] is called instead.
  Future<void> uploadMultipleToFolder({
    required String folder,
    required List<Map<String, String>> pathList,
    required void Function(List<String> uploadUrlList) successUpload,
    void Function(String error)? failUpload,
  }) async {
    if (pathList.isEmpty) {
      successUpload([]);
      return;
    }
    final prefix = _folderPrefix(folder);
    final uploadUrlList = <String>[];
    var completedCount = 0;
    var hasFailed = false;

    void onSuccess(String url) {
      if (hasFailed) return;
      uploadUrlList.add(url);
      completedCount++;
      if (completedCount == pathList.length) {
        successUpload(uploadUrlList);
      }
    }

    void onFail(Object? clientException, Object? serviceException) {
      if (hasFailed) return;
      hasFailed = true;
      _failCallback(clientException, serviceException);
      failUpload?.call(
        clientException?.toString() ??
            serviceException?.toString() ??
            "Upload failed",
      );
    }

    final futures = <Future<void>>[];
    for (final item in pathList) {
      final cosPath = item["cosPath"];
      final srcPath = item["srcPath"];
      if (cosPath == null || srcPath == null) continue;
      futures.add(
        _transferManager.upload(
          _bucket,
          '$prefix$cosPath',
          filePath: srcPath,
          resultListener: ResultListener(
            (result, cosXmlResult) {
              onSuccess(result!["accessUrl"]!);
            },
            onFail,
          ),
          stateCallback: _stateCallback,
          progressCallBack: _progressCallback,
          initMultipleUploadCallback: _initMultipleUploadCallback,
        ),
      );
    }
    await Future.wait(futures);
  }

  /// Uploads multiple images in parallel under the configured images prefix; [successUpload] is called once all succeed.
  /// If any upload fails, [failUpload] is called and [successUpload] is not invoked.
  Future<void> uploadMultipleImageToTencent({
    required List<Map<String, String>> pathList,
    required void Function(List<String> uploadUrlList) successUpload,
    void Function(String error)? failUpload,
  }) async {
    if (pathList.isEmpty) {
      successUpload([]);
      return;
    }

    final uploadUrlList = <String>[];
    var completedCount = 0;
    var hasFailed = false;

    void onSuccess(String url) {
      if (hasFailed) return;
      uploadUrlList.add(url);
      completedCount++;
      if (completedCount == pathList.length) {
        successUpload(uploadUrlList);
      }
    }

    void onFail(Object? clientException, Object? serviceException) {
      if (hasFailed) return;
      hasFailed = true;
      _failCallback(clientException, serviceException);
      failUpload?.call(
        clientException?.toString() ??
            serviceException?.toString() ??
            "Upload failed",
      );
    }

    final futures = <Future<void>>[];
    for (final item in pathList) {
      final cosPath = item["cosPath"];
      final srcPath = item["srcPath"];
      if (cosPath == null || srcPath == null) continue;
      futures.add(
        _transferManager.upload(
          _bucket,
          '${CosConfig.IMAGES_PREFIX}$cosPath',
          filePath: srcPath,
          resultListener: ResultListener(
            (result, cosXmlResult) {
              onSuccess(result!["accessUrl"]!);
            },
            onFail,
          ),
          stateCallback: _stateCallback,
          progressCallBack: _progressCallback,
          initMultipleUploadCallback: _initMultipleUploadCallback,
        ),
      );
    }
    await Future.wait(futures);
  }
}
