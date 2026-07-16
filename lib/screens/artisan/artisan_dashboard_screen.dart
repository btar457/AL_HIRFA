import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/wallet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../services/wallet_service.dart';
import '../shared/notifications_screen.dart';
import 'artisan_orders_screen.dart';
import 'artisan_wallet_screen.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

class ArtisanDashboardScreen extends StatelessWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: user == null
              ? Center(child: Text('سجّل الدخول لعرض لوحتك', style: TextStyle(color: AppColors.subText)))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildGreeting(user.name),
                    const SizedBox(height: 24),
                    StreamBuilder<List<OrderModel>>(
                      stream: OrderService.instance.getArtisanOrders(user.uid),
                      builder: (context, orderSnapshot) {
                        final orders = orderSnapshot.data ?? const <OrderModel>[];
                        final pendingOrders = orders.where((o) => o.status == 'pending').toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsGrid(context, user.uid, pendingOrders.length),
                            const SizedBox(height: 20),
                            _buildNewOrdersSection(context, pendingOrders),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildBestSellersSection(user.uid),
                    const SizedBox(height: 16),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 48),
        const Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
        Consumer<NotificationProvider>(
          builder: (context, notifications, _) => Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.gold),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
              if (notifications.unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('مرحباً، $name', style: const TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('حرفي موثّق في AL-HIRFA', style: TextStyle(color: AppColors.subText, fontSize: 13)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.black, size: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, String artisanUid, int pendingOrdersCount) {
    return StreamBuilder<WalletModel>(
      stream: WalletService.instance.getArtisanWallet(artisanUid),
      builder: (context, walletSnapshot) {
        final wallet = walletSnapshot.data ?? const WalletModel();
        return StreamBuilder<List<ProductModel>>(
          stream: ProductService.instance.getArtisanProducts(artisanUid),
          builder: (context, productSnapshot) {
            final activeProducts = (productSnapshot.data ?? const []).where((p) => p.status == 'active').length;
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(icon: Icons.payments_outlined, label: 'إجمالي المبيعات', value: '${_formatPrice(wallet.totalEarnings)} د.ع', valueColor: AppColors.gold, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanWalletScreen()))),
                _buildStatCard(icon: Icons.inventory_2_outlined, label: 'طلبات جديدة', value: '$pendingOrdersCount', valueColor: AppColors.text, showBadge: pendingOrdersCount > 0, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanOrdersScreen()))),
                _buildStatCard(icon: Icons.storefront_outlined, label: 'منتجاتي النشطة', valueColor: AppColors.gold, value: '$activeProducts'),
                _buildStatCard(icon: Icons.account_balance_wallet_outlined, label: 'رصيد متاح للسحب', value: '${_formatPrice(wallet.availableBalance)} د.ع', valueColor: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanWalletScreen()))),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color valueColor, bool showBadge = false, Widget? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 18),
                if (showBadge) ...[
                  const SizedBox(width: 6),
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                ],
              ],
            ),
            const Spacer(),
            Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: AppColors.subText, fontSize: 11)),
            if (trailing != null) ...[const SizedBox(height: 4), trailing],
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrdersSection(BuildContext context, List<OrderModel> pendingOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('طلبات تنتظر موافقتك', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanOrdersScreen())),
              child: const Text('عرض الكل', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        if (pendingOrders.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('لا توجد طلبات تنتظر موافقتك حالياً', style: TextStyle(color: AppColors.subText, fontSize: 13)))
        else
          ...pendingOrders.take(3).map((order) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(order.buyerName, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                      Text('د.ع ${_formatPrice(order.totalAmount)}', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => OrderService.instance.sellerApproveOrder(order.id),
                  child: const Text('قبول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          )),
      ],
    );
  }

  Widget _buildBestSellersSection(String artisanUid) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService.instance.getArtisanProducts(artisanUid),
      builder: (context, snapshot) {
        final products = (snapshot.data ?? const <ProductModel>[]).where((p) => p.salesCount > 0).toList()..sort((a, b) => b.salesCount.compareTo(a.salesCount));
        final bestSellers = products.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الأكثر مبيعاً', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (bestSellers.isEmpty)
              Text('لا توجد مبيعات مكتملة بعد', style: TextStyle(color: AppColors.subText, fontSize: 13))
            else
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: bestSellers.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final product = bestSellers[i];
                    return Container(
                      width: 110,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 22),
                          ),
                          const SizedBox(height: 6),
                          Text(product.name, style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${product.salesCount} عملية بيع', style: TextStyle(color: AppColors.subText, fontSize: 10)),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
