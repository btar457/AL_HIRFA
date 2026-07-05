import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

enum _StageStatus { completed, current, pending }

class _TimelineStage {
  final String title;
  final String subtitle;
  final _StageStatus status;
  const _TimelineStage({required this.title, required this.subtitle, required this.status});
}

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

/// تتبّع حالة طلب حقيقي حياً عبر OrderService.watchOrder.
class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  late final Animation<double> _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<_TimelineStage> _stagesFor(OrderModel order) {
    _StageStatus stageStatus(bool done, bool isCurrent) {
      if (done) return _StageStatus.completed;
      if (isCurrent) return _StageStatus.current;
      return _StageStatus.pending;
    }

    final approved = !['pending'].contains(order.status);
    final shipped = ['shipping_assigned', 'picked_up', 'delivered'].contains(order.status);
    final pickedUp = ['picked_up', 'delivered'].contains(order.status);
    final delivered = order.status == 'delivered';

    return [
      const _TimelineStage(title: 'تم استلام الطلب', subtitle: '', status: _StageStatus.completed),
      _TimelineStage(title: 'موافقة البائع', subtitle: approved ? '' : 'بانتظار موافقة الحرفي...', status: stageStatus(approved, order.status == 'pending')),
      _TimelineStage(title: 'جاري الشحن', subtitle: pickedUp ? '' : (shipped ? 'بانتظار الاستلام من الحرفي...' : ''), status: stageStatus(pickedUp, order.status == 'shipping_assigned')),
      _TimelineStage(title: 'تم التسليم', subtitle: '', status: stageStatus(delivered, order.status == 'picked_up')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: StreamBuilder<OrderModel?>(
          stream: OrderService.instance.watchOrder(widget.orderId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('تعذّر تحميل الطلب', style: TextStyle(color: AppColors.subText)));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            final order = snapshot.data;
            if (order == null) {
              return Center(child: Text('الطلب غير موجود', style: TextStyle(color: AppColors.subText)));
            }
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.background,
                  iconTheme: const IconThemeData(color: AppColors.gold),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تتبع الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildProductCard(order),
                      const SizedBox(height: 16),
                      if (order.status == 'cancelled') _buildCancelledBanner() else ...[
                        const SizedBox(height: 12),
                        _buildTimeline(order),
                      ],
                      if (order.shippingUid != null) ...[
                        const SizedBox(height: 28),
                        _buildShippingCompanyCard(order),
                      ],
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(OrderModel order) {
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
                Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('د.ع ${_formatPrice(order.price)}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(child: Text('تم إلغاء هذا الطلب', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    final stages = _stagesFor(order);
    return Column(
      children: List.generate(stages.length, (i) {
        final stage = stages[i];
        final isLast = i == stages.length - 1;
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

  Widget _buildShippingCompanyCard(OrderModel order) {
    // TODO: عرض رقم مندوب التوصيل الفعلي عند إضافة حقل جهة اتصال شركة
    // الشحن إلى OrderModel/shipping_profile (غير موجود في المخطط الحالي).
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: AppColors.gold, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(order.shippingCompanyName ?? 'شركة الشحن', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
