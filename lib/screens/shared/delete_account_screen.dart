import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../../core/settings/app_prefs.dart';

/// حذف الحساب نهائياً — يفي بمتطلب Google Play لحذف الحسابات (Account
/// Deletion policy): مسار حذف حقيقي داخل التطبيق، لا عبر الدعم فقط.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _confirmed = false;
  bool _isDeleting = false;

  Future<void> _delete() async {
    setState(() => _isDeleting = true);
    try {
      await context.read<AuthProvider>().deleteAccount(password: _passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('تم حذف حسابك نهائياً', 'Your account has been permanently deleted'))),
      );
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('حذف الحساب نهائياً؟', 'Permanently delete account?'), style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          content: Text(
            tr('لا يمكن التراجع عن هذا الإجراء. سيُحذف حسابك ولن تتمكّن من الدخول مجدداً بهذا البريد.', 'This can\'t be undone. Your account will be deleted and you won\'t be able to sign in with this email again.'),
            style: TextStyle(color: AppColors.subText),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(tr('حذف نهائياً', 'Delete permanently'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) await _delete();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _passwordController.text.isNotEmpty && _confirmed;
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(tr('حذف الحساب', 'Delete account'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: AppColors.gold),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr('ماذا يحدث عند حذف حسابك:', 'What happens when you delete your account:'), style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 10),
                    Text(tr('• تُحذف بياناتك الشخصية (الاسم، الصورة، رقم الهاتف، IBAN) نهائياً.', '• Your personal data (name, photo, phone number, IBAN) is permanently deleted.'), style: TextStyle(color: AppColors.text, fontSize: 13, height: 22 / 13)),
                    SizedBox(height: 6),
                    Text(tr('• لن تتمكّن من تسجيل الدخول بهذا الحساب مرة أخرى.', '• You won\'t be able to sign in to this account again.'), style: TextStyle(color: AppColors.text, fontSize: 13, height: 22 / 13)),
                    SizedBox(height: 6),
                    Text(tr('• سجلات الطلبات والمعاملات المالية تبقى محفوظة كما هي للامتثال القانوني، دون ربطها باسمك الظاهر.', '• Order and financial records are kept for legal compliance, without being linked to your displayed name.'), style: TextStyle(color: AppColors.text, fontSize: 13, height: 22 / 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(tr('أدخل كلمة المرور لتأكيد هويتك', 'Enter your password to confirm it\'s you'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: tr('كلمة المرور الحالية', 'Current password'),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => setState(() => _confirmed = !_confirmed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _confirmed,
                      onChanged: (v) => setState(() => _confirmed = v ?? false),
                      activeColor: Colors.redAccent,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(tr('أفهم أن هذا الإجراء نهائي ولا يمكن التراجع عنه', 'I understand this is permanent and can\'t be undone'), style: TextStyle(color: AppColors.text, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.redAccent.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: (isValid && !_isDeleting) ? _confirmAndDelete : null,
                  child: _isDeleting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(tr('حذف حسابي نهائياً', 'Delete my account permanently'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
