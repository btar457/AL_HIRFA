import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
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

/// سجل التوصيلات المكتملة لشركة الشحن (SHIPPING-6).
class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});
  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime _completionDate(OrderModel order) => order.deliveredAt ?? order.createdAt;

  List<OrderModel> _thisMonth(List<OrderModel> delivered) {
    final now = DateTime.now();
    return delivered.where((o) => _completionDate(o).year == now.year && _completionDate(o).month == now.month).toList();
  }

  List<OrderModel> _last3Months(List<OrderModel> delivered) {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return delivered.where((o) => _completionDate(o).isAfter(cutoff)).toList();
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
          title: const Text('سجل التوصيلات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'هذا الشهر'), Tab(text: 'آخر 3 أشهر'), Tab(text: 'الكل')],
          ),
        ),
        body: shippingUid == null
            ? Center(child: Text('سجّل الدخول لعرض السجل', style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.getShippingOrders(shippingUid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('تعذّر تحميل السجل', style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const ListRowShimmer();
                  }
                  final delivered = snapshot.data!.where((o) => o.status == 'delivered').toList()
                    ..sort((a, b) => _completionDate(b).compareTo(_completionDate(a)));
                  final thisMonth = _thisMonth(delivered);
                  final last3Months = _last3Months(delivered);

                  return Column(
                    children: [
                      _buildStatsRow(delivered, thisMonth),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(thisMonth),
                            _buildList(last3Months),
                            _buildList(delivered),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatsRow(List<OrderModel> all, List<OrderModel> thisMonth) {
    final totalEarnings = all.fold<int>(0, (sum, o) => sum + o.shippingEarnings);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('إجمالي التوصيلات', '${all.length}')),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('هذا الشهر', '${thisMonth.length}')),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('إجمالي الأرباح', _formatPrice(totalEarnings))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppColors.subText, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildList(List<OrderModel> deliveries) {
    if (deliveries.isEmpty) {
      return Center(child: Text('لا توجد توصيلات', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: deliveries.length,
      itemBuilder: (context, i) {
        final d = deliveries[i];
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
                    Row(children: [Text(d.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text(_formatDate(_completionDate(d)), style: TextStyle(color: AppColors.subText, fontSize: 11))]),
                    const SizedBox(height: 4),
                    Text(d.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(d.governorate, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_formatPrice(d.shippingEarnings)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('مكتمل', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
