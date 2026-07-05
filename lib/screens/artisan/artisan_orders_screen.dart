import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import 'artisan_order_detail_screen.dart';

const _inProgressStatuses = {'seller_approved', 'shipping_assigned', 'picked_up'};

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class ArtisanOrdersScreen extends StatefulWidget {
  const ArtisanOrdersScreen({super.key});
  @override
  State<ArtisanOrdersScreen> createState() => _ArtisanOrdersScreenState();
}

class _ArtisanOrdersScreenState extends State<ArtisanOrdersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _ordersFor(List<OrderModel> orders, Set<String> statuses) => orders.where((o) => statuses.contains(o.status)).toList();

  void _acceptOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('قبول الطلب؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('بعد قبولك سيُرسل إشعار لشركات الشحن.', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await OrderService.instance.sellerApproveOrder(order.id);
                } catch (e) {
                  if (!mounted) return;
                  AppError.showSnackbar(context, AppError.getFirebaseError(e));
                }
              },
              child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _rejectOrder(OrderModel order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('رفض الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'سبب الرفض',
              hintStyle: TextStyle(color: AppColors.subText),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('تراجع', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await OrderService.instance.sellerRejectOrder(order.id, reasonController.text.trim());
                } catch (e) {
                  if (!mounted) return;
                  AppError.showSnackbar(context, AppError.getFirebaseError(e));
                }
              },
              child: const Text('تأكيد الرفض', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artisanUid = context.watch<AuthProvider>().currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('الطلبات الواردة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'جديدة 🔴'), Tab(text: 'قيد التنفيذ 🟡'), Tab(text: 'مكتملة ✅'), Tab(text: 'مرفوضة ❌')],
          ),
        ),
        body: artisanUid == null
            ? Center(child: Text('سجّل الدخول لعرض الطلبات', style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.getArtisanOrders(artisanUid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('تعذّر تحميل الطلبات', style: TextStyle(color: AppColors.subText)));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  final orders = snapshot.data!;
                  final newOrders = _ordersFor(orders, {'pending'});
                  return Column(
                    children: [
                      if (newOrders.isNotEmpty) _buildNewOrdersBanner(newOrders.length),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOrdersList(newOrders),
                            _buildOrdersList(_ordersFor(orders, _inProgressStatuses)),
                            _buildOrdersList(_ordersFor(orders, {'delivered'})),
                            _buildOrdersList(_ordersFor(orders, {'cancelled'})),
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

  Widget _buildNewOrdersBanner(int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text('لديك $count طلبات جديدة بانتظار المراجعة', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(child: Text('لا توجد طلبات', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildOrderCard(orders[i]),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtisanOrderDetailScreen(order: order))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Color(0xFF2A2A2A)),
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
                  child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('د.ع ${_formatPrice(order.price)}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(order.buyerName, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.subText, size: 13), const SizedBox(width: 4), Expanded(child: Text('${order.governorate} - ${order.district}', style: TextStyle(color: AppColors.subText, fontSize: 11)))]),
                      const SizedBox(height: 2),
                      Row(children: [const Icon(Icons.call_outlined, color: AppColors.subText, size: 13), const SizedBox(width: 4), Text(order.buyerPhone, style: TextStyle(color: AppColors.subText, fontSize: 11))]),
                    ],
                  ),
                ),
              ],
            ),
            if (order.status == 'pending') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _acceptOrder(order),
                  child: const Text('قبول الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _rejectOrder(order),
                  child: const Text('رفض الطلب', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            if (_inProgressStatuses.contains(order.status)) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  order.shippingCompanyName != null ? 'جاري الشحن' : 'بانتظار الشحن',
                  style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              if (order.shippingCompanyName != null) ...[
                const SizedBox(height: 6),
                Text(order.shippingCompanyName!, style: TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
