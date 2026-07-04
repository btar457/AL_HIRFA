import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/order_item.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final orders = const [
      OrderItem(id: 'ORD-001', name: 'إناء نحاسي منقوش', status: 'جاري التوصيل', price: '125,000', statusColor: Colors.amber),
      OrderItem(id: 'ORD-002', name: 'سجادة بابلية', status: 'تم التسليم', price: '450,000', statusColor: Colors.green),
      OrderItem(id: 'ORD-003', name: 'محبس فضة عقيق', status: 'قيد المراجعة', price: '85,000', statusColor: Colors.blue),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, title: const Text('طلباتي', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)), centerTitle: true),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final o = orders[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.15))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(o.id, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: o.statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(o.status, style: TextStyle(color: o.statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(o.name, style: const TextStyle(color: AppColors.text, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${o.price} د.ع', style: const TextStyle(color: AppColors.gold, fontSize: 13)),
              ]),
            );
          },
        ),
      ),
    );
  }
}
