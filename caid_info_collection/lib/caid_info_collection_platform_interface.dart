import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'caid_info_collection_method_channel.dart';

abstract class CaidInfoCollectionPlatform extends PlatformInterface {
  /// Constructs a CaidInfoCollectionPlatform.
  CaidInfoCollectionPlatform() : super(token: _token);

  static final Object _token = Object();

  static CaidInfoCollectionPlatform _instance = MethodChannelCaidInfoCollection();

  /// The default instance of [CaidInfoCollectionPlatform] to use.
  ///
  /// Defaults to [MethodChannelCaidInfoCollection].
  static CaidInfoCollectionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CaidInfoCollectionPlatform] when
  /// they register themselves.
  static set instance(CaidInfoCollectionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getCAIDEncryptedInfo(String publicKeyBase64) {
    throw UnimplementedError(
        'getCAIDEncryptedInfo(String publicKeyBase64) has not been implemented.');
  }
}
