import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../services/admin_service.dart';

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

const _statusLabels = {'shipping_assigned': 'مُعيَّن لشركة شحن', 'picked_up': 'استُلم من الحرفي'};

/// طلبات عالقة بحالات شحن قديمة (shipping_assigned/picked_up) من قبل إغلاق
/// قسم الشحن مؤقتاً — لا مسار واجهة عادي يصل إليها الآن (راجع
/// AdminService.getStuckLegacyShippingOrders/unstuckLegacyShippingOrder).
class AdminStuckOrdersScreen extends StatelessWidget {
  const AdminStuckOrdersScreen({super.key});

  Future<void> _confirmUnstuck(BuildContext context, OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('إعادة الطلب للحرفي؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(
            'سيعود طلب ${order.orderNumber} إلى الحرفي (${order.artisanName}) ليتولّى توصيله بنفسه ويؤكّد التسليم مباشرة من تطبيقه.',
            style: TextStyle(color: AppColors.subText),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      await AdminService.instance.unstuckLegacyShippingOrder(order.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('طلبات عالقة (شحن قديم)', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: AdminService.instance.getStuckLegacyShippingOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('تعذّر تحميل الطلبات', style: TextStyle(color: AppColors.subText)));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            final orders = snapshot.data!;
            if (orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'لا توجد طلبات عالقة — كل الطلبات في مسارها الطبيعي.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.subText),
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final order = orders[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.4))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(_statusLabels[order.status] ?? order.status, style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('الحرفي: ${order.artisanName}', style: const TextStyle(color: AppColors.text, fontSize: 13)),
                      Text('الزبون: ${order.buyerName}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                      if (order.shippingCompanyName != null) Text('شركة الشحن: ${order.shippingCompanyName}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                      Text('تاريخ الطلب: ${_formatDate(order.createdAt)}', style: TextStyle(color: AppColors.subText, fontSize: 11)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () => _confirmUnstuck(context, order),
                          child: const Text('إعادة الطلب للحرفي للتوصيل الذاتي', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
