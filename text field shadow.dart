import 'package:flutter/material.dart';

class TextFieldShadow extends StatelessWidget {
  const TextFieldShadow({
    super.key,
    required this.child,
    required this.topStops,
    required this.leftStops,
  });

  final Widget child;
  final List<double>? topStops;
  final List<double>? leftStops;

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black26, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: topStops,
          // stops: [0.0, 0.15],
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Container(
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black26, Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: leftStops,
            // stops: [0.0, 0.013],
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: child,
      ),
    );
  }
}
