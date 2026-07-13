import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_color.dart';
import '../pop_out_button.dart';

// サイズ固定ボタンのラッパー
class SizedButton extends StatelessWidget {
  const SizedButton({required this.child, super.key});

  final Widget child;

  // final bool isLargeSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 65.0, width: 220.0, child: child);

    // return switch (isLargeSize) {
    //   true => SizedBox(height: 65.0, width: 220.0, child: child),
    //   _ => SizedBox(height: 65.0, width: 220.0, child: child),
    // };
  }
}

// 活性化した大きいボタン
class ActiveLargeButton extends StatelessWidget {
  const ActiveLargeButton({
    required this.text,
    required this.onPressed,
    this.btnBaseColor = orengeGradient,
    this.btnFontSize = 30.0, // ✅ NEW
    this.btnIconSize = 24.0, // ✅ NEW
    this.btnPadding = const EdgeInsets.only(right: 24.0),
    super.key,
  });

  final List<Color> btnBaseColor;
  final String text;
  final VoidCallback onPressed;
  final double btnFontSize;
  final double btnIconSize;
  final EdgeInsets btnPadding;

  @override
  Widget build(BuildContext context) {
    return SizedButton(
      child: PopOutButton(
        backgroundColors: btnBaseColor,
        foregroundColor: Colors.black,
        onPressed: onPressed,
        child: Padding(
          padding: btnPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: btnIconSize,
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                color: Colors.black,
                size: btnIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 非活性の大きいボタン
class InactiveLargeButton extends StatelessWidget {
  const InactiveLargeButton({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedButton(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xffc8c8c8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          overlayColor: Color(0xffc8c8c8),
        ),
        onPressed: () {},
        child: Padding(
          padding: const EdgeInsets.only(right: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                  color: Color(0xff969696),
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                color: Color(0xff969696),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
