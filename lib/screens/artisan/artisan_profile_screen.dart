import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ArtisanProfileScreen extends StatefulWidget {
  const ArtisanProfileScreen({super.key});
  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  late final _nameController = TextEditingController(text: context.read<AuthProvider>().currentUser?.name ?? '');
  late final _ibanController = TextEditingController(text: context.read<AuthProvider>().currentUser?.iban ?? '');
  late String _selectedCity = context.read<AuthProvider>().currentUser?.city.isNotEmpty == true ? context.read<AuthProvider>().currentUser!.city : kCities.first;
  bool _obscureIban = true;
  bool _isSaving = false;

  InputDecoration _fieldDecoration({Widget? suffix}) {
    return InputDecoration(
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildLabeledField({required String label, required Widget field}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.gold)));
    try {
      await context.read<AuthProvider>().uploadProfilePhoto(File(picked.path));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await context.read<AuthProvider>().updateProfile({
        'name': _nameController.text.trim(),
        'city': _selectedCity,
        'iban': _ibanController.text.trim(),
      });
      if (!mounted) return;
      AppError.showSnackbar(context, 'تم حفظ التعديلات بنجاح', isError: false);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _confirmLogout() {
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

  Widget _buildSettingsTile({required IconData icon, required String title, VoidCallback? onTap, Color? color}) {
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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabeledField(label: 'الاسم الكامل', field: TextFormField(controller: _nameController, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                  const SizedBox(height: 14),
                  _buildLabeledField(
                    label: 'المدينة',
                    field: DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: AppColors.text),
                      decoration: _fieldDecoration(),
                      items: kCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (value) => setState(() => _selectedCity = value!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBankSection(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsTile(icon: Icons.lock_outline, title: 'تغيير كلمة المرور'),
            _buildSettingsTile(icon: Icons.description_outlined, title: 'الشروط والأحكام'),
            _buildSettingsTile(icon: Icons.logout, title: 'تسجيل الخروج', color: Colors.redAccent, onTap: _confirmLogout),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text('حفظ التعديلات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthProvider>().currentUser;
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.gold, Color(0xFF8B6B1F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
            ),
          ),
          Positioned(
            top: 115,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _changePhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.background, width: 3)),
                      child: (user?.photoUrl.isEmpty ?? true)
                          ? const Icon(Icons.person, color: AppColors.gold, size: 44)
                          : CachedNetworkImage(imageUrl: user!.photoUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.person, color: AppColors.gold, size: 44)),
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
            ),
          ),
          Positioned(
            top: 208,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  Text(user?.name ?? '', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.black, size: 12),
                        SizedBox(width: 4),
                        Text('حرفي موثّق', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lock_outline, color: AppColors.gold, size: 18),
              SizedBox(width: 8),
              Text('الحساب المصرفي (IBAN)', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ibanController,
            obscureText: _obscureIban,
            style: const TextStyle(color: AppColors.text),
            decoration: _fieldDecoration(
              suffix: IconButton(
                icon: Icon(_obscureIban ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                onPressed: () => setState(() => _obscureIban = !_obscureIban),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('يُستخدم لتحويل أرباحك عند طلب السحب', style: TextStyle(color: AppColors.subText, fontSize: 11)),
        ],
      ),
    );
  }
}
