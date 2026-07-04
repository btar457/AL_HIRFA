import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class _SettlementEntry {
  final String name;
  final int count;
  final int amount;
  final bool settled;
  const _SettlementEntry({required this.name, required this.count, required this.amount, required this.settled});
}

/// التسويات المالية الأسبوعية (ADMIN-7).
class AdminFinancialsScreen extends StatefulWidget {
  const AdminFinancialsScreen({super.key});
  @override
  State<AdminFinancialsScreen> createState() => _AdminFinancialsScreenState();
}

class _AdminFinancialsScreenState extends State<AdminFinancialsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  static const _shippingSettlements = [
    _SettlementEntry(name: 'شركة بغداد السريعة للشحن', count: 50, amount: 22500, settled: true),
    _SettlementEntry(name: 'شركة الفرات للتوصيل', count: 20, amount: 9600, settled: false),
  ];
  static const _artisanSettlements = [
    _SettlementEntry(name: 'أبو مصطفى', count: 12, amount: 45000, settled: true),
    _SettlementEntry(name: 'زينب كريم', count: 5, amount: 18000, settled: true),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('التسويات المالية', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF8B6B1F), AppColors.gold])),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إجمالي الإيرادات هذا الشهر', style: TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 6),
                    const Text('٤,٧٥٠,٠٠٠ د.ع', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _miniStat('عمولة المنتجات (10%)', '٣,٢٠٠,٠٠٠')),
                      Expanded(child: _miniStat('عمولة الشحن (10%)', '١,٥٥٠,٠٠٠')),
                    ]),
                  ],
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.gold,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.subText,
              tabs: const [Tab(text: 'شركات الشحن'), Tab(text: 'الحرفيون')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_shippingSettlements),
                  _buildList(_artisanSettlements),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ],
    );
  }

  Widget _buildList(List<_SettlementEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('${e.count} عملية هذا الأسبوع', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${e.amount} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(e.settled ? 'مدفوعة ✓' : 'متأخرة ⚠️', style: TextStyle(color: e.settled ? Colors.green : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                  if (!e.settled) ...[
                    const SizedBox(height: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      onPressed: () {},
                      child: const Text('تأكيد الاستلام', style: TextStyle(color: AppColors.gold, fontSize: 11)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
