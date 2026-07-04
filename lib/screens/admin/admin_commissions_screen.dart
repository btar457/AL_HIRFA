import 'package:flutter/material.dart';
import '../../core/constants/app_rules.dart';
import '../../core/constants/colors.dart';

/// إدارة العمولات وسعر التوصيل الثابت (ADMIN-8).
class AdminCommissionsScreen extends StatefulWidget {
  const AdminCommissionsScreen({super.key});
  @override
  State<AdminCommissionsScreen> createState() => _AdminCommissionsScreenState();
}

class _AdminCommissionsScreenState extends State<AdminCommissionsScreen> {
  double _productCommission = AppRules.productCommission * 100;
  double _shippingCommission = AppRules.shippingCommission * 100;
  int _deliveryFee = AppRules.fixedDeliveryFee;

  Future<void> _editValue({required String title, required String initialValue, required ValueChanged<String> onSave}) async {
    final controller = TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionCard({required String label, required String value, required VoidCallback onEdit}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('تعديل', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold))),
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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('إدارة العمولات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCommissionCard(
              label: 'عمولة المنتجات',
              value: '${_productCommission.toStringAsFixed(0)}%',
              onEdit: () => _editValue(title: 'عمولة المنتجات (%)', initialValue: _productCommission.toStringAsFixed(0), onSave: (v) => setState(() => _productCommission = double.tryParse(v) ?? _productCommission)),
            ),
            _buildCommissionCard(
              label: 'عمولة الشحن',
              value: '${_shippingCommission.toStringAsFixed(0)}%',
              onEdit: () => _editValue(title: 'عمولة الشحن (%)', initialValue: _shippingCommission.toStringAsFixed(0), onSave: (v) => setState(() => _shippingCommission = double.tryParse(v) ?? _shippingCommission)),
            ),
            _buildCommissionCard(
              label: 'سعر التوصيل الثابت',
              value: '$_deliveryFee د.ع',
              onEdit: () => _editValue(title: 'سعر التوصيل الثابت (د.ع)', initialValue: '$_deliveryFee', onSave: (v) => setState(() => _deliveryFee = int.tryParse(v) ?? _deliveryFee)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.withOpacity(0.3))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_outlined, color: Colors.amber, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text('تغيير العمولات يؤثر على جميع الطلبات الجديدة فقط.', style: TextStyle(color: AppColors.text, fontSize: 13, height: 24 / 13))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
