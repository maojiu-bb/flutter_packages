import 'flutter_native_ui_kit_platform_interface.dart';

class FlutterNativeUiKit {
  Future<String?> getPlatformVersion() {
    return FlutterNativeUiKitPlatform.instance.getPlatformVersion();
  }
}
