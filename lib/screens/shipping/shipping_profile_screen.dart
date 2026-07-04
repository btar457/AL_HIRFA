import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../auth/login_screen.dart';
import '../shared/change_password_screen.dart';
import '../shared/terms_screen.dart';
import 'shipping_wallet_screen.dart';

/// الملف الشخصي لشركة الشحن (SHIPPING-8).
class ShippingProfileScreen extends StatelessWidget {
  const ShippingProfileScreen({super.key});

  static const _provinces = ['بغداد', 'النجف', 'كربلاء', 'البصرة'];

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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildInfoRow('اسم الشركة', 'شركة بغداد السريعة للشحن'),
                        _buildInfoRow('رقم السجل التجاري', '2024-8871'),
                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: Text('المحافظات التي تعمل بها', style: TextStyle(color: AppColors.subText, fontSize: 12))),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _provinces.map((p) => Chip(
                            label: Text(p, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                            backgroundColor: AppColors.gold,
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('رقم الهاتف', '07801234567'),
                        _buildInfoRow('البريد الإلكتروني', 'info@baghdad-express.iq'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: const [Icon(Icons.lock_outline, color: AppColors.gold, size: 18), SizedBox(width: 8), Text('الحساب المصرفي (IBAN)', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13))]),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('IQ98IHRF00000000009921', style: TextStyle(color: AppColors.text, fontSize: 13)),
                            TextButton(onPressed: () {}, child: const Text('تعديل', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('التوصيلات المكتملة', '312')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard('التقييم', '⭐ 4.9')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard('الالتزام', '98%')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildTile(context, icon: Icons.account_balance_wallet_outlined, title: 'محفظة الشركة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingWalletScreen()))),
            _buildTile(context, icon: Icons.description_outlined, title: 'شروط الشراكة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()))),
            _buildTile(context, icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
            _buildTile(context, icon: Icons.logout, title: 'تسجيل الخروج', color: Colors.redAccent, onTap: () => _confirmLogout(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppColors.subText, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 110,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.gold, Color(0xFF8B6B1F)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          ),
          Positioned(
            top: 60,
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.background, width: 3)),
                  child: const Icon(Icons.local_shipping, color: AppColors.gold, size: 40),
                ),
                const SizedBox(height: 10),
                const Text('شركة بغداد السريعة للشحن', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('شركة شحن موثّقة ✓', style: TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
