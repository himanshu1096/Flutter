import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  static const bg          = Color(0xFFECEFF4);
  static const surface     = Color(0xFF1C2333);
  static const surface2    = Color(0xFFDDE3ED);
  static const surface3    = Color(0xFFF5F7FA);
  static const navBg       = Color(0xFF243044);
  static const navActive   = Color(0xFF1A6FA8);
  static const border      = Color(0xFFBDC8D8);
  static const borderDark  = Color(0xFF8FA0B8);
  static const accent      = Color(0xFF1A6FA8);
  static const accentLight = Color(0xFF3D9BD4);
  static const success     = Color(0xFF2E7D5E);
  static const danger      = Color(0xFFB83232);
  static const warn        = Color(0xFF8B6914);
  static const warnBg      = Color(0xFFFFFBE6);
  static const textPrimary = Color(0xFF1A2336);
  static const textSec     = Color(0xFF4A6080);
  static const textDim     = Color(0xFF8898AA);
  static const textOnDark  = Color(0xFFE8EEF6);
  static const textOnNav   = Color(0xFFB0C4DA);
  static const numpadBg    = Color(0xFF1C2840);
  static const numpadKey   = Color(0xFF263654);
  static const numpadHexKey= Color(0xFF1E3A5F);
  static const numpadOk    = Color(0xFF1B5E3B);
  static const numpadDel   = Color(0xFF5C1E1E);
  static const numpadClear = Color(0xFF5C4A00);
  static const rangeCard   = Color(0xFFE8F0F8);
  static const rangeBorder = Color(0xFF9DB8D4);
}

class AppText {
  AppText._();
  static const mono = 'monospace';
  static const headerTitle = TextStyle(fontFamily: mono, fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textOnDark, letterSpacing: 1.5);
  static const tabLabel    = TextStyle(fontFamily: mono, fontSize: 9,  fontWeight: FontWeight.w600);
  static const instruction = TextStyle(fontFamily: mono, fontSize: 8,  color: AppColors.warn, fontWeight: FontWeight.w600);
  static const fieldNum    = TextStyle(fontFamily: mono, fontSize: 9,  color: AppColors.textDim);
  static const fieldLabel  = TextStyle(fontFamily: mono, fontSize: 10, color: AppColors.textSec);
  static const fieldValue  = TextStyle(fontFamily: mono, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const hexBadge    = TextStyle(fontFamily: mono, fontSize: 7,  color: AppColors.accent, fontWeight: FontWeight.w700);
  static const memAddr     = TextStyle(fontFamily: mono, fontSize: 7,  color: AppColors.textDim);
  static const rangeLabel  = TextStyle(fontFamily: mono, fontSize: 8,  color: AppColors.textSec, letterSpacing: 0.5);
  static const rangeValue  = TextStyle(fontFamily: mono, fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600);
}

class AppTheme {
  AppTheme._();
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(primary: AppColors.accent, secondary: AppColors.success, error: AppColors.danger, surface: AppColors.surface3),
      dividerColor: AppColors.border,
      useMaterial3: true,
      splashColor: AppColors.accent.withOpacity(0.08),
      highlightColor: Colors.transparent,
    );
  }
}
