import 'package:flutter/material.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/colors.dart';
import '../auth/login_screen.dart';

/// تسجيل شركة شحن جديدة (SHIPPING-2).
class ShippingRegisterScreen extends StatefulWidget {
  const ShippingRegisterScreen({super.key});
  @override
  State<ShippingRegisterScreen> createState() => _ShippingRegisterScreenState();
}

class _ShippingRegisterScreenState extends State<ShippingRegisterScreen> {
  final _companyNameController = TextEditingController();
  final _registrationController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  final _ibanController = TextEditingController();
  final Set<String> _selectedProvinces = {};

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
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
        const SizedBox(height: 14),
      ],
    );
  }

  void _submit() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تم استلام طلبك', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          content: Text('سيراجع فريق AL-HIRFA طلبك خلال 24 ساعة وسنُعلمك بالنتيجة.', style: TextStyle(color: AppColors.subText)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false),
              child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('AL-HIRFA', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 8),
                const Text('تسجيل شركة شحن', textAlign: TextAlign.center, style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 28),
                const Text('معلومات الشركة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),
                _buildLabeledField(label: 'اسم الشركة', field: TextFormField(controller: _companyNameController, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                _buildLabeledField(label: 'رقم السجل التجاري', field: TextFormField(controller: _registrationController, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                Text('المحافظات التي تعمل بها', style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kCities.map((city) {
                    final selected = _selectedProvinces.contains(city);
                    return FilterChip(
                      label: Text(city),
                      selected: selected,
                      onSelected: (val) => setState(() => val ? _selectedProvinces.add(city) : _selectedProvinces.remove(city)),
                      backgroundColor: AppColors.card,
                      selectedColor: AppColors.gold,
                      labelStyle: TextStyle(color: selected ? Colors.black : AppColors.text, fontSize: 12, fontWeight: FontWeight.bold),
                      side: BorderSide(color: AppColors.gold.withOpacity(selected ? 1 : 0.4)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _buildLabeledField(label: 'رقم هاتف الشركة', field: TextFormField(controller: _companyPhoneController, keyboardType: TextInputType.phone, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                _buildLabeledField(label: 'البريد الإلكتروني', field: TextFormField(controller: _companyEmailController, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                const SizedBox(height: 8),
                const Text('مسؤول الشركة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 14),
                _buildLabeledField(label: 'اسم المسؤول', field: TextFormField(controller: _managerNameController, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                _buildLabeledField(label: 'رقم هاتفه الشخصي', field: TextFormField(controller: _managerPhoneController, keyboardType: TextInputType.phone, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: const [
                        Icon(Icons.info_outline, color: AppColors.gold, size: 18),
                        SizedBox(width: 8),
                        Text('مبلغ التأمين المطلوب: 500,000 د.ع', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                      ]),
                      const SizedBox(height: 8),
                      Text('يُودع عند التسجيل ويُعاد عند إنهاء العقد.', style: TextStyle(color: AppColors.subText, fontSize: 12, height: 24 / 12)),
                      Text('يُخصم منه عند التأخر أو المخالفات.', style: TextStyle(color: AppColors.subText, fontSize: 12, height: 24 / 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabeledField(label: 'الحساب المصرفي (IBAN) لاستلام المستحقات', field: TextFormField(controller: _ibanController, style: const TextStyle(color: AppColors.text), decoration: _fieldDecoration())),
                const SizedBox(height: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _submit,
                    child: const Text('تقديم طلب التسجيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
