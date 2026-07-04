import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum _AdminOrderStatus { inProgress, completed, cancelled, issue }

class _AdminOrder {
  final String orderNumber;
  final String date;
  final String productName;
  final String price;
  final String buyerName;
  final String artisanName;
  final String shippingCompany;
  final _AdminOrderStatus status;
  final String? issueDescription;
  const _AdminOrder({required this.orderNumber, required this.date, required this.productName, required this.price, required this.buyerName, required this.artisanName, required this.shippingCompany, required this.status, this.issueDescription});
}

/// إدارة الطلبات على مستوى المنصة (ADMIN-6).
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filter = 'الكل';

  static const _orders = [
    _AdminOrder(orderNumber: '#HRF-9821', date: '٣ يوليو ٢٠٢٦', productName: 'إناء نحاسي منقوش', price: '125,000', buyerName: 'سارة العبيدي', artisanName: 'أبو مصطفى', shippingCompany: 'بغداد السريعة', status: _AdminOrderStatus.inProgress),
    _AdminOrder(orderNumber: '#HRF-9756', date: '٢٤ يونيو ٢٠٢٦', productName: 'إبريق نحاسي بصري', price: '210,000', buyerName: 'نور الزهراوي', artisanName: 'أبو مصطفى', shippingCompany: 'الفرات للتوصيل', status: _AdminOrderStatus.completed),
    _AdminOrder(orderNumber: '#HRF-9700', date: '٢٠ يونيو ٢٠٢٦', productName: 'صينية نحاسية كبيرة', price: '180,000', buyerName: 'حسن عبود', artisanName: 'زينب كريم', shippingCompany: 'بغداد السريعة', status: _AdminOrderStatus.issue, issueDescription: 'المشتري يدّعي استلام منتج تالف'),
    _AdminOrder(orderNumber: '#HRF-9611', date: '٢ يونيو ٢٠٢٦', productName: 'مرآة نحاسية منقوشة', price: '150,000', buyerName: 'زينب كريم', artisanName: 'أبو مصطفى', shippingCompany: '—', status: _AdminOrderStatus.cancelled),
  ];

  List<_AdminOrder> get _filtered {
    if (_filter == 'الكل') return _orders;
    final status = switch (_filter) {
      'قيد التنفيذ' => _AdminOrderStatus.inProgress,
      'مكتملة' => _AdminOrderStatus.completed,
      'ملغاة' => _AdminOrderStatus.cancelled,
      'مشكلات' => _AdminOrderStatus.issue,
      _ => null,
    };
    return _orders.where((o) => o.status == status).toList();
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
          title: const Text('إدارة الطلبات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: 5,
                separatorBuilder: (context, i) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final labels = ['الكل', 'قيد التنفيذ', 'مكتملة', 'ملغاة', 'مشكلات'];
                  final label = labels[i];
                  final selected = _filter == label;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: selected ? AppColors.gold : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.gold.withOpacity(selected ? 1 : 0.4))),
                      child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.black : AppColors.text, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => _buildOrderCard(_filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(_AdminOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
              _buildStatusChip(order.status),
            ],
          ),
          Text(order.date, style: TextStyle(color: AppColors.subText, fontSize: 11)),
          const Divider(color: Color(0xFF2A2A2A)),
          Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
          Text('د.ع ${order.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          Text('المشتري: ${order.buyerName}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('البائع: ${order.artisanName}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('شركة الشحن: ${order.shippingCompany}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          if (order.status == _AdminOrderStatus.issue) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.issueDescription ?? '', style: TextStyle(color: AppColors.text, fontSize: 12)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('تواصل مع المشتري', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold))),
                      OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('تواصل مع الشركة', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold))),
                      OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: const Text('إلغاء الطلب', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(_AdminOrderStatus status) {
    late final Color color;
    late final String label;
    switch (status) {
      case _AdminOrderStatus.inProgress:
        color = AppColors.gold;
        label = 'قيد التنفيذ';
        break;
      case _AdminOrderStatus.completed:
        color = Colors.green;
        label = 'مكتملة';
        break;
      case _AdminOrderStatus.cancelled:
        color = Colors.grey;
        label = 'ملغاة';
        break;
      case _AdminOrderStatus.issue:
        color = Colors.redAccent;
        label = 'مشكلة';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
