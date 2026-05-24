import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const bg          = Color(0xFFE8ECF0);
  static const surface     = Color(0xFFF0F3F7);
  static const rowAlt      = Color(0xFFEAEEF3);
  static const rowSelected = Color(0xFFFFFBCC);
  static const inputBox    = Color(0xFFFFFFFF);
  static const tableBorder = Color(0xFFB0BCC8);
  static const headerBg    = Color(0xFF1C2640);
  static const numpadBg    = Color(0xFFCDD6E2);
  static const numpadKey   = Color(0xFFBBC8D8);
  static const numpadHex   = Color(0xFFA8BCCC);
  static const numpadTop   = Color(0xFF8CA0B4);
  static const accent      = Color(0xFF2A5A9A);
  static const accentLight = Color(0xFF3A7ABB);
  static const success     = Color(0xFF2E8B2E);
  static const danger      = Color(0xFFB83232);
  static const warn        = Color(0xFF7A6010);
  static const warnBg      = Color(0xFFFFFBCC);
  static const statusGreen = Color(0xFF2A7A2A);
  static const statusRed   = Color(0xFFCC2222);
  static const textPrimary = Color(0xFF1A2030);
  static const textSec     = Color(0xFF3A4A5A);
  static const textDim     = Color(0xFF7A8898);
  static const textOnDark  = Color(0xFFDDE8F4);
}

class AppText {
  AppText._();
  static const mono = 'monospace';
  static const headerTitle = TextStyle(fontFamily: mono, fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textOnDark, letterSpacing: 1);
  static const instruction = TextStyle(fontFamily: mono, fontSize: 9,  color: AppColors.warn, fontWeight: FontWeight.w600);
  static const menuCode    = TextStyle(fontFamily: mono, fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500, letterSpacing: 1);
  static const menuLabel   = TextStyle(fontFamily: mono, fontSize: 11, color: AppColors.textPrimary);
  static const fieldNum    = TextStyle(fontFamily: mono, fontSize: 10, color: AppColors.textSec);
  static const fieldLabel  = TextStyle(fontFamily: mono, fontSize: 10, color: AppColors.textPrimary);
  static const fieldValue  = TextStyle(fontFamily: mono, fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500);
  static const rangeText   = TextStyle(fontFamily: mono, fontSize: 9,  color: AppColors.textSec);
  static const numpadKey   = TextStyle(fontFamily: mono, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

class AppTheme {
  AppTheme._();
  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(primary: AppColors.accent, surface: AppColors.surface),
    useMaterial3: true,
  );
}
