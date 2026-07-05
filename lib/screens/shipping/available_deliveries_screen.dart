import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/common/loading_shimmer.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

/// طلبات التوصيل المتاحة أمام شركة الشحن (SHIPPING-3).
class AvailableDeliveriesScreen extends StatefulWidget {
  const AvailableDeliveriesScreen({super.key});
  @override
  State<AvailableDeliveriesScreen> createState() => _AvailableDeliveriesScreenState();
}

class _AvailableDeliveriesScreenState extends State<AvailableDeliveriesScreen> {
  late final Timer _ticker;
  String? _governorateFilter; // null = كل المحافظات
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    // يعيد رسم عدّاد "متبقي للانتهاء" كل ثانية (لا علاقة له ببث Firestore).
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatRemaining(DateTime? deadline) {
    if (deadline == null) return '--:--';
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return '٠٠:٠٠';
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _accept(OrderModel order) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || _isAccepting) return;

    setState(() => _isAccepting = true);
    try {
      final accepted = await OrderService.instance.shippingAcceptOrder(order.id, user.uid, user.name);
      if (!mounted) return;
      _showResultDialog(accepted);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  void _showResultDialog(bool accepted) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(accepted ? 'تم! الطلب أصبح لك' : 'عذراً، سبقك شخص آخر', style: TextStyle(color: accepted ? AppColors.gold : Colors.redAccent, fontWeight: FontWeight.bold)),
          content: Text(accepted ? 'يمكنك متابعته الآن من تبويب "توصيلاتي النشطة".' : 'قبلت شركة أخرى هذا الطلب قبلك.', style: TextStyle(color: AppColors.subText)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('طلبات التوصيل المتاحة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined, color: AppColors.gold),
              onPressed: () => _showGovernorateFilterSheet(context),
            ),
          ],
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: OrderService.instance.getAvailableDeliveries(_governorateFilter),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('تعذّر تحميل الطلبات', style: TextStyle(color: AppColors.subText)));
            }
            if (!snapshot.hasData) {
              return const ListRowShimmer();
            }
            final orders = snapshot.data!;
            return Column(
              children: [
                if (orders.isNotEmpty) _buildAlertBanner(orders.first),
                Expanded(child: orders.isEmpty ? _buildEmptyState() : _buildList(orders)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showGovernorateFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String?>(
                value: null,
                groupValue: _governorateFilter,
                activeColor: AppColors.gold,
                title: const Text('كل المحافظات', style: TextStyle(color: AppColors.text)),
                onChanged: (val) {
                  setState(() => _governorateFilter = val);
                  Navigator.pop(sheetContext);
                },
              ),
              ...kCities.map((city) => RadioListTile<String?>(
                value: city,
                groupValue: _governorateFilter,
                activeColor: AppColors.gold,
                title: Text(city, style: const TextStyle(color: AppColors.text)),
                onChanged: (val) {
                  setState(() => _governorateFilter = val);
                  Navigator.pop(sheetContext);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner(OrderModel order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text('طلب توصيل جديد في ${order.governorate}! اقبل الآن', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined, color: AppColors.subText.withOpacity(0.5), size: 64),
          const SizedBox(height: 16),
          Text('لا توجد طلبات متاحة الآن', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('سنُعلمك فور وصول طلب جديد', style: TextStyle(color: AppColors.subText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildCard(orders[i]),
    );
  }

  Widget _buildCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)])),
                child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(order.orderNumber, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 20),
          Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.subText, size: 14), const SizedBox(width: 6), Text('المحافظة: ${order.governorate}', style: TextStyle(color: AppColors.subText, fontSize: 12))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.flag_outlined, color: AppColors.subText, size: 14), const SizedBox(width: 6), Expanded(child: Text('العنوان: ${order.district}', style: TextStyle(color: AppColors.subText, fontSize: 12)))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.call_outlined, color: AppColors.subText, size: 14), const SizedBox(width: 6), Text('رقم المشتري: مخفي حتى القبول', style: TextStyle(color: AppColors.subText, fontSize: 12))]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('أجر التوصيل: ${_formatPrice(order.shippingEarnings)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
              Row(children: [Text('متبقي للانتهاء: ', style: TextStyle(color: AppColors.subText, fontSize: 11)), Text(_formatRemaining(order.shippingAcceptDeadline), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13))]),
            ],
          ),
          Text('(بعد خصم عمولة AL-HIRFA)', style: TextStyle(color: AppColors.subText, fontSize: 10)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _isAccepting ? null : () => _accept(order),
              child: const Text('قبول طلب التوصيل', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
