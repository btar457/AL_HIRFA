import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import 'order_review_screen.dart';
import 'order_tracking_screen.dart';

const _activeStatuses = {'pending', 'seller_approved', 'shipping_assigned', 'picked_up'};
const _cancelledStatuses = {'cancelled', 'disputed'};

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

MarketplaceProduct _toMarketplaceProduct(OrderModel order) {
  return MarketplaceProduct(name: order.productName, price: _formatPrice(order.price), city: order.governorate, cityTag: order.governorate.toUpperCase());
}

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});
  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _ordersFor(List<OrderModel> orders, Set<String>? statuses) {
    if (statuses == null) return orders;
    return orders.where((o) => statuses.contains(o.status)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final buyerUid = context.watch<AuthProvider>().currentUser?.uid;

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
        body: buyerUid == null
            ? Center(child: Text('سجّل الدخول لعرض طلباتك', style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.getBuyerOrders(buyerUid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('تعذّر تحميل الطلبات', style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  final orders = snapshot.data!;
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(_ordersFor(orders, null)),
                      _buildOrdersList(_ordersFor(orders, _activeStatuses)),
                      _buildOrdersList(_ordersFor(orders, {'delivered'})),
                      _buildOrdersList(_ordersFor(orders, _cancelledStatuses)),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(child: Text('لا توجد طلبات', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildOrderCard(orders[i]),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isActive = _activeStatuses.contains(order.status);
    final isCompleted = order.status == 'delivered';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id))),
      child: Container(
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
                      Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('د.ع ${_formatPrice(order.price)}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (isActive || (isCompleted && !order.isReviewed)) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: isActive
                    ? OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id))),
                        child: const Text('تتبع الطلب', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrderReviewScreen(product: _toMarketplaceProduct(order), artisanName: order.artisanName)),
                        ),
                        child: const Text('تقييم', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    late final Color bg;
    late final Color fg;
    late final String label;
    if (status == 'delivered') {
      bg = Colors.green.withOpacity(0.2);
      fg = Colors.green;
      label = 'مكتمل';
    } else if (_cancelledStatuses.contains(status)) {
      bg = Colors.red.withOpacity(0.2);
      fg = Colors.red;
      label = status == 'disputed' ? 'نزاع' : 'ملغي';
    } else {
      bg = AppColors.gold;
      fg = Colors.black;
      label = switch (status) {
        'pending' => 'بانتظار الموافقة',
        'seller_approved' => 'بانتظار الشحن',
        'shipping_assigned' => 'تم تعيين الشحن',
        'picked_up' => 'في الطريق',
        _ => 'نشط',
      };
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
