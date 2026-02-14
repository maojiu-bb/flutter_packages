import 'caid_info_collection_platform_interface.dart';

class CaidInfoCollection {
  static Future<String?> getPlatformVersion() async {
    return await CaidInfoCollectionPlatform.instance.getPlatformVersion();
  }

  static Future<String?> getCAIDEncryptedInfo(String publicKeyBase64) async {
    return await CaidInfoCollectionPlatform.instance.getCAIDEncryptedInfo(publicKeyBase64);
  }
}
