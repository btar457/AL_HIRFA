import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/dispute_service.dart';
import '../../services/order_service.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

/// تحديث حالة توصيل حقيقي عبر Timeline خطوة بخطوة (SHIPPING-5).
class UpdateDeliveryScreen extends StatefulWidget {
  final String orderId;
  const UpdateDeliveryScreen({super.key, required this.orderId});

  @override
  State<UpdateDeliveryScreen> createState() => _UpdateDeliveryScreenState();
}

class _UpdateDeliveryScreenState extends State<UpdateDeliveryScreen> {
  String _selectedProblem = 'لا مشكلة';
  final _problemDetailsController = TextEditingController();
  bool _isUpdating = false;

  static const _problems = ['لا مشكلة', 'المشتري غير متاح', 'العنوان خاطئ', 'أخرى'];
  bool _isSendingReport = false;

  Future<void> _sendReport(OrderModel order) async {
    if (_selectedProblem == 'لا مشكلة') {
      Navigator.pop(context);
      return;
    }
    final shippingUid = context.read<AuthProvider>().currentUser?.uid;
    if (shippingUid == null) return;
    setState(() => _isSendingReport = true);
    try {
      await DisputeService.instance.createDispute(
        orderId: widget.orderId,
        reporterUid: shippingUid,
        reportedUid: order.buyerUid,
        type: 'delivery_issue',
        description: '$_selectedProblem: ${_problemDetailsController.text.trim()}',
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSendingReport = false);
    }
  }

  Future<void> _confirmPickup() async {
    setState(() => _isUpdating = true);
    try {
      await OrderService.instance.shippingPickedUp(widget.orderId);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _confirmDelivery(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تأكيد التسليم والمبلغ المحصّل', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('المبلغ المطلوب تحصيله: ${_formatPrice(order.totalAmount)} د.ع', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isUpdating = true);
                try {
                  await OrderService.instance.confirmDelivery(widget.orderId);
                  if (!mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!mounted) return;
                  AppError.showSnackbar(context, AppError.getFirebaseError(e));
                } finally {
                  if (mounted) setState(() => _isUpdating = false);
                }
              },
              child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String label, bool done, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(done ? Icons.check_circle : Icons.circle_outlined, color: done ? AppColors.gold : AppColors.subText, size: 22),
            if (!isLast) Container(width: 2, height: 32, color: done ? AppColors.gold.withOpacity(0.5) : AppColors.subText.withOpacity(0.3)),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(label, style: TextStyle(color: done ? AppColors.text : AppColors.subText, fontWeight: done ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        ),
      ],
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
          title: const Text('تحديث حالة التوصيل', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: StreamBuilder<OrderModel?>(
          stream: OrderService.instance.watchOrder(widget.orderId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            final order = snapshot.data!;
            final pickedUp = order.status != 'shipping_assigned';
            final delivered = order.status == 'delivered';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildStep('تم قبول الطلب', true),
                  _buildStep('استلمت من البائع', pickedUp),
                  _buildStep('في الطريق للمشتري', pickedUp),
                  _buildStep('تم التسليم', delivered, isLast: true),
                  const SizedBox(height: 16),
                  if (!pickedUp)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: _isUpdating ? null : _confirmPickup,
                        child: const Text('تأكيد الاستلام من البائع', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                      ),
                    )
                  else if (!delivered)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: _isUpdating ? null : () => _confirmDelivery(order),
                        child: const Text('تأكيد التسليم', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 28),
                  const Text('هل واجهت مشكلة؟', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedProblem,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.card,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: _problems.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (value) => setState(() => _selectedProblem = value!),
                  ),
                  if (_selectedProblem != 'لا مشكلة') ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _problemDetailsController,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'اشرح المشكلة',
                        hintStyle: TextStyle(color: AppColors.subText),
                        filled: true,
                        fillColor: AppColors.card,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: _isSendingReport ? null : () => _sendReport(order),
                      child: _isSendingReport
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('إرسال', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
