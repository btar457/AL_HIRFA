import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'admin_shipping_screen.dart';
import 'review_artisans_screen.dart';

/// لوحة تحكم المؤسس الرئيسية (ADMIN-2).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _weeklySales = [120000.0, 250000.0, 180000.0, 320000.0, 275000.0, 410000.0, 250000.0];
  static const _days = ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildChartCard(),
              const SizedBox(height: 24),
              _buildAlertsSection(context),
              const SizedBox(height: 24),
              _buildPlatformStats(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('بوابة المؤسس', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            Text('٤ يوليو ٢٠٢٦', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          ],
        ),
        IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.gold), onPressed: () {}),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(icon: Icons.payments_outlined, label: 'إيرادات اليوم', value: '٢٥٠,٠٠٠ د.ع', valueColor: AppColors.gold),
        _buildStatCard(icon: Icons.person_add_outlined, label: 'مستخدمون جدد اليوم', value: '١٢', valueColor: AppColors.text),
        _buildStatCard(icon: Icons.receipt_long_outlined, label: 'طلبات اليوم', value: '٣٤', valueColor: AppColors.text),
        _buildStatCard(icon: Icons.local_shipping_outlined, label: 'توصيلات نشطة', value: '٨', valueColor: Colors.green),
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

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('المبيعات الأسبوعية', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(_weeklySales),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days.map((d) => Text(d, style: TextStyle(color: AppColors.subText, fontSize: 10))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تنبيهات عاجلة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildAlertTile(
          icon: Icons.person_outline,
          label: 'حرفيون ينتظرون المراجعة',
          count: '٣',
          buttonColor: AppColors.gold,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewArtisansScreen())),
        ),
        _buildAlertTile(
          icon: Icons.local_shipping_outlined,
          label: 'شركات شحن جديدة',
          count: '١',
          buttonColor: AppColors.gold,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShippingScreen())),
        ),
        _buildAlertTile(
          icon: Icons.report_gmailerrorred_outlined,
          label: 'بلاغات مستخدمين',
          count: '٢',
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

  Widget _buildPlatformStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _statRow('إجمالي الحرفيين النشطين', '١٤٨'),
          Divider(color: AppColors.subText.withOpacity(0.15)),
          _statRow('إجمالي المشترين', '٢,٣١٠'),
          Divider(color: AppColors.subText.withOpacity(0.15)),
          _statRow('إجمالي شركات الشحن', '٩'),
          Divider(color: AppColors.subText.withOpacity(0.15)),
          _statRow('إجمالي المنتجات', '٥٧٦'),
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
