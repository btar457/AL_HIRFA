import 'package:flutter/material.dart';

/// لوحة الألوان الموحدة للتطبيق. يجب استخدام هذه الثوابت بدلاً من كتابة
/// قيم Color مباشرة داخل الشاشات والويدجتات.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color card = surface;
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8C96D);
  static const Color text = Colors.white;
  static const Color subText = Color(0xFF888888);
}
