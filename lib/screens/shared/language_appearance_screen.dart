import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/settings/app_prefs.dart';

/// اختيار لغة الواجهة والمظهر. تظهر مرة واحدة عند أول تشغيل (قبل الدخول،
/// عبر AuthGate)، ومن الإعدادات لاحقاً. الحفظ يعيد بناء التطبيق كاملاً
/// باللغة/المظهر الجديدين (راجع AlHirfaApp في main.dart).
class LanguageAppearanceScreen extends StatefulWidget {
  final bool firstRun;
  const LanguageAppearanceScreen({super.key, this.firstRun = false});

  @override
  State<LanguageAppearanceScreen> createState() => _LanguageAppearanceScreenState();
}

class _LanguageAppearanceScreenState extends State<LanguageAppearanceScreen> {
  late String _language = AppPrefs.language;
  late bool _isDark = AppPrefs.isDark;

  bool get _en => _language == 'en';
  // نصوص الشاشة تتبع الاختيار الحالي فوراً (قبل الحفظ) كمعاينة.
  String _t(String ar, String en) => _en ? en : ar;

  Widget _option({required bool selected, required VoidCallback onTap, required Widget leading, required String label}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.gold : AppColors.gold.withOpacity(0.25), width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              leading,
              const SizedBox(height: 10),
              Text(label, style: TextStyle(color: selected ? AppColors.gold : AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(text, style: TextStyle(color: AppColors.subText, fontSize: 14, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _en ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: widget.firstRun
            ? null
            : AppBar(
                backgroundColor: AppColors.background,
                iconTheme: IconThemeData(color: AppColors.gold),
                title: Text(_t('اللغة والمظهر', 'Language & appearance'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.firstRun) ...[
                  const SizedBox(height: 24),
                  Text('AL-HIRFA', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4)),
                  const SizedBox(height: 8),
                  Text(_t('اختر لغتك ومظهر التطبيق', 'Choose your language and theme'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 15)),
                  const SizedBox(height: 36),
                ],
                _sectionTitle(_t('اللغة', 'Language')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _option(
                      selected: !_en,
                      onTap: () => setState(() => _language = 'ar'),
                      leading: Text('ع', style: TextStyle(color: AppColors.gold, fontSize: 30, fontWeight: FontWeight.bold)),
                      label: 'العربية',
                    ),
                    const SizedBox(width: 14),
                    _option(
                      selected: _en,
                      onTap: () => setState(() => _language = 'en'),
                      leading: Text('A', style: TextStyle(color: AppColors.gold, fontSize: 30, fontWeight: FontWeight.bold)),
                      label: 'English',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _sectionTitle(_t('المظهر', 'Appearance')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _option(
                      selected: _isDark,
                      onTap: () => setState(() => _isDark = true),
                      leading: Icon(Icons.dark_mode_outlined, color: AppColors.gold, size: 32),
                      label: _t('داكن', 'Dark'),
                    ),
                    const SizedBox(width: 14),
                    _option(
                      selected: !_isDark,
                      onTap: () => setState(() => _isDark = false),
                      leading: Icon(Icons.light_mode_outlined, color: AppColors.gold, size: 32),
                      label: _t('فاتح', 'Light'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => AppPrefs.instance.update(language: _language, isDark: _isDark),
                    child: Text(widget.firstRun ? _t('متابعة', 'Continue') : _t('حفظ', 'Save'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                ),
                if (!widget.firstRun) ...[
                  const SizedBox(height: 12),
                  Text(
                    _t('سيُعاد تحميل التطبيق لتطبيق التغيير.', 'The app will reload to apply the change.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subText, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
