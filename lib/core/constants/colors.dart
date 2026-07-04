import 'package:flutter/material.dart';

/// لوحة الألوان الموحدة للتطبيق. يجب استخدام هذه الثوابت بدلاً من كتابة
/// قيم Color مباشرة داخل الشاشات والويدجتات.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF111111);
  static const Color card = Color(0xFF1A1A1A);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF0D060);
  static const Color text = Colors.white;
  static const Color subText = Color(0xFFAAAAAA);

  // ألوان خاصة بشاشة محادثة مستشار الجودة
  static const Color chatBackground = Color(0xFF0F0F0F);
  static const Color chatAppBar = Color(0xFF161616);
  static const Color chatUserBubble = Color(0xFF8B5A2B);
  static const Color chatInputFill = Color(0xFF262626);
}
