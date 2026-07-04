import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../auth/login_screen.dart';
import 'favorites_screen.dart';
import 'orders_history_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

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

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap, Color? color}) {
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
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSettingsTile(context, icon: Icons.person_outline, title: 'تعديل البيانات الشخصية'),
            _buildSettingsTile(context, icon: Icons.inventory_2_outlined, title: 'سجل طلباتي', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()))),
            _buildSettingsTile(context, icon: Icons.favorite_border, title: 'المفضلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
            _buildSettingsTile(context, icon: Icons.notifications_outlined, title: 'إعدادات الإشعارات'),
            _buildSettingsTile(context, icon: Icons.lock_outline, title: 'تغيير كلمة المرور'),
            _buildSettingsTile(context, icon: Icons.description_outlined, title: 'الشروط والأحكام'),
            _buildSettingsTile(context, icon: Icons.privacy_tip_outlined, title: 'سياسة الخصوصية'),
            _buildSettingsTile(context, icon: Icons.info_outline, title: 'عن التطبيق'),
            Divider(color: AppColors.subText.withOpacity(0.2)),
            _buildSettingsTile(context, icon: Icons.logout, title: 'تسجيل الخروج', color: Colors.redAccent, onTap: () => _confirmLogout(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.gold, Color(0xFF8B6B1F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
            ),
          ),
          Positioned(
            top: 105,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.background, width: 3)),
                      child: const Icon(Icons.person, color: AppColors.gold, size: 44),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 2)),
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('سارة العبيدي', style: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('sara.alobaidi@example.com', style: TextStyle(color: AppColors.subText, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
