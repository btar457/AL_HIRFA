import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../shared/about_screen.dart';
import '../shared/change_password_screen.dart';
import '../shared/notifications_screen.dart';
import '../shared/privacy_policy_screen.dart';
import '../shared/terms_screen.dart';
import 'favorites_screen.dart';
import 'orders_history_screen.dart';
import 'payment_methods_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

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

  Future<void> _changePhoto(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !context.mounted) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.gold)));
    try {
      await context.read<AuthProvider>().uploadProfilePhoto(File(picked.path));
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    }
  }

  void _editPersonalInfo(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تعديل البيانات الشخصية', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(hintText: 'الاسم الكامل', hintStyle: TextStyle(color: AppColors.subText), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(hintText: 'رقم الهاتف', hintStyle: TextStyle(color: AppColors.subText), filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await auth.updateProfile({'name': nameController.text.trim(), 'phone': phoneController.text.trim()});
                    if (!sheetContext.mounted) return;
                    Navigator.pop(sheetContext);
                    AppError.showSnackbar(context, 'تم حفظ التعديلات', isError: false);
                  },
                  child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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
    final user = context.watch<AuthProvider>().currentUser;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context, user?.name ?? '', user?.email ?? '', user?.photoUrl ?? ''),
            const SizedBox(height: 12),
            _buildSettingsTile(context, icon: Icons.person_outline, title: 'تعديل البيانات الشخصية', onTap: () => _editPersonalInfo(context)),
            _buildSettingsTile(context, icon: Icons.inventory_2_outlined, title: 'سجل طلباتي', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()))),
            _buildSettingsTile(context, icon: Icons.favorite_border, title: 'المفضلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))),
            _buildSettingsTile(context, icon: Icons.payment_outlined, title: 'طرق الدفع', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()))),
            _buildSettingsTile(context, icon: Icons.notifications_outlined, title: 'الإشعارات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _buildSettingsTile(context, icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
            _buildSettingsTile(context, icon: Icons.description_outlined, title: 'الشروط والأحكام', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()))),
            _buildSettingsTile(context, icon: Icons.privacy_tip_outlined, title: 'سياسة الخصوصية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()))),
            _buildSettingsTile(context, icon: Icons.info_outline, title: 'عن التطبيق', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
            Divider(color: AppColors.subText.withOpacity(0.2)),
            _buildSettingsTile(context, icon: Icons.logout, title: 'تسجيل الخروج', color: Colors.redAccent, onTap: () => _confirmLogout(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String email, String photoUrl) {
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
                GestureDetector(
                  onTap: () => _changePhoto(context),
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.background, width: 3)),
                        child: photoUrl.isEmpty
                            ? const Icon(Icons.person, color: AppColors.gold, size: 44)
                            : CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.person, color: AppColors.gold, size: 44)),
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
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: AppColors.subText, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
