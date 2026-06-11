import 'package:flutter/material.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';

/// 立体凸ボタン
class PopOutButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(LongPressEndDetails)? onLongPressEnd;
  final List<Color> backgroundColors;
  final Color foregroundColor;
  final Widget child;
  final double circularValue;
  final Widget? icon;
  final double? iconSize;
  final IconAlignment iconAlignment;

  /// 立体凸ボタン
  const PopOutButton({
    super.key,
    required this.backgroundColors,
    this.foregroundColor = Colors.white,
    required this.onPressed,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressEnd,
    required this.child,
    this.circularValue = 10,
  }) : icon = null,
       iconSize = null,
       iconAlignment = IconAlignment.start;

  const PopOutButton.icon({
    super.key,
    required this.icon,
    required this.backgroundColors,
    this.foregroundColor = Colors.white,
    required this.onPressed,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressEnd,
    required this.child,
    this.circularValue = 10,
    this.iconSize,
    this.iconAlignment = IconAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final btnStyle = GradientElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundGradient: LinearGradient(
        colors: backgroundColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(circularValue),
      ), // RoundedRectangleBorder
      side: BorderSide(color: Colors.white, width: 1),
      shadowColor: Colors.black,
      elevation: 8,
      iconColor: foregroundColor,
      iconSize: iconSize,
    );

    return Container(
      decoration: BoxDecoration(
        // ボタンの外側の影
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 1,
            offset: Offset(3, 3),
            blurRadius: .5,
          ), // BoxShadow
        ],
        borderRadius: BorderRadius.circular(circularValue),
      ), // BoxDecoration
      // ボタンの表面に影をかける（下側）
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black12],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.7, 1.0],
        ), // LinearGradient
        borderRadius: BorderRadius.circular(circularValue),
      ), // BoxDecoration
      // グラデーションボタンの本体
      child: GestureDetector(
        onLongPressStart: onLongPressStart,
        onLongPressEnd: onLongPressEnd,
        child: icon == null
            ? GradientElevatedButton(
                style: btnStyle,
                onPressed: onPressed,
                onLongPress: onLongPress,
                child: child,
              ) // GradientElevatedButton
            : GradientElevatedButton.icon(
                style: btnStyle,
                icon: icon,
                onPressed: onPressed,
                onLongPress: onLongPress,
                label: child,
                iconAlignment: iconAlignment,
              ), // GradientElevatedButton.icon
      ), // GestureDetector
    ); // Container
  }
}

/// 立体凹ボタン
class SetBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final List<Color> backgroundColors;
  final Color foregroundColor;
  final Widget child;
  final double circularValue;
  final Widget? icon;
  final double? iconSize;
  final IconAlignment iconAlignment;

  /// 立体凹ボタン
  const SetBackButton({
    super.key,
    required this.backgroundColors,
    this.foregroundColor = Colors.white,
    required this.onPressed,
    required this.child,
    this.circularValue = 10,
  }) : icon = null,
       iconSize = null,
       iconAlignment = IconAlignment.start;

  const SetBackButton.icon({
    super.key,
    required this.icon,
    required this.backgroundColors,
    this.foregroundColor = Colors.white,
    required this.onPressed,
    required this.child,
    this.circularValue = 10,
    this.iconSize,
    this.iconAlignment = IconAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final btnStyle = GradientElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundGradient: LinearGradient(
        colors: backgroundColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      foregroundColor: foregroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(circularValue),
      ), // RoundedRectangleBorder
      side: BorderSide(color: Colors.white, width: 1),
      elevation: 0,
      iconColor: foregroundColor,
      iconSize: iconSize,
    );

    const List<Color> shadowColors = [Colors.black26, Colors.transparent];

    return Container(
      // ボタンの表面に影をかける（左側）
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          colors: shadowColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          stops: [0.01, 0.25],
        ), // LinearGradient
        borderRadius: BorderRadius.circular(circularValue),
      ), // BoxDecoration
      child: Container(
        // ボタンの表面に影をかける（上側）
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: shadowColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.01, 0.3],
          ), // LinearGradient
          borderRadius: BorderRadius.circular(circularValue),
        ), // BoxDecoration
        // グラデーションボタンの本体
        child: icon == null
            ? GradientElevatedButton(
                style: btnStyle,
                onPressed: onPressed,
                child: child,
              ) // GradientElevatedButton
            : GradientElevatedButton.icon(
                style: btnStyle,
                icon: icon,
                onPressed: onPressed,
                label: child,
                iconAlignment: iconAlignment,
              ), // GradientElevatedButton.icon
      ), // Container
    ); // Container
  }
}
