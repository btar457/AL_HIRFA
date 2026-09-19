import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../services/admin_service.dart';
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

class _ArtisanDue {
  final String artisanUid;
  final String artisanName;
  int confirmedOwed = 0; // طلبات delivered لم تُدفَع عمولتها بعد
  int pendingOwed = 0; // طلبات لم تُسلَّم بعد — تقديري، غير مؤكَّد
  final List<String> confirmedOrderIds = [];

  _ArtisanDue({required this.artisanUid, required this.artisanName});
}

/// لوحة عمولات الحرفيين المستحقة للمنصة (5% من سعر كل منتج) — قسم الشحن
/// مغلق مؤقتاً، فالحرفي يقبض كامل مبلغ الطلب كاشاً من الزبون مباشرة ويدين
/// للمنصة بعمولتها، بدل النموذج السابق حيث كانت المنصة تدين للحرفي.
/// العمولة "معلّقة" فور الشراء، وتصبح "مستحقة مؤكَّدة" فقط بعد التسليم —
/// نفس الاستنتاج من حالة الطلب مباشرة بلا حقل منفصل (راجع checkout_screen.dart).
class AdminCommissionsOwedScreen extends StatelessWidget {
  const AdminCommissionsOwedScreen({super.key});

  Map<String, _ArtisanDue> _groupByArtisan(List<OrderModel> orders) {
    final byArtisan = <String, _ArtisanDue>{};
    for (final order in orders) {
      if (order.status == 'cancelled' || order.status == 'disputed') continue;
      final due = byArtisan.putIfAbsent(order.artisanUid, () => _ArtisanDue(artisanUid: order.artisanUid, artisanName: order.artisanName));
      if (order.status == 'delivered') {
        if (!order.commissionPaid) {
          due.confirmedOwed += order.platformFee;
          due.confirmedOrderIds.add(order.id);
        }
      } else {
        due.pendingOwed += order.platformFee;
      }
    }
    final result = byArtisan.values.where((d) => d.confirmedOwed > 0 || d.pendingOwed > 0).toList()
      ..sort((a, b) => b.confirmedOwed.compareTo(a.confirmedOwed));
    return {for (final d in result) d.artisanUid: d};
  }

  Future<void> _collect(BuildContext context, _ArtisanDue due) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تأكيد التحصيل؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(
            'أكِّد فقط بعد استلام ${_formatPrice(due.confirmedOwed)} د.ع فعلياً من ${due.artisanName} (تحويل بنكي أو نقداً خارج التطبيق).',
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
              child: const Text('تم التحصيل', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true) {
      await OrderService.instance.markArtisanCommissionPaid(due.artisanUid, due.confirmedOrderIds);
    }
  }

  /// تشغيل فحص الالتزام بالسداد يدوياً (بالإضافة للتشغيل الصامت التلقائي عند
  /// فتح لوحة تحكم الأدمن) — مفيد لو لم يفتح أي أدمن الصفحة الرئيسية منذ فترة.
  Future<void> _runComplianceCheck(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
    try {
      await AdminService.instance.checkCommissionCompliance();
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فحص الالتزام بالسداد لكل الحرفيين')));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذّر إتمام الفحص: $e')));
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
          automaticallyImplyLeading: false,
          title: const Text('عمولات الحرفيين', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.fact_check_outlined, color: AppColors.gold),
              tooltip: 'فحص الالتزام بالسداد (تنبيه/حظر)',
              onPressed: () => _runComplianceCheck(context),
            ),
          ],
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: OrderService.instance.getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('تعذّر تحميل العمولات', style: TextStyle(color: AppColors.subText)));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            final dues = _groupByArtisan(snapshot.data!).values.toList();
            if (dues.isEmpty) {
              return Center(child: Text('لا توجد عمولات مستحقة حالياً', style: TextStyle(color: AppColors.subText)));
            }
            final totalConfirmed = dues.fold<int>(0, (sum, d) => sum + d.confirmedOwed);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.4))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إجمالي العمولات المستحقة المؤكَّدة (طلبات مُسلَّمة لم تُحصَّل)', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('${_formatPrice(totalConfirmed)} د.ع', style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...dues.map((due) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(due.artisanName.isEmpty ? 'حرفي غير معروف' : due.artisanName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('مستحق مؤكَّد (تسليم فعلي)', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                          Text('${_formatPrice(due.confirmedOwed)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('معلّق (بانتظار التسليم)', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                          Text('${_formatPrice(due.pendingOwed)} د.ع', style: TextStyle(color: AppColors.subText, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (due.confirmedOwed > 0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () => _collect(context, due),
                            child: const Text('تم تحصيل المبلغ من الحرفي', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
              ],
            );
          },
        ),
      ),
    );
  }
}
