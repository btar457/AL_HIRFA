import 'package:flutter/material.dart';
import '../settings/app_prefs.dart';

/// لوحة الألوان الموحدة للتطبيق. يجب استخدام هذه القيم بدلاً من كتابة
/// قيم Color مباشرة داخل الشاشات والويدجتات.
///
/// القيم getters لا ثوابت: تتبع المظهر المختار (AppPrefs.isDark)، ويُعاد
/// بناء التطبيق كاملاً عند تغييره — لذا لا تُستخدم داخل تعابير const.
class AppColors {
  AppColors._();

  static bool get _dark => AppPrefs.isDark;

  static Color get background => _dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F3EA);
  static Color get surface => _dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
  static Color get card => surface;
  // الذهبي الأصلي باهت على خلفية فاتحة — نسخة أغمق تحافظ على التباين.
  static Color get gold => _dark ? const Color(0xFFD4AF37) : const Color(0xFFA8841F);
  static Color get goldLight => _dark ? const Color(0xFFE8C96D) : const Color(0xFFC9A43A);
  static Color get text => _dark ? Colors.white : const Color(0xFF1C1A16);
  static Color get subText => _dark ? const Color(0xFF888888) : const Color(0xFF6B655A);

  // مركزيان بدل تكرارهما كقيم Color خام في نحو 9 ملفات (شريط التنقل السفلي
  // في الأدوار الأربعة، فواصل داخل بطاقات الطلبات).
  static Color get navBackground => _dark ? const Color(0xFF111111) : const Color(0xFFFFFFFF);
  static Color get divider => _dark ? const Color(0xFF2A2A2A) : const Color(0xFFE5DED0);

  /// طبقة تعتيم فوق صور الخلفية (الدخول/الترحيب) — داكنة أو فاتحة حسب
  /// المظهر، كي يبقى النص فوقها مقروءاً في الحالتين.
  static Color get imageOverlay => _dark ? Colors.black.withOpacity(0.75) : const Color(0xFFF7F3EA).withOpacity(0.86);
}
