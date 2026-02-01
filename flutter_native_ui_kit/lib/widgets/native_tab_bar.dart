import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_ui_kit/channel/channel_name.dart';
import 'package:flutter_native_ui_kit/channel/method_name.dart';
import 'package:flutter_native_ui_kit/common/sf_symbol.dart';
import 'package:flutter_native_ui_kit/common/view_type.dart';

class NativeTabBarItem {
  final String? label;
  final SfSymbol? symbol;

  NativeTabBarItem({
    this.label,
    this.symbol,
  }) : assert(
          label != null || symbol != null,
          'label and symbol cannot be null at the same time',
        );

  Map<String, dynamic> toJson() {
    return {
      "label": label,
      "symbol": symbol?.symbol.name,
    };
  }
}

class NativeTabBar extends StatelessWidget {
  final List<NativeTabBarItem> items;
  final Color? activeColor;
  final Color? inactiveColor;
  final int? selectedIndex;
  final Function(int index) onTabSelected;

  NativeTabBar({
    super.key,
    required this.items,
    this.activeColor,
    this.inactiveColor,
    this.selectedIndex,
    required this.onTabSelected,
  }) : assert(items.isNotEmpty, 'items cannot be empty');

  void _onPlatformViewCreated(int id) {
    final channel =
        MethodChannel(ChannelName.of(MethodName.NATIVE_TAB_BAR.withId(id)));
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case MethodName.NATIVE_TAB_BAR:
          final index = call.arguments as int;
          onTabSelected.call(index);
          break;

        default:
          throw PlatformException(
            code: 'Method not found',
            message: 'Method ${call.method} not found',
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final height = 49.0 + bottomInset;

    return SizedBox(
      height: height,
      child: UiKitView(
        viewType: ViewType.NATIVE_TAB_BAR,
        creationParams: {
          "items": items.map((item) => item.toJson()).toList(),
          "activeColor": activeColor?.toARGB32(),
          "inactiveColor": inactiveColor?.toARGB32(),
          "selectedIndex": selectedIndex,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}
