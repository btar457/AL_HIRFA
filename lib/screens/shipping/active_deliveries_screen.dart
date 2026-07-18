import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import 'update_delivery_screen.dart';

const _activeStatuses = {'shipping_assigned', 'picked_up'};

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

/// توصيلات شركة الشحن النشطة حالياً (SHIPPING-4).
class ActiveDeliveriesScreen extends StatefulWidget {
  const ActiveDeliveriesScreen({super.key});
  @override
  State<ActiveDeliveriesScreen> createState() => _ActiveDeliveriesScreenState();
}

class _ActiveDeliveriesScreenState extends State<ActiveDeliveriesScreen> {
  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _markPickedUp(OrderModel order) async {
    try {
      await OrderService.instance.shippingPickedUp(order.id);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    }
  }

  void _confirmDelivered(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تأكيد التسليم', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('تأكد أنك حصّلت ${_formatPrice(order.totalAmount)} د.ع كاشاً من المشتري قبل التأكيد.', style: TextStyle(color: AppColors.subText)),
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
                try {
                  await OrderService.instance.confirmDelivery(order.id);
                } catch (e) {
                  if (!mounted) return;
                  AppError.showSnackbar(context, AppError.getFirebaseError(e));
                }
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
    final shippingUid = context.watch<AuthProvider>().currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('توصيلاتي النشطة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: shippingUid == null
            ? Center(child: Text('سجّل الدخول لعرض توصيلاتك', style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.getShippingOrders(shippingUid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('تعذّر تحميل التوصيلات', style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  final active = snapshot.data!.where((o) => _activeStatuses.contains(o.status)).toList();
                  if (active.isEmpty) {
                    return Center(child: Text('لا توجد توصيلات نشطة حالياً', style: TextStyle(color: AppColors.subText)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: active.length,
                    itemBuilder: (context, i) => _buildCard(active[i]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCard(OrderModel order) {
    final isWaitingPickup = order.status == 'shipping_assigned';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateDeliveryScreen(orderId: order.id))),
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
                Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
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
                ProductThumbnail(imageUrl: order.productImage, size: 70, iconSize: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.subText, size: 13), const SizedBox(width: 4), Expanded(child: Text('التسليم إلى: ${order.governorate} - ${order.district}', style: TextStyle(color: AppColors.subText, fontSize: 11)))]),
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
                    onPressed: () => _call(order.buyerPhone),
                    icon: const Icon(Icons.call, color: AppColors.gold, size: 15),
                    label: const Text('اتصال بالمشتري', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('أجرك: ${_formatPrice(order.shippingEarnings)} د.ع — تُجمعه كاشاً عند التسليم', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
            Text('مستحق لـ AL-HIRFA: ${_formatPrice(order.deliveryFee - order.shippingEarnings)} د.ع', style: TextStyle(color: AppColors.subText, fontSize: 11)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: isWaitingPickup
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _markPickedUp(order),
                      child: const Text('استلمت من البائع', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _confirmDelivered(order),
                      child: const Text('تم التسليم للمشتري', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
