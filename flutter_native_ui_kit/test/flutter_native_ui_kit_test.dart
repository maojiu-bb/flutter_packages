import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_native_ui_kit/flutter_native_ui_kit.dart';
import 'package:flutter_native_ui_kit/flutter_native_ui_kit_platform_interface.dart';
import 'package:flutter_native_ui_kit/flutter_native_ui_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterNativeUiKitPlatform
    with MockPlatformInterfaceMixin
    implements FlutterNativeUiKitPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterNativeUiKitPlatform initialPlatform = FlutterNativeUiKitPlatform.instance;

  test('$MethodChannelFlutterNativeUiKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterNativeUiKit>());
  });

  test('getPlatformVersion', () async {
    FlutterNativeUiKit flutterNativeUiKitPlugin = FlutterNativeUiKit();
    MockFlutterNativeUiKitPlatform fakePlatform = MockFlutterNativeUiKitPlatform();
    FlutterNativeUiKitPlatform.instance = fakePlatform;

    expect(await flutterNativeUiKitPlugin.getPlatformVersion(), '42');
  });
}
