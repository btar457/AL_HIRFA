import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../shared/privacy_policy_screen.dart';
import '../shared/terms_screen.dart';
import '../shipping/shipping_register_screen.dart';
import 'login_screen.dart';
import '../../core/settings/app_prefs.dart';

class RegisterScreen extends StatefulWidget {
  final int? initialRoleIndex;
  const RegisterScreen({super.key, this.initialRoleIndex});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  int _selectedRole = 0;
  String _selectedCity = kCities.first;

  // "شركة شحن" مخفاة مؤقتاً — قسم الشحن مغلق (راجع onboarding_screen.dart
  // لنفس القرار). ShippingRegisterScreen نفسها لم تُحذف، فقط لا مدخل إليها.
  final _roles = [tr('مشتري', 'Buyer'), tr('حرفي', 'Artisan')];
  static const _roleKeys = ['customer', 'artisan'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRoleIndex ?? 0;
  }

  Widget _buildField({required String hint, TextEditingController? controller, bool obscure = false, Widget? suffix, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
      ),
    );
  }

  Future<void> _createAccount() async {
    final role = _roleKeys[_selectedRole];
    final auth = context.read<AuthProvider>();
    if (_passwordController.text != _confirmPasswordController.text) {
      AppError.showSnackbar(context, tr('كلمتا المرور غير متطابقتين', 'Passwords do not match'));
      return;
    }
    try {
      await auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: role,
        city: _selectedCity,
      );
      if (!mounted) return;
      if (role == 'shipping') {
        // شركات الشحن تكمل التسجيل عبر نموذج إضافي (بيانات الشركة والتأمين) قبل الدخول.
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingRegisterScreen()));
        return;
      }
      // لا دخول قبل تأكيد البريد (AuthService.needsEmailVerification)؛
      // والحرفيون ينتظرون أيضاً مراجعة الإدارة (ADMIN-4).
      await auth.signOut();
      if (!mounted) return;
      _showVerifyEmailDialog(isArtisan: role == 'artisan');
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    }
  }

  void _showVerifyEmailDialog({required bool isArtisan}) {
    final email = _emailController.text.trim();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(tr('أكّد بريدك الإلكتروني', 'Confirm your email'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          content: Text(
            tr('أرسلنا رابط تأكيد إلى $email — افتحه ثم سجّل الدخول (تفقّد أيضاً الرسائل غير المرغوب فيها).', 'We sent a confirmation link to $email — open it, then sign in (also check your spam folder).') +
            (isArtisan ? tr('\n\nبعد التأكيد، سيراجع فريق AL-HIRFA حسابك كحرفي وسنُعلمك عند الموافقة.', '\n\nAfter confirming, the AL-HIRFA team will review your artisan account and notify you once approved.') : ''),
            style: TextStyle(color: AppColors.subText),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
              child: Text(tr('حسناً', 'OK'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr('انضم إلى AL-HIRFA', 'Join AL-HIRFA'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _buildField(hint: tr('الاسم الكامل', 'Full name'), controller: _nameController),
                const SizedBox(height: 14),
                _buildField(hint: tr('البريد الإلكتروني', 'Email'), controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _buildField(hint: tr('رقم الهاتف', 'Phone number'), controller: _phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  dropdownColor: AppColors.card,
                  style: TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: tr('المدينة', 'City'),
                    hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                  ),
                  items: kCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => _selectedCity = value!),
                ),
                const SizedBox(height: 14),
                _buildField(
                  hint: tr('كلمة المرور', 'Password'),
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 14),
                _buildField(
                  hint: tr('تأكيد كلمة المرور', 'Confirm password'),
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 22),
                Text(tr('اختر دورك', 'Choose your role'), style: TextStyle(color: AppColors.subText, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(_roles.length, (i) {
                    final selected = _selectedRole == i;
                    return ChoiceChip(
                      label: Text(_roles[i]),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedRole = i),
                      backgroundColor: AppColors.card,
                      selectedColor: AppColors.gold,
                      labelStyle: TextStyle(color: selected ? Colors.black : AppColors.text, fontWeight: FontWeight.bold, fontSize: 13),
                      side: BorderSide(color: AppColors.gold.withOpacity(selected ? 1 : 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      activeColor: AppColors.gold,
                      onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: AppColors.subText, fontSize: 12),
                          children: [
                            TextSpan(text: tr('أوافق على ', 'I agree to the ')),
                            TextSpan(
                              text: tr('الشروط والأحكام', 'Terms & Conditions'),
                              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                            ),
                            TextSpan(text: tr(' و', ' and ')),
                            TextSpan(
                              text: tr('سياسة الخصوصية', 'Privacy Policy'),
                              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: (_termsAccepted && !auth.isLoading) ? _createAccount : null,
                    child: auth.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(tr('إنشاء الحساب', 'Create account'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tr('لديك حساب؟', 'Already have an account?'), style: TextStyle(color: AppColors.subText, fontSize: 13)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: Text(tr('سجّل الدخول', 'Sign in'), style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
