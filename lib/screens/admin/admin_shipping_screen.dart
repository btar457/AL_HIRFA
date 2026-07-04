import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum _ShippingCompanyStatus { pending, active, suspended }

class _ShippingCompany {
  final String name;
  final String provinces;
  final String registrationNumber;
  final int deposit;
  final int monthlyDeliveries;
  final double rating;
  final int owedToPlatform;
  final bool settled;
  final _ShippingCompanyStatus status;
  const _ShippingCompany({required this.name, required this.provinces, required this.registrationNumber, required this.deposit, this.monthlyDeliveries = 0, this.rating = 0, this.owedToPlatform = 0, this.settled = true, required this.status});
}

/// إدارة شركات الشحن (ADMIN-5).
class AdminShippingScreen extends StatefulWidget {
  const AdminShippingScreen({super.key});
  @override
  State<AdminShippingScreen> createState() => _AdminShippingScreenState();
}

class _AdminShippingScreenState extends State<AdminShippingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  static const _companies = [
    _ShippingCompany(name: 'شركة الشحن الجديدة', provinces: 'بغداد', registrationNumber: '2026-1122', deposit: 500000, status: _ShippingCompanyStatus.pending),
    _ShippingCompany(name: 'شركة بغداد السريعة للشحن', provinces: 'بغداد، النجف، كربلاء', registrationNumber: '2024-8871', deposit: 500000, monthlyDeliveries: 312, rating: 4.9, owedToPlatform: 22500, settled: true, status: _ShippingCompanyStatus.active),
    _ShippingCompany(name: 'شركة الفرات للتوصيل', provinces: 'البصرة، ذي قار', registrationNumber: '2023-5541', deposit: 500000, monthlyDeliveries: 96, rating: 4.2, owedToPlatform: 9600, settled: false, status: _ShippingCompanyStatus.suspended),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_ShippingCompany> _for(_ShippingCompanyStatus status) => _companies.where((c) => c.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('إدارة شركات الشحن', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'قيد المراجعة'), Tab(text: 'نشطة'), Tab(text: 'معلقة')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_for(_ShippingCompanyStatus.pending)),
            _buildList(_for(_ShippingCompanyStatus.active)),
            _buildList(_for(_ShippingCompanyStatus.suspended)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_ShippingCompany> companies) {
    if (companies.isEmpty) return Center(child: Text('لا توجد شركات', style: TextStyle(color: AppColors.subText)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: companies.length,
      itemBuilder: (context, i) => _buildCard(companies[i]),
    );
  }

  Widget _buildCard(_ShippingCompany company) {
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
              Expanded(child: Text(company.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14))),
              _buildStatusChip(company.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(company.provinces, style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('سجل تجاري: ${company.registrationNumber}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('مبلغ التأمين: ${company.deposit} د.ع', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          if (company.status == _ShippingCompanyStatus.active) ...[
            const SizedBox(height: 8),
            Divider(color: AppColors.subText.withOpacity(0.15)),
            Text('التوصيلات هذا الشهر: ${company.monthlyDeliveries} — التقييم: ⭐ ${company.rating}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Text('المستحق لـ AL-HIRFA: ${company.owedToPlatform} د.ع — ', style: TextStyle(color: AppColors.subText, fontSize: 12)),
              Text(company.settled ? 'مدفوعة ✓' : 'متأخرة ⚠️', style: TextStyle(color: company.settled ? Colors.green : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (company.status == _ShippingCompanyStatus.pending) ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () {},
                    child: const Text('موافقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () {},
                    child: const Text('رفض', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () {},
                    child: const Text('تعليق', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(_ShippingCompanyStatus status) {
    late final Color color;
    late final String label;
    switch (status) {
      case _ShippingCompanyStatus.pending:
        color = AppColors.gold;
        label = 'قيد المراجعة';
        break;
      case _ShippingCompanyStatus.active:
        color = Colors.green;
        label = 'نشطة';
        break;
      case _ShippingCompanyStatus.suspended:
        color = Colors.orange;
        label = 'معلقة';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
