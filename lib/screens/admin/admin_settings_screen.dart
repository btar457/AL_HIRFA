import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_commissions_screen.dart';
import 'admin_financials_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_products_screen.dart';
import 'admin_stuck_orders_screen.dart';
import 'admin_test_accounts_screen.dart';
import '../../core/settings/app_prefs.dart';
import '../shared/language_appearance_screen.dart';

/// قائمة إعدادات بوابة المؤسس (تبويب "الإعدادات" ضمن AdminNav).
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('تسجيل الخروج؟', 'Sign out?'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(tr('هل أنت متأكد من رغبتك في تسجيل الخروج؟', 'Are you sure you want to sign out?'), style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              },
              child: Text(tr('تسجيل الخروج', 'Sign out'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.gold),
      title: Text(title, style: TextStyle(color: color ?? AppColors.text)),
      trailing: Icon(Icons.arrow_back_ios, color: AppColors.subText, size: 14),
      onTap: onTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: Text(tr('الإعدادات', 'Settings'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          children: [
            _buildTile(context, icon: Icons.percent, title: tr('إدارة العمولات', 'Manage commissions'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCommissionsScreen()))),
            _buildTile(context, icon: Icons.account_balance_outlined, title: tr('التسويات المالية', 'Financial settlements'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinancialsScreen()))),
            _buildTile(context, icon: Icons.notifications_outlined, title: tr('إدارة الإشعارات', 'Manage notifications'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()))),
            _buildTile(context, icon: Icons.inventory_2_outlined, title: tr('إدارة المنتجات', 'Manage products'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductsScreen()))),
            _buildTile(context, icon: Icons.category_outlined, title: tr('إدارة الفئات', 'Manage categories'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()))),
            _buildTile(context, icon: Icons.build_circle_outlined, title: tr('طلبات عالقة (شحن قديم)', 'Stuck orders (legacy shipping)'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStuckOrdersScreen()))),
            _buildTile(context, icon: Icons.badge_outlined, title: tr('حسابات المختبرين', 'Tester accounts'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTestAccountsScreen()))),
            Divider(color: AppColors.subText.withOpacity(0.2)),
            _buildTile(context, icon: Icons.translate, title: tr('اللغة والمظهر', 'Language & appearance'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageAppearanceScreen()))),
            _buildTile(context, icon: Icons.logout, title: tr('تسجيل الخروج', 'Sign out'), color: Colors.redAccent, onTap: () => _confirmLogout(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
