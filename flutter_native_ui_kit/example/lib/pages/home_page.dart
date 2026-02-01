import 'package:flutter/material.dart';
import 'package:flutter_native_ui_kit/widgets/native_action_sheet.dart';
import 'package:flutter_native_ui_kit/widgets/native_alert.dart';
import 'package:flutter_native_ui_kit_example/pages/detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                NativeAlert.show(
                  title: "NativeAlert",
                  message: "This is a native alert",
                  cancelText: "No",
                  confirmText: "Delete",
                  isDestructive: true,
                  onResult: (AlertResult result) {
                    print("result: $result");
                  },
                );
              },
              child:
                  Text("Native Alert", style: TextStyle(color: Colors.white)),
            ),
            GestureDetector(
              onTap: () {
                NativeActionSheet.show(
                  title: "Native Action Sheet",
                  cells: [
                    ActionSheetCell(label: "Option 1", key: "option1"),
                    ActionSheetCell(
                      label: "Option 2",
                      key: "option2",
                      isDestructive: true,
                    ),
                    ActionSheetCell(label: "Option 3", key: "option3"),
                  ],
                  onResult: (ActionSheetCell? cell) {
                    print("result: ${cell?.key}");
                  },
                );
              },
              child: Text("Native Action Sheet",
                  style: TextStyle(color: Colors.white)),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DetailPage()));
              },
              child: Text("Detail", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
