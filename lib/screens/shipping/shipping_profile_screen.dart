import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../auth/login_screen.dart';
import '../shared/change_password_screen.dart';
import '../shared/terms_screen.dart';
import 'shipping_wallet_screen.dart';

/// الملف الشخصي لشركة الشحن (SHIPPING-8).
class ShippingProfileScreen extends StatefulWidget {
  const ShippingProfileScreen({super.key});
  @override
  State<ShippingProfileScreen> createState() => _ShippingProfileScreenState();
}

class _ShippingProfileScreenState extends State<ShippingProfileScreen> {
  bool _obscureIban = true;

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تسجيل الخروج؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              },
              child: const Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _editIban(String currentIban) {
    final ibanController = TextEditingController(text: currentIban);
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تعديل IBAN', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: ibanController,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                await context.read<AuthProvider>().updateProfile({'iban': ibanController.text.trim()});
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                AppError.showSnackbar(context, 'تم تحديث IBAN', isError: false);
              },
              child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final user = context.watch<AuthProvider>().currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: user == null
            ? Center(child: Text('سجّل الدخول لعرض ملفك', style: TextStyle(color: AppColors.subText)))
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(user.companyName.isNotEmpty ? user.companyName : user.name),
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
                              _buildInfoRow('اسم الشركة', user.companyName.isNotEmpty ? user.companyName : '—'),
                              _buildInfoRow('رقم السجل التجاري', user.registrationNumber.isNotEmpty ? user.registrationNumber : '—'),
                              const SizedBox(height: 8),
                              Align(alignment: Alignment.centerRight, child: Text('المحافظات التي تعمل بها', style: TextStyle(color: AppColors.subText, fontSize: 12))),
                              const SizedBox(height: 8),
                              if (user.provinces.isEmpty)
                                Align(alignment: Alignment.centerRight, child: Text('لا توجد محافظات مسجَّلة', style: TextStyle(color: AppColors.subText, fontSize: 12)))
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: user.provinces.map((p) => Chip(
                                    label: Text(p, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                                    backgroundColor: AppColors.gold,
                                  )).toList(),
                                ),
                              const SizedBox(height: 8),
                              _buildInfoRow('رقم الهاتف', user.phone),
                              _buildInfoRow('البريد الإلكتروني', user.email),
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
                                  Expanded(
                                    child: Text(
                                      user.iban.isEmpty ? 'لم يُسجَّل بعد' : (_obscureIban ? '•' * user.iban.length : user.iban),
                                      style: const TextStyle(color: AppColors.text, fontSize: 13),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(_obscureIban ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold, size: 18),
                                    onPressed: () => setState(() => _obscureIban = !_obscureIban),
                                  ),
                                  TextButton(onPressed: () => _editIban(user.iban), child: const Text('تعديل', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        StreamBuilder<List<OrderModel>>(
                          stream: OrderService.instance.getShippingOrders(user.uid),
                          builder: (context, snapshot) {
                            final delivered = (snapshot.data ?? const []).where((o) => o.status == 'delivered').length;
                            return Row(
                              children: [
                                Expanded(child: _buildStatCard('التوصيلات المكتملة', '$delivered')),
                              ],
                            );
                          },
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

  Widget _buildHeader(String companyName) {
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
                Text(companyName, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
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
