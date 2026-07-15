import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/notification_provider.dart';
import '../shared/notifications_screen.dart';
import 'artisan_orders_screen.dart';
import 'artisan_wallet_screen.dart';

class _MiniOrder {
  final String productName;
  final String buyerName;
  final String price;
  const _MiniOrder({required this.productName, required this.buyerName, required this.price});
}

class _MiniProduct {
  final String name;
  final int sales;
  const _MiniProduct({required this.name, required this.sales});
}

class ArtisanDashboardScreen extends StatelessWidget {
  const ArtisanDashboardScreen({super.key});

  static const _newOrders = [
    _MiniOrder(productName: 'إناء نحاسي منقوش', buyerName: 'سارة العبيدي', price: '125,000'),
    _MiniOrder(productName: 'طبق نحاسي مزخرف', buyerName: 'محمد الكناني', price: '90,000'),
    _MiniOrder(productName: 'إبريق نحاسي بصري', buyerName: 'نور الزهراوي', price: '210,000'),
  ];

  static const _bestSellers = [
    _MiniProduct(name: 'إناء نحاسي منقوش', sales: 42),
    _MiniProduct(name: 'طبق نحاسي مزخرف', sales: 31),
    _MiniProduct(name: 'إبريق نحاسي بصري', sales: 27),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildGreeting(),
              const SizedBox(height: 24),
              _buildStatsGrid(context),
              const SizedBox(height: 28),
              _buildNewOrdersSection(context),
              const SizedBox(height: 28),
              _buildBestSellersSection(),
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
        IconButton(icon: const Icon(Icons.menu, color: AppColors.gold), onPressed: () {}),
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

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('مرحباً، أبو مصطفى', style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
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

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(icon: Icons.payments_outlined, label: 'إجمالي المبيعات', value: '١,٢٥٠,٠٠٠ د.ع', valueColor: AppColors.gold, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanWalletScreen()))),
        _buildStatCard(icon: Icons.inventory_2_outlined, label: 'طلبات جديدة', value: '٤', valueColor: AppColors.text, showBadge: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanOrdersScreen()))),
        _buildStatCard(
          icon: Icons.star,
          label: 'تقييمك',
          valueColor: AppColors.gold,
          value: '٤.٨',
          trailing: Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_half, color: AppColors.gold, size: 12))),
        ),
        _buildStatCard(icon: Icons.account_balance_wallet_outlined, label: 'رصيد المحفظة', value: '٨٥٠,٠٠٠ د.ع', valueColor: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanWalletScreen()))),
      ],
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

  Widget _buildNewOrdersSection(BuildContext context) {
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
        ..._newOrders.map((order) => Container(
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
                    Text('د.ع ${order.price}', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () {}, // TODO: منطق القبول الفعلي ضمن artisan_orders_screen
                child: const Text('قبول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBestSellersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الأكثر مبيعاً', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _bestSellers.length,
            separatorBuilder: (context, i) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final product = _bestSellers[i];
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
                    Text('${product.sales} عملية بيع', style: TextStyle(color: AppColors.subText, fontSize: 10)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
