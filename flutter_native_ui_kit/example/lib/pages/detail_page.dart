import 'package:flutter/material.dart';
import 'package:flutter_native_ui_kit/common/sf_symbol.dart';
import 'package:flutter_native_ui_kit/common/sf_symbol_data.dart';
import 'package:flutter_native_ui_kit/widgets/native_app_bar.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Center(
              child: Text('Detail', style: TextStyle(color: Colors.white)),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: NativeAppBar(
                title: 'Detail',
                titleColor: Colors.white,
                leading: SfSymbol(symbol: SfSymbolData.chevronLeft),
                actions: [
                  SfSymbol(symbol: SfSymbolData.heart),
                  SfSymbol(symbol: SfSymbolData.ellipsis),
                ],
                onLeadingPressed: () {
                  Navigator.pop(context);
                },
                onActionPressed: (index) {
                  print('action pressed: $index');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
