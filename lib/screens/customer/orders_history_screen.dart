import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../widgets/common/loading_shimmer.dart';
import 'order_review_screen.dart';
import 'order_tracking_screen.dart';
import '../../core/settings/app_prefs.dart';

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
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text(tr('طلباتي', 'My orders'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: AppColors.gold),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: [
              Tab(text: 'الكل'),
              Tab(text: tr('قيد التنفيذ', 'In progress')),
              Tab(text: tr('مكتملة', 'Completed')),
              Tab(text: tr('ملغاة', 'Cancelled')),
            ],
          ),
        ),
        body: buyerUid == null
            ? Center(child: Text(tr('سجّل الدخول لعرض طلباتك', 'Sign in to see your orders'), style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.getBuyerOrders(buyerUid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(tr('تعذّر تحميل الطلبات', 'Couldn\'t load orders'), style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const ListRowShimmer();
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
      return Center(child: Text(tr('لا توجد طلبات', 'No orders'), style: TextStyle(color: AppColors.subText)));
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
                ProductThumbnail(imageUrl: order.productImage, size: 80, iconSize: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.orderNumber, style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                          _buildStatusChip(order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(order.productName, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(tr('د.ع ${_formatPrice(order.price)}', 'IQD ${_formatPrice(order.price)}'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            if (isActive || (isCompleted && !order.isReviewed)) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: isActive
                    ? OutlinedButton(
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id))),
                        child: Text(tr('تتبع الطلب', 'Track order'), style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrderReviewScreen(order: order)),
                        ),
                        child: Text(tr('تقييم', 'Rate'), style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
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
      label = tr('مكتمل', 'Completed');
    } else if (_cancelledStatuses.contains(status)) {
      bg = Colors.red.withOpacity(0.2);
      fg = Colors.red;
      label = status == 'disputed' ? tr('نزاع', 'Disputed') : tr('ملغي', 'Cancelled');
    } else {
      bg = AppColors.gold;
      fg = Colors.black;
      label = switch (status) {
        'pending' => tr('بانتظار الموافقة', 'Awaiting approval'),
        'seller_approved' => tr('بانتظار الشحن', 'Awaiting shipping'),
        'shipping_assigned' => tr('تم تعيين الشحن', 'Shipping assigned'),
        'picked_up' => tr('في الطريق', 'On the way'),
        _ => tr('نشط', 'Active'),
      };
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
