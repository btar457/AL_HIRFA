import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../settings/app_prefs.dart';

/// الثيم المركزي للتطبيق (Cairo + السمة الذهبية، داكنة أو فاتحة).
class AppTheme {
  AppTheme._();

  static ThemeData get current {
    final dark = AppPrefs.isDark;
    final base = dark ? ThemeData.dark() : ThemeData.light();
    return ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: dark
          ? ColorScheme.dark(primary: AppColors.gold, surface: AppColors.background)
          : ColorScheme.light(primary: AppColors.gold, surface: AppColors.background),
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
    );
  }
}
