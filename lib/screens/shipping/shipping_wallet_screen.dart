import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_rules.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../models/settlement_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/wallet_service.dart';
import '../../widgets/common/loading_shimmer.dart';

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

/// محفظة شركة الشحن (SHIPPING-7).
class ShippingWalletScreen extends StatelessWidget {
  const ShippingWalletScreen({super.key});

  DateTime _completionDate(OrderModel order) => order.deliveredAt ?? order.createdAt;

  void _showSettlementDialog(BuildContext context, String shippingUid) async {
    showDialog(
      context: context,
      builder: (dialogContext) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
    );
    try {
      final settlement = await WalletService.instance.previewCurrentWeekSettlement(shippingUid);
      if (!context.mounted) return;
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('تفاصيل التسوية', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('عدد التوصيلات', '${settlement.deliveriesCount}', AppColors.text),
                const SizedBox(height: 8),
                _row('أرباح الشركة', '${_formatPrice(settlement.totalEarnings)} د.ع', Colors.green),
                const SizedBox(height: 8),
                _row('المستحق لـ AL-HIRFA', '${_formatPrice(settlement.platformDue)} د.ع', Colors.redAccent),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق', style: TextStyle(color: AppColors.gold))),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
    }
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
          title: const Text('محفظة الشركة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: shippingUid == null
            ? Center(child: Text('سجّل الدخول لعرض المحفظة', style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.getShippingOrders(shippingUid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListRowShimmer();
                  }
                  final delivered = snapshot.data!.where((o) => o.status == 'delivered').toList()
                    ..sort((a, b) => _completionDate(b).compareTo(_completionDate(a)));
                  final now = DateTime.now();
                  final thisMonthEarnings = delivered
                      .where((o) => _completionDate(o).year == now.year && _completionDate(o).month == now.month)
                      .fold<int>(0, (acc, o) => acc + o.shippingEarnings);

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildBalanceCard(thisMonthEarnings),
                      const SizedBox(height: 16),
                      FutureBuilder<int>(
                        future: WalletService.instance.getUsedDeposit(shippingUid),
                        builder: (context, depositSnapshot) => _buildInsuranceCard(depositSnapshot.data ?? 0),
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<SettlementModel>(
                        future: WalletService.instance.previewCurrentWeekSettlement(shippingUid),
                        builder: (context, settlementSnapshot) => _buildSettlementCard(context, shippingUid, settlementSnapshot.data),
                      ),
                      const SizedBox(height: 20),
                      const Text('سجل المعاملات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 10),
                      if (delivered.isEmpty)
                        Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('لا توجد معاملات بعد', style: TextStyle(color: AppColors.subText))))
                      else
                        ...delivered.map(_buildTransactionTile),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBalanceCard(int thisMonthEarnings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF8B6B1F), AppColors.gold], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إجمالي الأرباح هذا الشهر', style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          Text('${_formatPrice(thisMonthEarnings)} د.ع', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard(int used) {
    final remaining = AppRules.securityDeposit - used;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('مبلغ التأمين المودع', '${_formatPrice(AppRules.securityDeposit)} د.ع', AppColors.gold),
          const SizedBox(height: 6),
          _row('المستخدم', '${_formatPrice(used)} د.ع', AppColors.text),
          const SizedBox(height: 6),
          _row('المتبقي', '${_formatPrice(remaining)} د.ع', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSettlementCard(BuildContext context, String shippingUid, SettlementModel? settlement) {
    final due = settlement?.platformDue ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('المستحق لـ AL-HIRFA هذا الأسبوع', '${_formatPrice(due)} د.ع', Colors.redAccent),
          const SizedBox(height: 6),
          Text('موعد التسوية: نهاية الأسبوع الحالي', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => _showSettlementDialog(context, shippingUid),
              child: const Text('تفاصيل التسوية', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildTransactionTile(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_formatDate(_completionDate(order)), style: TextStyle(color: AppColors.subText, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${_formatPrice(order.shippingEarnings)} د.ع', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('-${_formatPrice(order.deliveryFee - order.shippingEarnings)} د.ع عمولة', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
