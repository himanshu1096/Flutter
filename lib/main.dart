import 'package:flutter/material.dart';
import 'package:flutter_application_astrohoro/src/common/ui/details/main_menu/main_menu.dart';

void main() {
  runApp(Zodoscope());
}

class Zodoscope extends StatefulWidget {
  @override
  _ZodoscopeState createState() => _ZodoscopeState();
}

class _ZodoscopeState extends State<Zodoscope> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Augustus',
      ),
      home: MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}
