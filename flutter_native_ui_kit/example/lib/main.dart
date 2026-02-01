import 'package:flutter/material.dart';
import 'package:flutter_native_ui_kit/common/sf_symbol.dart';
import 'package:flutter_native_ui_kit/common/sf_symbol_data.dart';
import 'package:flutter_native_ui_kit/widgets/native_tab_bar.dart';
import 'package:flutter_native_ui_kit_example/pages/home_page.dart';
import 'package:flutter_native_ui_kit_example/pages/setting_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NativeTabBar(
                activeColor: Colors.pink,
                items: [
                  NativeTabBarItem(
                    label: "Home",
                    symbol: SfSymbol(symbol: SfSymbolData.house),
                  ),
                  NativeTabBarItem(
                    label: "Settings",
                    symbol: SfSymbol(symbol: SfSymbolData.gearshape),
                  ),
                ],
                onTabSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
