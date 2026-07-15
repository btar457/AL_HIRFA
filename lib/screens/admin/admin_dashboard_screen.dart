import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/notification_provider.dart';
import '../../services/admin_service.dart';
import '../shared/notifications_screen.dart';
import 'admin_shipping_screen.dart';
import 'review_artisans_screen.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _DashboardData {
  final int revenueToday;
  final int newUsersToday;
  final int ordersToday;
  final int activeDeliveries;
  final List<double> weeklySales;
  final int pendingArtisans;
  final int pendingShippingCompanies;
  final int openDisputes;
  final int activeArtisans;
  final int buyers;
  final int shippingCompanies;
  final int totalProducts;

  const _DashboardData({
    required this.revenueToday,
    required this.newUsersToday,
    required this.ordersToday,
    required this.activeDeliveries,
    required this.weeklySales,
    required this.pendingArtisans,
    required this.pendingShippingCompanies,
    required this.openDisputes,
    required this.activeArtisans,
    required this.buyers,
    required this.shippingCompanies,
    required this.totalProducts,
  });
}

/// لوحة تحكم المؤسس الرئيسية (ADMIN-2).
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final Future<_DashboardData> _future = _load();

  Future<_DashboardData> _load() async {
    final admin = AdminService.instance;
    final results = await Future.wait([
      admin.getRevenueToday(),
      admin.getNewUsersTodayCount(),
      admin.getOrdersTodayCount(),
      admin.getActiveDeliveriesCount(),
      admin.getWeeklySales(),
      admin.getPendingArtisansCount(),
      admin.getPendingShippingCompaniesCount(),
      admin.getOpenDisputesCount(),
      admin.getActiveArtisansCount(),
      admin.getBuyersCount(),
      admin.getShippingCompaniesCount(),
      admin.getTotalProductsCount(),
    ]);
    return _DashboardData(
      revenueToday: results[0] as int,
      newUsersToday: results[1] as int,
      ordersToday: results[2] as int,
      activeDeliveries: results[3] as int,
      weeklySales: results[4] as List<double>,
      pendingArtisans: results[5] as int,
      pendingShippingCompanies: results[6] as int,
      openDisputes: results[7] as int,
      activeArtisans: results[8] as int,
      buyers: results[9] as int,
      shippingCompanies: results[10] as int,
      totalProducts: results[11] as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: FutureBuilder<_DashboardData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('تعذّر تحميل الإحصائيات', style: TextStyle(color: AppColors.subText)));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: AppColors.gold));
              }
              final data = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(data),
                  const SizedBox(height: 24),
                  _buildChartCard(data.weeklySales),
                  const SizedBox(height: 24),
                  _buildAlertsSection(context, data),
                  const SizedBox(height: 24),
                  _buildPlatformStats(data),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('بوابة المؤسس', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            Text(_formatDate(DateTime.now()), style: TextStyle(color: AppColors.subText, fontSize: 12)),
          ],
        ),
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

  Widget _buildStatsGrid(_DashboardData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(icon: Icons.payments_outlined, label: 'إيرادات اليوم', value: '${_formatPrice(data.revenueToday)} د.ع', valueColor: AppColors.gold),
        _buildStatCard(icon: Icons.person_add_outlined, label: 'مستخدمون جدد اليوم', value: '${data.newUsersToday}', valueColor: AppColors.text),
        _buildStatCard(icon: Icons.receipt_long_outlined, label: 'طلبات اليوم', value: '${data.ordersToday}', valueColor: AppColors.text),
        _buildStatCard(icon: Icons.local_shipping_outlined, label: 'توصيلات نشطة', value: '${data.activeDeliveries}', valueColor: Colors.green),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const Spacer(),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: AppColors.subText, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<double> weeklySales) {
    final days = List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      const weekdays = ['اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];
      return weekdays[day.weekday - 1];
    });
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('المبيعات — آخر 7 أيام', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(weeklySales),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) => Text(d, style: TextStyle(color: AppColors.subText, fontSize: 10))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context, _DashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تنبيهات عاجلة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildAlertTile(
          icon: Icons.person_outline,
          label: 'حرفيون ينتظرون المراجعة',
          count: '${data.pendingArtisans}',
          buttonColor: AppColors.gold,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewArtisansScreen())),
        ),
        _buildAlertTile(
          icon: Icons.local_shipping_outlined,
          label: 'شركات شحن جديدة',
          count: '${data.pendingShippingCompanies}',
          buttonColor: AppColors.gold,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShippingScreen())),
        ),
        _buildAlertTile(
          icon: Icons.report_gmailerrorred_outlined,
          label: 'بلاغات مفتوحة',
          count: '${data.openDisputes}',
          buttonColor: Colors.redAccent,
          onTap: () => showDialog(
            context: context,
            builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: AppColors.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                title: const Text('البلاغات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                content: Text('شاشة مراجعة البلاغات التفصيلية ستُضاف لاحقاً.', style: TextStyle(color: AppColors.subText)),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertTile({required IconData icon, required String label, required String count, required Color buttonColor, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.text, fontSize: 13))),
          Text(count, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: buttonColor, foregroundColor: buttonColor == AppColors.gold ? Colors.black : Colors.white, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: onTap,
            child: const Text('مراجعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformStats(_DashboardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _statRow('إجمالي الحرفيين النشطين', '${data.activeArtisans}'),
          Divider(color: AppColors.subText.withOpacity(0.15)),
          _statRow('إجمالي المشترين', '${data.buyers}'),
          Divider(color: AppColors.subText.withOpacity(0.15)),
          _statRow('إجمالي شركات الشحن', '${data.shippingCompanies}'),
          Divider(color: AppColors.subText.withOpacity(0.15)),
          _statRow('إجمالي المنتجات', '${data.totalProducts}'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1 : (maxValue - minValue);
    final stepX = size.width / (values.length - 1);

    final linePaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(colors: [AppColors.gold.withOpacity(0.25), AppColors.gold.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final y = size.height - ((values[i] - minValue) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = AppColors.gold);
    }
    fillPath.lineTo(stepX * (values.length - 1), size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.values != values;
}
