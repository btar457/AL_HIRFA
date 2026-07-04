import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class _CompletedDelivery {
  final String orderNumber;
  final String productName;
  final String province;
  final String date;
  final int fee;
  const _CompletedDelivery({required this.orderNumber, required this.productName, required this.province, required this.date, required this.fee});
}

/// سجل التوصيلات المكتملة لشركة الشحن (SHIPPING-6).
class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});
  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  static const _deliveries = [
    _CompletedDelivery(orderNumber: '#HRF-9690', productName: 'مرآة نحاسية منقوشة', province: 'كربلاء', date: '١٥ يونيو ٢٠٢٦', fee: 4500),
    _CompletedDelivery(orderNumber: '#HRF-9611', productName: 'صينية نحاسية كبيرة', province: 'الموصل', date: '٢ يونيو ٢٠٢٦', fee: 4500),
    _CompletedDelivery(orderNumber: '#HRF-9502', productName: 'سجادة حرير نجفية', province: 'النجف', date: '٢٠ مايو ٢٠٢٦', fee: 4500),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalFee = _deliveries.fold<int>(0, (sum, d) => sum + d.fee);
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
        body: Column(
          children: [
            _buildStatsRow(totalFee),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_deliveries),
                  _buildList(_deliveries),
                  _buildList(_deliveries),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(int totalFee) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('إجمالي التوصيلات', '${_deliveries.length}')),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('هذا الشهر', '${_deliveries.length}')),
          const SizedBox(width: 10),
          Expanded(child: _buildStatCard('التقييم', '⭐ 4.9')),
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

  Widget _buildList(List<_CompletedDelivery> deliveries) {
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
                    Row(children: [Text(d.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Text(d.date, style: TextStyle(color: AppColors.subText, fontSize: 11))]),
                    const SizedBox(height: 4),
                    Text(d.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(d.province, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${d.fee} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
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
