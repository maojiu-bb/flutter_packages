import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_ui_kit_method_channel.dart';

abstract class FlutterNativeUiKitPlatform extends PlatformInterface {
  /// Constructs a FlutterNativeUiKitPlatform.
  FlutterNativeUiKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNativeUiKitPlatform _instance =
      MethodChannelFlutterNativeUiKit();

  /// The default instance of [FlutterNativeUiKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNativeUiKit].
  static FlutterNativeUiKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNativeUiKitPlatform] when
  /// they register themselves.
  static set instance(FlutterNativeUiKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
