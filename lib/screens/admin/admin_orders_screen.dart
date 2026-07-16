import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/dispute_model.dart';
import '../../models/order_model.dart';
import '../../services/admin_service.dart';
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

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

const _inProgressStatuses = {'pending', 'seller_approved', 'shipping_assigned', 'picked_up'};

/// إدارة الطلبات على مستوى المنصة (ADMIN-6).
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filter = 'الكل';

  List<OrderModel> _filtered(List<OrderModel> orders) {
    return switch (_filter) {
      'قيد التنفيذ' => orders.where((o) => _inProgressStatuses.contains(o.status)).toList(),
      'مكتملة' => orders.where((o) => o.status == 'delivered').toList(),
      'ملغاة' => orders.where((o) => o.status == 'cancelled').toList(),
      'مشكلات' => orders.where((o) => o.status == 'disputed').toList(),
      _ => orders,
    };
  }

  void _showContactDialog(String title, String name, String? phone) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(phone?.isNotEmpty == true ? phone! : 'لا يوجد رقم هاتف مسجّل', style: TextStyle(color: AppColors.subText)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق', style: TextStyle(color: AppColors.gold))),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(OrderModel order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('إلغاء الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(hintText: 'سبب الإلغاء', hintStyle: TextStyle(color: AppColors.subText), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تراجع', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                await OrderService.instance.adminCancelOrder(order.id, reason);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('تأكيد الإلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResolve(OrderModel order) {
    final resolutionController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('إنهاء البلاغ', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: resolutionController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(hintText: 'وصف الحل النهائي', hintStyle: TextStyle(color: AppColors.subText), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تراجع', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final resolution = resolutionController.text.trim();
                if (resolution.isEmpty) return;
                await DisputeService.instance.resolveDispute(order.disputeId!, resolution);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('تأكيد الحل', style: TextStyle(fontWeight: FontWeight.bold)),
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
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('إدارة الطلبات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: 5,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final labels = ['الكل', 'قيد التنفيذ', 'مكتملة', 'ملغاة', 'مشكلات'];
                  final label = labels[i];
                  final selected = _filter == label;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: selected ? AppColors.gold : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withOpacity(selected ? 1 : 0.4))),
                      child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.black : AppColors.text, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('تعذّر تحميل الطلبات', style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  final orders = _filtered(snapshot.data!);
                  if (orders.isEmpty) return Center(child: Text('لا توجد طلبات', style: TextStyle(color: AppColors.subText)));
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, i) => _buildOrderCard(orders[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
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
              _buildStatusChip(order.status),
            ],
          ),
          Text(_formatDate(order.createdAt), style: TextStyle(color: AppColors.subText, fontSize: 11)),
          const Divider(color: Color(0xFF2A2A2A)),
          Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
          Text('د.ع ${_formatPrice(order.totalAmount)}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          Text('المشتري: ${order.buyerName}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('البائع: ${order.artisanName}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('شركة الشحن: ${order.shippingCompanyName ?? '—'}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          if (order.status == 'disputed') ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.disputeId != null)
                    StreamBuilder<DisputeModel?>(
                      stream: DisputeService.instance.watchDispute(order.disputeId!),
                      builder: (context, disputeSnapshot) {
                        final dispute = disputeSnapshot.data;
                        return Text(dispute?.description ?? 'جاري تحميل تفاصيل البلاغ...', style: TextStyle(color: AppColors.text, fontSize: 12));
                      },
                    ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => _showContactDialog('بيانات المشتري', order.buyerName, order.buyerPhone),
                        child: const Text('تواصل مع المشتري', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      if (order.shippingUid != null)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () async {
                            final shippingUser = await AdminService.instance.getUserById(order.shippingUid!);
                            if (!mounted) return;
                            _showContactDialog('بيانات شركة الشحن', shippingUser?.name ?? order.shippingCompanyName ?? '', shippingUser?.phone);
                          },
                          child: const Text('تواصل مع الشركة', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => _confirmCancel(order),
                        child: const Text('إلغاء الطلب', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      if (order.disputeId != null)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () => _confirmResolve(order),
                          child: const Text('إنهاء البلاغ دون إلغاء', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    late final Color color;
    late final String label;
    if (_inProgressStatuses.contains(status)) {
      color = AppColors.gold;
      label = 'قيد التنفيذ';
    } else if (status == 'delivered') {
      color = Colors.green;
      label = 'مكتملة';
    } else if (status == 'cancelled') {
      color = Colors.grey;
      label = 'ملغاة';
    } else if (status == 'disputed') {
      color = Colors.redAccent;
      label = 'مشكلة';
    } else {
      color = AppColors.subText;
      label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
