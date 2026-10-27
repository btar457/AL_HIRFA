import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

/// الثيم المركزي للتطبيق (Cairo + السمة الداكنة الذهبية).
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(primary: AppColors.gold, surface: AppColors.background),
      fontFamily: GoogleFonts.cairo().fontFamily,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
    );
  }
}
