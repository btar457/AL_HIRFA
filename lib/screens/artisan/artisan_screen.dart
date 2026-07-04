import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/artisan_product.dart';
import '../../widgets/common/stat_card.dart';

class ArtisanScreen extends StatefulWidget {
  const ArtisanScreen({super.key});
  @override
  State<ArtisanScreen> createState() => _ArtisanScreenState();
}

class _ArtisanScreenState extends State<ArtisanScreen> {
  final List<ArtisanProduct> _products = [
    const ArtisanProduct(name: 'إناء نحاسي منقوش', price: '125,000', stock: 3, status: 'معتمد'),
    const ArtisanProduct(name: 'طبق نحاسي مزخرف', price: '90,000', stock: 5, status: 'قيد المراجعة'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('لوحة الحرفي', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.gold), onPressed: () => _showAddProduct(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(child: StatCard(label: 'المبيعات', value: '١٢٥,٠٠٠ د.ع', color: Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'التسوية', value: '٧ أيام', color: Colors.amber)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'المنتجات', value: '${_products.length}', color: AppColors.gold)),
            ]),
            const SizedBox(height: 20),
            const Text('منتجاتي', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._products.map((p) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.15))),
              child: Row(children: [
                const Icon(Icons.inventory_2_outlined, color: AppColors.gold, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  Text('${p.price} د.ع  |  الكمية: ${p.stock}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (p.status == 'معتمد' ? Colors.green : Colors.orange).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(p.status, style: TextStyle(color: p.status == 'معتمد' ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  void _showAddProduct(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('إضافة منتج جديد', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(labelText: 'اسم المنتج', labelStyle: TextStyle(color: AppColors.subText),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.gold)))),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(labelText: 'السعر (دينار)', labelStyle: TextStyle(color: AppColors.subText),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.gold)))),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 48)),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                  setState(() => _products.add(ArtisanProduct(name: nameCtrl.text, price: priceCtrl.text, stock: 1, status: 'قيد المراجعة')));
                  Navigator.pop(context);
                }
              },
              child: const Text('رفع المنتج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
