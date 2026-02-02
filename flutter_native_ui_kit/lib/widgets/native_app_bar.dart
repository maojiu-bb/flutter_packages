import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_ui_kit/channel/channel_name.dart';
import 'package:flutter_native_ui_kit/channel/method_name.dart';
import 'package:flutter_native_ui_kit/common/sf_symbol.dart';
import 'package:flutter_native_ui_kit/common/view_type.dart';

class NativeAppBar extends StatefulWidget {
  final String? title;
  final Color? titleColor;
  final SfSymbol? leading;
  final List<SfSymbol>? actions;
  final VoidCallback? onLeadingPressed;
  final void Function(int index)? onActionPressed;

  const NativeAppBar({
    super.key,
    this.title,
    this.titleColor,
    this.leading,
    this.actions,
    this.onLeadingPressed,
    this.onActionPressed,
  });

  @override
  State<NativeAppBar> createState() => _NativeAppBarState();
}

class _NativeAppBarState extends State<NativeAppBar> {
  MethodChannel? _channel;

  void _onPlatformViewCreated(int id) {
    _channel =
        MethodChannel(ChannelName.of(MethodName.NATIVE_APP_BAR.withId(id)));
    _channel!.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case MethodName.NATIVE_APP_BAR:
        final args = call.arguments as Map<dynamic, dynamic>;
        final position = args['position'] as String;
        final index = args['index'] as int;

        if (position == 'leading') {
          widget.onLeadingPressed?.call();
        } else if (position == 'action') {
          widget.onActionPressed?.call(index);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: UiKitView(
        viewType: ViewType.NATIVE_APP_BAR,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        creationParams: {
          "title": widget.title,
          "titleColor": widget.titleColor?.value,
          "leading": widget.leading?.toJson(),
          "actions": widget.actions?.map((action) => action.toJson()).toList(),
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}
