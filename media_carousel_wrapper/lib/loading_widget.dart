import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color? loadingColor;
  const LoadingWidget({super.key, this.loadingColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: loadingColor ?? Colors.white,
      ),
    );
  }
}
