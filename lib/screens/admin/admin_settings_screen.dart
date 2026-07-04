import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../auth/login_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_commissions_screen.dart';
import 'admin_financials_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_products_screen.dart';

/// قائمة إعدادات بوابة المؤسس (تبويب "الإعدادات" ضمن AdminNav).
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  void _confirmLogout(BuildContext context) {
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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('الإعدادات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          children: [
            _buildTile(context, icon: Icons.percent, title: 'إدارة العمولات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCommissionsScreen()))),
            _buildTile(context, icon: Icons.account_balance_outlined, title: 'التسويات المالية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinancialsScreen()))),
            _buildTile(context, icon: Icons.notifications_outlined, title: 'إدارة الإشعارات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()))),
            _buildTile(context, icon: Icons.inventory_2_outlined, title: 'إدارة المنتجات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductsScreen()))),
            _buildTile(context, icon: Icons.category_outlined, title: 'إدارة الفئات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()))),
            Divider(color: AppColors.subText.withOpacity(0.2)),
            _buildTile(context, icon: Icons.logout, title: 'تسجيل الخروج', color: Colors.redAccent, onTap: () => _confirmLogout(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
