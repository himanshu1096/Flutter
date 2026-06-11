import 'package:flutter/material.dart';

class FramedIcon extends StatelessWidget {
  /// アイコン
  final Widget icon;

  /// 枠付きアイコン
  const FramedIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.white, blurRadius: 3, spreadRadius: 3),
          BoxShadow(color: Colors.green, blurRadius: 3, spreadRadius: 3),
        ],
      ), // BoxDecoration
      child: icon,
    ); // Container
  }
}
