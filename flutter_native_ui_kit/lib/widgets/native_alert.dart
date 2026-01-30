import 'package:flutter/services.dart';
import 'package:flutter_native_ui_kit/channel/channel_name.dart';
import 'package:flutter_native_ui_kit/channel/method_name.dart';

enum AlertResult { cancel, confirm }

class NativeAlert {
  static final MethodChannel _channel =
      MethodChannel(ChannelName.of(MethodName.NATIVE_ALERT));

  static Future<void> show({
    required String title,
    String? message,
    String? cancelText,
    String? confirmText,
    bool isDestructive = false,
    required Function(AlertResult) onResult,
  }) async {
    final result = await _channel.invokeMethod<bool>(MethodName.NATIVE_ALERT, {
      "title": title,
      "message": message,
      "cancelText": cancelText,
      "confirmText": confirmText,
      "isDestructive": isDestructive,
    });
    onResult.call(result == true ? AlertResult.confirm : AlertResult.cancel);
  }
}
