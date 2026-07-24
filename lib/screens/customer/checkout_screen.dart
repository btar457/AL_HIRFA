import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/app_settings_model.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/app_settings_service.dart';
import '../../services/order_service.dart';
import '../shared/terms_screen.dart';
import 'orders_history_screen.dart';

const _kProvinces = [
  'بغداد', 'البصرة', 'النجف', 'أربيل', 'الموصل', 'كربلاء', 'الديوانية',
  'ذي قار', 'ميسان', 'واسط', 'صلاح الدين', 'الأنبار', 'ديالى', 'كركوك',
  'بابل', 'المثنى', 'القادسية',
];

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

/// شاشة تأكيد الطلب — تنشئ طلباً منفصلاً لكل عنصر في السلة (كل منتج له
/// حرفي مختلف يحتاج موافقة وشحناً مستقلَّين).
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
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
  bool _isSubmitting = false;
  AppSettingsModel? _settings;

  @override
  void initState() {
    super.initState();
    AppSettingsService.instance.getSettings().then((settings) {
      if (!mounted) return;
      setState(() => _settings = settings);
      context.read<CartProvider>().setDeliveryFeePerItem(settings.fixedDeliveryFee);
    });
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
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty || _neighborhoodController.text.trim().isEmpty) {
      AppError.showSnackbar(context, 'أكمل بيانات التوصيل أولاً');
      return;
    }
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
                _placeOrders();
              },
              child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrders() async {
    final cart = context.read<CartProvider>();
    final buyer = context.read<AuthProvider>().currentUser;
    if (buyer == null || cart.items.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final settings = _settings ?? await AppSettingsService.instance.getSettings();
      final orders = cart.items.map((item) {
        final product = item.product;
        final linePrice = product.price * item.quantity;
        final commission = (linePrice * settings.productCommission).round();
        return OrderModel(
          id: '',
          orderNumber: '',
          productId: product.id,
          productName: product.name,
          productImage: product.images.isNotEmpty ? product.images.first : '',
          price: linePrice,
          deliveryFee: settings.fixedDeliveryFee,
          totalAmount: linePrice + settings.fixedDeliveryFee,
          platformFee: commission + settings.platformDeliveryFee,
          artisanEarnings: linePrice - commission,
          shippingEarnings: settings.companyNetDelivery,
          buyerUid: buyer.uid,
          buyerName: _nameController.text.trim(),
          buyerPhone: _phoneController.text.trim(),
          governorate: _selectedProvince,
          district: _neighborhoodController.text.trim(),
          addressNotes: _notesController.text.trim(),
          artisanUid: product.artisanUid,
          artisanName: product.artisanName,
          status: 'pending',
          createdAt: DateTime.now(),
        );
      }).toList();
      // دفعة (WriteBatch) ذرّية واحدة لكل طلبات السلة — إما تُنشأ كلها معاً
      // أو لا يُنشأ أي منها؛ السلة لا تُفرَّغ إلا بعد نجاحها بالكامل.
      await OrderService.instance.createOrders(orders);
      cart.clearCart();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OrdersHistoryScreen()), (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('تأكيد الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: cart.items.isEmpty
            ? Center(child: Text('السلة فارغة', style: TextStyle(color: AppColors.subText)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(cart),
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
                    _buildInvoiceCard(cart),
                    const SizedBox(height: 16),
                    _buildPaymentMethod(),
                    const SizedBox(height: 16),
                    _buildAcceptanceCheckboxes(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: (_cashAccepted && _policyAccepted && !_isSubmitting) ? _confirmOrder : null,
                        child: _isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text('تأكيد الطلب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: cart.items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                ProductThumbnail(imageUrl: item.product.images.isNotEmpty ? item.product.images.first : '', size: 56, iconSize: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(item.product.artisanName, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                    ],
                  ),
                ),
                Text('${item.quantity} × ${_formatPrice(item.product.price)}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInvoiceCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        children: [
          _invoiceRow('سعر المنتجات', _formatPrice(cart.subtotal)),
          const SizedBox(height: 8),
          _invoiceRow('سعر التوصيل (${cart.items.length} × ${_settings?.fixedDeliveryFee ?? cart.deliveryFee})', _formatPrice(cart.deliveryFee)),
          const SizedBox(height: 12),
          Divider(color: AppColors.gold.withOpacity(0.4)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${_formatPrice(cart.total)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
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
