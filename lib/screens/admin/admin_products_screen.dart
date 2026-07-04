import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class _AdminProduct {
  final String name;
  final String price;
  final String artisanName;
  final String status; // pending, active, suspended, rejected
  const _AdminProduct({required this.name, required this.price, required this.artisanName, required this.status});
}

/// إدارة المنتجات على مستوى المنصة (ADMIN-10).
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});
  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  static const _products = [
    _AdminProduct(name: 'إناء نحاسي منقوش', price: '125,000', artisanName: 'أبو مصطفى', status: 'pending'),
    _AdminProduct(name: 'طبق نحاسي مزخرف', price: '90,000', artisanName: 'أبو مصطفى', status: 'active'),
    _AdminProduct(name: 'مزهرية طينية بابلية', price: '175,000', artisanName: 'زينب كريم', status: 'suspended'),
    _AdminProduct(name: 'شمعدان نحاسي قديم', price: '65,000', artisanName: 'كريم عبد الرزاق', status: 'rejected'),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_AdminProduct> _for(String status) => _products.where((p) => p.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('إدارة المنتجات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'قيد المراجعة'), Tab(text: 'منشورة'), Tab(text: 'موقوفة'), Tab(text: 'مرفوضة')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList(_for('pending'), pending: true),
            _buildList(_for('active'), pending: false),
            _buildList(_for('suspended'), pending: false),
            _buildList(_for('rejected'), pending: false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_AdminProduct> products, {required bool pending}) {
    if (products.isEmpty) return Center(child: Text('لا توجد منتجات', style: TextStyle(color: AppColors.subText)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, i) => _buildCard(products[i], pending: pending),
    );
  }

  Widget _buildCard(_AdminProduct product, {required bool pending}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('د.ع ${product.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(product.artisanName, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (pending)
            Row(
              children: [
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('معاينة', style: TextStyle(color: AppColors.gold, fontSize: 12)))),
                const SizedBox(width: 6),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('موافقة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
                const SizedBox(width: 6),
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('رفض', style: TextStyle(color: Colors.redAccent, fontSize: 12)))),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('إيقاف', style: TextStyle(color: Colors.orange, fontSize: 12)))),
              ],
            ),
        ],
      ),
    );
  }
}
