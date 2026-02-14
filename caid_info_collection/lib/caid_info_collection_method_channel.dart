import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'caid_info_collection_platform_interface.dart';

/// An implementation of [CaidInfoCollectionPlatform] that uses method channels.
class MethodChannelCaidInfoCollection extends CaidInfoCollectionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('caid_info_collection');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> getCAIDEncryptedInfo(String publicKeyBase64) async {
    final caidEncryptedInfo = await methodChannel.invokeMethod<String>('getCAIDEncryptedInfo', {
      'publicKeyBase64': publicKeyBase64,
    });
    return caidEncryptedInfo;
  }
}
