import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/navigation/role_router.dart';
import '../shared/privacy_policy_screen.dart';
import '../shared/terms_screen.dart';
import '../shipping/shipping_register_screen.dart';
import 'login_screen.dart';

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

  final _roles = const ['مشتري', 'حرفي', 'شركة شحن'];
  static const _roleKeys = ['customer', 'artisan', 'shipping'];

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
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
      ),
    );
  }

  void _createAccount() {
    final role = _roleKeys[_selectedRole];
    if (role == 'shipping') {
      // شركات الشحن تكمل التسجيل عبر نموذج إضافي (بيانات الشركة والتأمين) قبل الدخول.
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingRegisterScreen()));
      return;
    }
    navigateByRole(context, role);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('انضم إلى AL-HIRFA', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _buildField(hint: 'الاسم الكامل', controller: _nameController),
                const SizedBox(height: 14),
                _buildField(hint: 'البريد الإلكتروني', controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _buildField(hint: 'رقم الهاتف', controller: _phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                _buildField(
                  hint: 'كلمة المرور',
                  controller: _passwordController,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 14),
                _buildField(
                  hint: 'تأكيد كلمة المرور',
                  controller: _confirmPasswordController,
                  obscure: _obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.gold),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 22),
                const Text('اختر دورك', style: TextStyle(color: AppColors.subText, fontSize: 13, fontWeight: FontWeight.bold)),
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
                            const TextSpan(text: 'أوافق على '),
                            TextSpan(
                              text: 'الشروط والأحكام',
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                            ),
                            const TextSpan(text: ' و'),
                            TextSpan(
                              text: 'سياسة الخصوصية',
                              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: _termsAccepted ? _createAccount : null,
                  child: const Text('إنشاء الحساب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('لديك حساب؟', style: TextStyle(color: AppColors.subText, fontSize: 13)),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Text('سجّل الدخول', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
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
