import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// لغة الواجهة والمظهر (فاتح/داكن)، محفوظان على الجهاز. قيم ثابتة (static)
/// عمداً: AppColors وtr() تقرآنها مباشرة من أي مكان دون BuildContext، و
/// AlHirfaApp يعيد بناء الشجرة كاملة عند تغييرها (راجع main.dart).
class AppPrefs extends ChangeNotifier {
  AppPrefs._();
  static final AppPrefs instance = AppPrefs._();

  static const _languageKey = 'app_language';
  static const _darkKey = 'app_dark_mode';

  static String _language = 'ar';
  static bool _isDark = true;
  static bool _hasChosen = false;

  static bool get isEnglish => _language == 'en';
  static bool get isDark => _isDark;
  /// هل اختار المستخدم اللغة والمظهر من قبل؟ (شاشة الاختيار تظهر مرة واحدة)
  static bool get hasChosen => _hasChosen;
  static String get language => _language;
  static TextDirection get dir => isEnglish ? TextDirection.ltr : TextDirection.rtl;
  static Locale get locale => Locale(_language);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasChosen = prefs.containsKey(_languageKey);
      _language = prefs.getString(_languageKey) ?? 'ar';
      _isDark = prefs.getBool(_darkKey) ?? true;
    } catch (_) {}
  }

  Future<void> update({String? language, bool? isDark}) async {
    if (language != null) _language = language;
    if (isDark != null) _isDark = isDark;
    _hasChosen = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, _language);
      await prefs.setBool(_darkKey, _isDark);
    } catch (_) {}
  }
}

/// نص الواجهة باللغة المختارة: العربية أولاً (اللغة الأصلية للتطبيق).
String tr(String ar, String en) => AppPrefs.isEnglish ? en : ar;
