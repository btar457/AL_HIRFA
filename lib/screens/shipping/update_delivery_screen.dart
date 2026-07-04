import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/delivery_request.dart';

/// تحديث حالة توصيل عبر Timeline خطوة بخطوة (SHIPPING-5).
class UpdateDeliveryScreen extends StatefulWidget {
  final DeliveryRequest delivery;
  const UpdateDeliveryScreen({super.key, required this.delivery});

  @override
  State<UpdateDeliveryScreen> createState() => _UpdateDeliveryScreenState();
}

class _UpdateDeliveryScreenState extends State<UpdateDeliveryScreen> {
  String _selectedProblem = 'لا مشكلة';
  final _problemDetailsController = TextEditingController();

  static const _problems = ['لا مشكلة', 'المشتري غير متاح', 'العنوان خاطئ', 'أخرى'];

  bool get _pickedUp => widget.delivery.status != DeliveryStatus.waitingPickup;
  bool get _delivered => widget.delivery.status == DeliveryStatus.delivered;

  void _confirmPickup() {
    setState(() => widget.delivery.status = DeliveryStatus.inTransit);
  }

  void _confirmDelivery() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تأكيد التسليم والمبلغ المحصّل', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('المبلغ المطلوب تحصيله: ${widget.delivery.fee} د.ع', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                setState(() => widget.delivery.status = DeliveryStatus.delivered);
                Navigator.pop(context);
                Navigator.pop(context);
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.delivery.orderNumber, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildStep('تم قبول الطلب', true),
              _buildStep('استلمت من البائع', _pickedUp),
              _buildStep('في الطريق للمشتري', _pickedUp),
              _buildStep('تم التسليم', _delivered, isLast: true),
              const SizedBox(height: 16),
              if (!_pickedUp)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: _confirmPickup,
                    child: const Text('تأكيد الاستلام من البائع', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  ),
                )
              else if (!_delivered)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: _confirmDelivery,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إرسال', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
