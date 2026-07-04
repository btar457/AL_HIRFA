import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../models/marketplace_product.dart';

enum _StageStatus { completed, current, pending }

class _TimelineStage {
  final String title;
  final String subtitle;
  final _StageStatus status;
  const _TimelineStage({required this.title, required this.subtitle, required this.status});
}

class OrderTrackingScreen extends StatefulWidget {
  final MarketplaceProduct product;
  final String orderNumber;
  const OrderTrackingScreen({super.key, required this.product, this.orderNumber = '#HRF-9821'});
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  late final Animation<double> _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

  final _stages = const [
    _TimelineStage(title: 'تم استلام الطلب', subtitle: '٢ يوليو ٢٠٢٦ - ١٠:١٥ ص', status: _StageStatus.completed),
    _TimelineStage(title: 'موافقة البائع', subtitle: '٢ يوليو ٢٠٢٦ - ١١:٤٠ ص', status: _StageStatus.completed),
    _TimelineStage(title: 'جاري الشحن', subtitle: 'جاري الآن...', status: _StageStatus.current),
    _TimelineStage(title: 'تم التسليم', subtitle: '', status: _StageStatus.pending),
  ];

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _callRepresentative() async {
    final uri = Uri(scheme: 'tel', path: '07701234567');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تتبع الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductCard(),
              const SizedBox(height: 28),
              _buildTimeline(),
              const SizedBox(height: 28),
              _buildShippingCompanyCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('د.ع ${widget.product.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_stages.length, (i) {
        final stage = _stages[i];
        final isLast = i == _stages.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildStageCircle(stage.status),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: stage.status == _StageStatus.completed ? AppColors.gold : const Color(0xFF3A3A3A),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.title,
                        style: TextStyle(
                          color: stage.status == _StageStatus.pending ? AppColors.subText : (stage.status == _StageStatus.current ? AppColors.gold : AppColors.text),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (stage.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          stage.subtitle,
                          style: TextStyle(color: stage.status == _StageStatus.current ? AppColors.gold : AppColors.subText, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStageCircle(_StageStatus status) {
    switch (status) {
      case _StageStatus.completed:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        );
      case _StageStatus.current:
        return ScaleTransition(
          scale: _pulseAnimation,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: DecoratedBox(decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
          ),
        );
      case _StageStatus.pending:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF3A3A3A), width: 2)),
        );
    }
  }

  Widget _buildShippingCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('شركة بغداد السريعة للشحن', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('المندوب: ٠٧٧٠١٢٣٤٥٦٧', style: TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: const StadiumBorder()),
            onPressed: _callRepresentative,
            child: const Text('اتصال', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
