import 'package:flutter/services.dart';
import 'package:flutter_native_ui_kit/channel/channel_name.dart';
import 'package:flutter_native_ui_kit/channel/method_name.dart';

class ActionSheetCell {
  final String label;
  final String key;
  final bool isDestructive;

  ActionSheetCell({
    required this.label,
    required this.key,
    this.isDestructive = false,
  });
}

class NativeActionSheet {
  static final MethodChannel _channel =
      MethodChannel(ChannelName.of(MethodName.NATIVE_ACTION_SHEET));

  static Future<void> show({
    required String title,
    String? message,
    required List<ActionSheetCell> cells,
    required Function(ActionSheetCell?) onResult,
  }) async {
    final result =
        await _channel.invokeMethod<String>(MethodName.NATIVE_ACTION_SHEET, {
      "title": title,
      "message": message,
      "cells": cells
          .map((cell) => {
                "label": cell.label,
                "key": cell.key,
                "isDestructive": cell.isDestructive,
              })
          .toList(),
    });

    if (result == null) {
      onResult.call(null);
      return;
    }

    onResult.call(cells.firstWhere((cell) => cell.key == result));
  }
}
