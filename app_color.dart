import 'package:flutter/material.dart';

/// MaterialColor
/// 色の参照先: 🎨 Material Design Colors, Color Palette | Material UI
/// https://materialui.co/colors
enum AppColor {
  red(
    no50: Color(0xffFFEBEE),
    no100: Color(0xffFFCDD2),
    no300: Color(0xffE57373),
    no400: Color(0xffEF5350),
    no700: Color(0xffD32F2F),
  ),
  pink(
    no50: Color(0xffFCE4EC),
    no100: Color(0xffF8BBD0),
    no300: Color(0xffF06292),
    no400: Color(0xffEC407A),
    no700: Color(0xffC2185B),
  ),
  purple(
    no50: Color(0xffF3E5F5),
    no100: Color(0xffE1BEE7),
    no300: Color(0xffBA68C8),
    no400: Color(0xffAB47BC),
    no700: Color(0xff7B1FA2),
  ),
  deepPurple(
    no50: Color(0xffEDE7F6),
    no100: Color(0xffD1C4E9),
    no300: Color(0xff9575CD),
    no400: Color(0xff7E57C2),
    no700: Color(0xff512DA8),
  ),
  indigo(
    no50: Color(0xffE8EAF6),
    no100: Color(0xffC5CAE9),
    no300: Color(0xff7986CB),
    no400: Color(0xff5C6BC0),
    no700: Color(0xff303F9F),
  ),
  blue(
    no50: Color(0xffE3F2FD),
    no100: Color(0xff90CAF9),
    no300: Color(0xff64B5F6),
    no400: Color(0xff42A5F5),
    no700: Color(0xff1976D2),
  ),
  lightBlue(
    no50: Color(0xffE1F5FE),
    no100: Color(0xff81D4FA),
    no300: Color(0xff4FC3F7),
    no400: Color(0xff29B6F6),
    no700: Color(0xff0288D1),
  ),
  cyan(
    no50: Color(0xffE0F7FA),
    no100: Color(0xffB2DFDB),
    no300: Color(0xff4DD0E1),
    no400: Color(0xff26C6DA),
    no700: Color(0xff0097A7),
  ),
  teal(
    no50: Color(0xffE0F2F1),
    no100: Color(0xffB2DFDB),
    no300: Color(0xff4DB6AC),
    no400: Color(0xff26A69A),
    no700: Color(0xff00796B),
  ),
  green(
    no50: Color(0xffE8F5E9),
    no100: Color(0xffC8E6C9),
    no300: Color(0xff81C784),
    no400: Color(0xff66BB6A),
    no700: Color(0xff388E3C),
  ),
  lightGreen(
    no50: Color(0xffF1F8E9),
    no100: Color(0xffDCEDC8),
    no300: Color(0xffAED581),
    no400: Color(0xff9CCC65),
    no700: Color(0xff689F38),
  ),
  lime(
    no50: Color(0xffF9FBE7),
    no100: Color(0xffF0F4C3),
    no300: Color(0xffDCE775),
    no400: Color(0xffD4E157),
    no700: Color(0xffAFB42B),
  ),
  yellow(
    no50: Color(0xffFFFDE7),
    no100: Color(0xffFFF9C4),
    no300: Color(0xffFFF176),
    no400: Color(0xffFFEE58),
    no700: Color(0xffFBC02D),
  ),
  amber(
    no50: Color(0xffFFF8E1),
    no100: Color(0xffFFECB3),
    no300: Color(0xffFFD54F),
    no400: Color(0xffFFCA28),
    no700: Color(0xffFFA000),
  ),
  orange(
    no50: Color(0xffFFF3E0),
    no100: Color(0xffFFE0B2),
    no300: Color(0xffFFB74D),
    no400: Color(0xffFFA726),
    no700: Color(0xffF57C00),
  ),
  deepOrange(
    no50: Color(0xffFBE9E7),
    no100: Color(0xffFFCCBC),
    no300: Color(0xffFF8A65),
    no400: Color(0xffFF7043),
    no700: Color(0xffE64A19),
  ),
  brown(
    no50: Color(0xffEFEBE9),
    no100: Color(0xffD7CCC8),
    no300: Color(0xffBCAAA4),
    no400: Color(0xff8D6E63),
    no700: Color(0xff5D4037),
  ),
  grey(
    no50: Color(0xffFAFAFA),
    no100: Color(0xffF5F5F5),
    no300: Color(0xffE0E0E0),
    no400: Color(0xffBDBDBD),
    no700: Color(0xff616161),
  ),
  blueGrey(
    no50: Color(0xffECEFF1),
    no100: Color(0xffCFD8DC),
    no300: Color(0xff90A4AE),
    no400: Color(0xff78909C),
    no700: Color(0xff455A64),
  );

  /// 50番
  final Color no50;

  /// 100番
  final Color no100;

  /// 300番
  final Color no300;

  /// 400番
  final Color no400;

  /// 700番
  final Color no700;

  /// コンストラクタ
  const AppColor({
    required this.no50,
    required this.no100,
    required this.no300,
    required this.no400,
    required this.no700,
  });

  /// BodyやContainerの背景色向け
  Color get body => no100;

  /// グラデーションの色リスト：400から700へ
  List<Color> get gradientColors => [no400, no700];

  /// グラデーションの色リスト：50から300へ
  List<Color> get gradientLightColors => [no50, no300];
}

// Color(0xff)

/// 完了ボタンのグラデーション色
const List<Color> completedGradient = [Color(0xffC55255), Color(0xffB71C1C)];

/// 通常のグラデーション色
const List<Color> orengeGradient = [Color(0xFFF3C377), Color(0xFFDC9322)];
// const List<Color> greenGradient = [Color(0xFF81C784), Color(0xFF4CAF50)];
const List<Color> greenGradient = [Color(0xff77e5f3), Color(0xff77e5f3)];
