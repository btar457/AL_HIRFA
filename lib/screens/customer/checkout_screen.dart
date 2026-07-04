import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import '../shared/terms_screen.dart';
import 'order_tracking_screen.dart';

const int _kDeliveryFee = 5000;

const _kProvinces = [
  'بغداد', 'البصرة', 'النجف', 'أربيل', 'الموصل', 'كربلاء', 'الديوانية',
  'ذي قار', 'ميسان', 'واسط', 'صلاح الدين', 'الأنبار', 'ديالى', 'كركوك',
  'بابل', 'المثنى', 'القادسية',
];

int _parsePrice(String price) => int.parse(price.replaceAll(',', ''));

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class CheckoutScreen extends StatefulWidget {
  final MarketplaceProduct product;
  const CheckoutScreen({super.key, required this.product});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedProvince = _kProvinces.first;
  bool _cashAccepted = false;
  bool _policyAccepted = false;

  Widget _buildLabeledField({
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

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

  void _confirmOrder() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تأكيد الطلب؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('سيتم إرسال طلبك للبائع للمراجعة', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(product: widget.product)));
              },
              child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productPrice = _parsePrice(widget.product.price);
    final total = productPrice + _kDeliveryFee;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('تأكيد الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductSummary(),
              const SizedBox(height: 24),
              _buildLabeledField(
                label: 'الاسم الكامل',
                field: TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AppColors.text),
                  decoration: _fieldDecoration(),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: 'رقم الهاتف',
                field: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  style: const TextStyle(color: AppColors.text),
                  decoration: _fieldDecoration(hint: '07xxxxxxxxx'),
                ),
              ),
              _buildLabeledField(
                label: 'المحافظة',
                field: DropdownButtonFormField<String>(
                  initialValue: _selectedProvince,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.text),
                  decoration: _fieldDecoration(),
                  items: _kProvinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (value) => setState(() => _selectedProvince = value!),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: 'المنطقة/الحي',
                field: TextFormField(
                  controller: _neighborhoodController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: _fieldDecoration(),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabeledField(
                label: 'ملاحظات للمندوب (اختياري)',
                field: TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.text),
                  decoration: _fieldDecoration(),
                ),
              ),
              const SizedBox(height: 24),
              _buildInvoiceCard(productPrice, total),
              const SizedBox(height: 16),
              _buildPaymentMethod(),
              const SizedBox(height: 16),
              _buildAcceptanceCheckboxes(),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: (_cashAccepted && _policyAccepted) ? _confirmOrder : null,
                  child: const Text('تأكيد الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('أبو مصطفى', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                const SizedBox(height: 4),
                Text('د.ع ${widget.product.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(int productPrice, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        children: [
          _invoiceRow('سعر المنتج', _formatPrice(productPrice)),
          const SizedBox(height: 8),
          _invoiceRow('سعر التوصيل', _formatPrice(_kDeliveryFee)),
          const SizedBox(height: 12),
          Divider(color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_formatPrice(total)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 14)),
        Text('$value د.ع', style: const TextStyle(color: AppColors.text, fontSize: 14)),
      ],
    );
  }

  Widget _buildAcceptanceCheckboxes() {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          CheckboxListTile(
            value: _cashAccepted,
            activeColor: AppColors.gold,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('أفهم أن الدفع كاشاً عند الاستلام فقط', style: TextStyle(color: AppColors.text, fontSize: 13)),
            onChanged: (val) => setState(() => _cashAccepted = val ?? false),
          ),
          CheckboxListTile(
            value: _policyAccepted,
            activeColor: AppColors.gold,
            controlAffinity: ListTileControlAffinity.leading,
            title: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.text, fontSize: 13),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  TextSpan(
                    text: 'سياسة الإرجاع',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                  ),
                ],
              ),
            ),
            onChanged: (val) => setState(() => _policyAccepted = val ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: AppColors.gold),
          const SizedBox(width: 12),
          const Expanded(child: Text('الدفع عند الاستلام', style: TextStyle(color: AppColors.text))),
          const Icon(Icons.check_circle, color: AppColors.gold),
        ],
      ),
    );
  }
}
