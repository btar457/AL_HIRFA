import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/delivery_request.dart';

class _AvailableItem {
  final DeliveryRequest request;
  final DateTime expiresAt;
  _AvailableItem({required this.request, required this.expiresAt});
}

/// طلبات التوصيل المتاحة أمام شركة الشحن (SHIPPING-3).
class AvailableDeliveriesScreen extends StatefulWidget {
  const AvailableDeliveriesScreen({super.key});
  @override
  State<AvailableDeliveriesScreen> createState() => _AvailableDeliveriesScreenState();
}

class _AvailableDeliveriesScreenState extends State<AvailableDeliveriesScreen> {
  late Timer _ticker;
  String _cityFilter = 'الكل';

  late final List<_AvailableItem> _items = [
    _AvailableItem(
      request: DeliveryRequest(orderNumber: '#HRF-9821', productName: 'إناء نحاسي منقوش', category: 'نحاسيات', fromProvince: 'بغداد', toProvince: 'النجف', buyerAddress: 'مخفي حتى القبول', sellerPhone: '07701234567', buyerPhone: 'مخفي', distance: '٢٥٠ كم تقريباً', fee: 4500),
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    ),
    _AvailableItem(
      request: DeliveryRequest(orderNumber: '#HRF-9815', productName: 'طبق نحاسي مزخرف', category: 'نحاسيات', fromProvince: 'البصرة', toProvince: 'البصرة', buyerAddress: 'مخفي حتى القبول', sellerPhone: '07709876543', buyerPhone: 'مخفي', distance: '١٥ كم تقريباً', fee: 4500),
      expiresAt: DateTime.now().add(const Duration(minutes: 3, seconds: 20)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _items.removeWhere((i) => DateTime.now().isAfter(i.expiresAt)));
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatRemaining(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return '٠٠:٠٠';
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _accept(_AvailableItem item) {
    setState(() => _items.remove(item));
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تم! الطلب أصبح لك', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          content: Text('يمكنك متابعته الآن من تبويب "توصيلاتي النشطة".', style: TextStyle(color: AppColors.subText)),
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
    final filtered = _cityFilter == 'الكل' ? _items : _items.where((i) => i.request.fromProvince == _cityFilter || i.request.toProvince == _cityFilter).toList();
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
              onPressed: () => _showCityFilterSheet(context),
            ),
          ],
        ),
        body: Column(
          children: [
            if (filtered.isNotEmpty) _buildAlertBanner(filtered.first),
            Expanded(child: filtered.isEmpty ? _buildEmptyState() : _buildList(filtered)),
          ],
        ),
      ),
    );
  }

  void _showCityFilterSheet(BuildContext context) {
    final cities = {'الكل', ..._items.map((i) => i.request.fromProvince)};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities.map((city) => RadioListTile<String>(
              value: city,
              groupValue: _cityFilter,
              activeColor: AppColors.gold,
              title: Text(city, style: const TextStyle(color: AppColors.text)),
              onChanged: (val) {
                setState(() => _cityFilter = val!);
                Navigator.pop(sheetContext);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner(_AvailableItem item) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text('طلب توصيل جديد في ${item.request.fromProvince}! اقبل الآن', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13))),
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

  Widget _buildList(List<_AvailableItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) => _buildCard(items[i]),
    );
  }

  Widget _buildCard(_AvailableItem item) {
    final request = item.request;
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
                    Text(request.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(request.category, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 20),
          Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.subText, size: 14), const SizedBox(width: 6), Text('من: ${request.fromProvince}', style: TextStyle(color: AppColors.subText, fontSize: 12))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.flag_outlined, color: AppColors.subText, size: 14), const SizedBox(width: 6), Text('إلى: ${request.toProvince}', style: TextStyle(color: AppColors.subText, fontSize: 12))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.call_outlined, color: AppColors.subText, size: 14), const SizedBox(width: 6), Text('رقم المشتري: ${request.buyerPhone}', style: TextStyle(color: AppColors.subText, fontSize: 12))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.social_distance_outlined, color: AppColors.subText, size: 14), const SizedBox(width: 6), Text(request.distance, style: TextStyle(color: AppColors.subText, fontSize: 12))]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('أجر التوصيل: ${request.fee} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 14)),
              Row(children: [Text('متبقي للانتهاء: ', style: TextStyle(color: AppColors.subText, fontSize: 11)), Text(_formatRemaining(item.expiresAt), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13))]),
            ],
          ),
          Text('(بعد خصم عمولة AL-HIRFA 10%)', style: TextStyle(color: AppColors.subText, fontSize: 10)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => _accept(item),
              child: const Text('قبول طلب التوصيل', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
