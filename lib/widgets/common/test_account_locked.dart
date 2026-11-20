import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/settings/app_prefs.dart';

/// يُعرض بدل شاشتي تغيير كلمة المرور وحذف الحساب لحسابات المختبرين
/// المشتركة (isTestAccount): مختبر واحد كان سيُقفل الحساب على الجميع.
class TestAccountLocked extends StatelessWidget {
  final String title;
  const TestAccountLocked({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: IconThemeData(color: AppColors.gold),
          title: Text(title, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_outlined, color: AppColors.gold, size: 60),
                const SizedBox(height: 16),
                Text(
                  tr('هذا حساب تجريبي مشترك بين المختبرين، لذلك لا يمكن تغيير كلمة مروره أو حذفه.',
                      'This is a shared tester account, so its password can\'t be changed and it can\'t be deleted.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.subText, height: 1.6, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
