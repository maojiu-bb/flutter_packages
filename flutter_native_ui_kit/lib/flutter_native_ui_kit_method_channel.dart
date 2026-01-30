import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_native_ui_kit_platform_interface.dart';

/// An implementation of [FlutterNativeUiKitPlatform] that uses method channels.
class MethodChannelFlutterNativeUiKit extends FlutterNativeUiKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_native_ui_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
