import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../auth/login_screen.dart';
import 'about_screen.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

/// شاشة الإعدادات العامة (SHARED-3).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderNotifications = true;
  bool _offerNotifications = true;
  bool _messageNotifications = true;
  bool _isArabic = true;

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تسجيل الخروج؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
              child: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildTile({required IconData icon, required String title, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.gold),
      title: Text(title, style: TextStyle(color: color ?? AppColors.text)),
      trailing: Icon(Icons.arrow_back_ios, color: AppColors.subText, size: 14),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSwitchTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.gold,
      title: Text(title, style: const TextStyle(color: AppColors.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('الإعدادات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          children: [
            _buildSectionTitle('الحساب'),
            _buildTile(icon: Icons.person_outline, title: 'تعديل الملف الشخصي'),
            _buildTile(icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
            _buildTile(icon: Icons.mail_outline, title: 'تغيير البريد الإلكتروني'),
            _buildSectionTitle('الإشعارات'),
            _buildSwitchTile(title: 'إشعارات الطلبات', value: _orderNotifications, onChanged: (v) => setState(() => _orderNotifications = v)),
            _buildSwitchTile(title: 'إشعارات العروض', value: _offerNotifications, onChanged: (v) => setState(() => _offerNotifications = v)),
            _buildSwitchTile(title: 'إشعارات الرسائل', value: _messageNotifications, onChanged: (v) => setState(() => _messageNotifications = v)),
            _buildSectionTitle('التطبيق'),
            SwitchListTile(
              value: _isArabic,
              onChanged: (v) => setState(() => _isArabic = v),
              activeThumbColor: AppColors.gold,
              title: const Text('اللغة', style: TextStyle(color: AppColors.text)),
              subtitle: Text(_isArabic ? 'عربي' : 'English', style: TextStyle(color: AppColors.subText, fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.gold),
              title: const Text('نسخة التطبيق', style: TextStyle(color: AppColors.text)),
              trailing: Text('1.0.0', style: TextStyle(color: AppColors.subText)),
            ),
            _buildSectionTitle('الخصوصية'),
            _buildTile(icon: Icons.privacy_tip_outlined, title: 'سياسة الخصوصية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
            _buildTile(icon: Icons.description_outlined, title: 'الشروط والأحكام', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()))),
            _buildTile(icon: Icons.info_outline, title: 'عن التطبيق', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
            Divider(color: AppColors.subText.withOpacity(0.2)),
            _buildTile(icon: Icons.logout, title: 'تسجيل الخروج', color: Colors.redAccent, onTap: _confirmLogout),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
