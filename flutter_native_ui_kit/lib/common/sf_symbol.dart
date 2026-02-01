import 'dart:ui';

import 'package:flutter_native_ui_kit/common/sf_symbol_data.dart';

class SfSymbol {
  final SfSymbolData symbol;
  final Color? color;

  SfSymbol({
    required this.symbol,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      "symbol": symbol.name,
      "color": color?.toARGB32(),
    };
  }
}
