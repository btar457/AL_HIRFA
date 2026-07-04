import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import 'order_review_screen.dart';
import 'order_tracking_screen.dart';

enum _OrderStatus { active, completed, cancelled }

class _OrderEntry {
  final String orderNumber;
  final MarketplaceProduct product;
  final String date;
  final _OrderStatus status;
  const _OrderEntry({required this.orderNumber, required this.product, required this.date, required this.status});
}

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});
  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  final _orders = const [
    _OrderEntry(
      orderNumber: '#HRF-9821',
      product: MarketplaceProduct(name: 'سجادة حرير نجفية مطرزة يدوياً', price: '450,000', city: 'نجف', cityTag: 'NAJAF SILK'),
      date: '٢ يوليو ٢٠٢٦',
      status: _OrderStatus.active,
    ),
    _OrderEntry(
      orderNumber: '#HRF-9756',
      product: MarketplaceProduct(name: 'إبريق نحاسي بصري منقوش', price: '210,000', city: 'بصرة', cityTag: 'BASRA COPPER'),
      date: '٢٤ يونيو ٢٠٢٦',
      status: _OrderStatus.completed,
    ),
    _OrderEntry(
      orderNumber: '#HRF-9612',
      product: MarketplaceProduct(name: 'منحوتة حجرية موصلية', price: '295,000', city: 'موصل', cityTag: 'MOSUL STONE'),
      date: '١٠ يونيو ٢٠٢٦',
      status: _OrderStatus.cancelled,
    ),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_OrderEntry> _ordersFor(_OrderStatus? status) {
    if (status == null) return _orders;
    return _orders.where((o) => o.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('طلباتي', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'قيد التنفيذ'),
              Tab(text: 'مكتملة'),
              Tab(text: 'ملغاة'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOrdersList(_ordersFor(null)),
            _buildOrdersList(_ordersFor(_OrderStatus.active)),
            _buildOrdersList(_ordersFor(_OrderStatus.completed)),
            _buildOrdersList(_ordersFor(_OrderStatus.cancelled)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<_OrderEntry> orders) {
    if (orders.isEmpty) {
      return Center(child: Text('لا توجد طلبات', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildOrderCard(orders[i]),
    );
  }

  Widget _buildOrderCard(_OrderEntry order) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                    const SizedBox(height: 6),
                    Text(order.product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('د.ع ${order.product.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(order.date, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          if (order.status == _OrderStatus.active || order.status == _OrderStatus.completed) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: order.status == _OrderStatus.active
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(product: order.product, orderNumber: order.orderNumber))),
                      child: const Text('تتبع الطلب', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  : OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderReviewScreen(product: order.product))),
                      child: const Text('تقييم', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(_OrderStatus status) {
    late final Color bg;
    late final Color fg;
    late final String label;
    switch (status) {
      case _OrderStatus.active:
        bg = AppColors.gold;
        fg = Colors.black;
        label = 'نشط';
        break;
      case _OrderStatus.completed:
        bg = Colors.green.withOpacity(0.2);
        fg = Colors.green;
        label = 'مكتمل';
        break;
      case _OrderStatus.cancelled:
        bg = Colors.red.withOpacity(0.2);
        fg = Colors.red;
        label = 'ملغي';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
