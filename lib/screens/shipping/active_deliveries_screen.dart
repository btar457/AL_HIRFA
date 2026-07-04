import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../models/delivery_request.dart';
import 'update_delivery_screen.dart';

/// توصيلات شركة الشحن النشطة حالياً (SHIPPING-4).
class ActiveDeliveriesScreen extends StatefulWidget {
  const ActiveDeliveriesScreen({super.key});
  @override
  State<ActiveDeliveriesScreen> createState() => _ActiveDeliveriesScreenState();
}

class _ActiveDeliveriesScreenState extends State<ActiveDeliveriesScreen> {
  final List<DeliveryRequest> _deliveries = [
    DeliveryRequest(orderNumber: '#HRF-9788', productName: 'إبريق نحاسي بصري', category: 'نحاسيات', fromProvince: 'بغداد - الكرادة', toProvince: 'النجف - حي السلام', buyerAddress: 'النجف - حي السلام - قرب جامع الإمام', sellerPhone: '07701112222', buyerPhone: '07715558888', distance: '١٦٠ كم', fee: 4500, status: DeliveryStatus.waitingPickup),
    DeliveryRequest(orderNumber: '#HRF-9750', productName: 'شمعدان نحاسي قديم', category: 'نحاسيات', fromProvince: 'أربيل - عنكاوا', toProvince: 'أربيل - المركز', buyerAddress: 'أربيل - المركز - شارع 60م', sellerPhone: '07733334444', buyerPhone: '07733335555', distance: '١٢ كم', fee: 4500, status: DeliveryStatus.inTransit),
  ];

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _markPickedUp(DeliveryRequest delivery) {
    setState(() => delivery.status = DeliveryStatus.inTransit);
  }

  void _confirmDelivered(DeliveryRequest delivery) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تأكيد التسليم', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('تأكد أنك حصّلت ${delivery.fee} د.ع كاشاً من المشتري قبل التأكيد.', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                setState(() => delivery.status = DeliveryStatus.delivered);
                Navigator.pop(context);
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
    final active = _deliveries.where((d) => d.status != DeliveryStatus.delivered).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('توصيلاتي النشطة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: active.isEmpty
            ? Center(child: Text('لا توجد توصيلات نشطة حالياً', style: TextStyle(color: AppColors.subText)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: active.length,
                itemBuilder: (context, i) => _buildCard(active[i]),
              ),
      ),
    );
  }

  Widget _buildCard(DeliveryRequest delivery) {
    final isWaitingPickup = delivery.status == DeliveryStatus.waitingPickup;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateDeliveryScreen(delivery: delivery))).then((_) => setState(() {})),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(delivery.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(isWaitingPickup ? 'بانتظار الاستلام' : 'في الطريق', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2A2A2A)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)])),
                child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(delivery.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.subText, size: 13), const SizedBox(width: 4), Expanded(child: Text('استلام: ${delivery.fromProvince}', style: TextStyle(color: AppColors.subText, fontSize: 11)))]),
                    const SizedBox(height: 2),
                    Row(children: [const Icon(Icons.flag_outlined, color: AppColors.subText, size: 13), const SizedBox(width: 4), Expanded(child: Text('تسليم: ${delivery.buyerAddress}', style: TextStyle(color: AppColors.subText, fontSize: 11)))]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _call(delivery.sellerPhone),
                  icon: const Icon(Icons.call, color: AppColors.gold, size: 15),
                  label: const Text('اتصال بالبائع', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _call(delivery.buyerPhone),
                  icon: const Icon(Icons.call, color: AppColors.gold, size: 15),
                  label: const Text('اتصال بالمشتري', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('أجرك: ${delivery.fee} د.ع — تُجمعه كاشاً عند التسليم', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
          Text('مستحق لـ AL-HIRFA: ${(delivery.fee * 0.10 / 0.9).round()} د.ع', style: TextStyle(color: AppColors.subText, fontSize: 11)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: isWaitingPickup
                ? OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => _markPickedUp(delivery),
                    child: const Text('استلمت من البائع', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => _confirmDelivered(delivery),
                    child: const Text('تم التسليم للمشتري', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
          ),
        ],
      ),
      ),
    );
  }
}
