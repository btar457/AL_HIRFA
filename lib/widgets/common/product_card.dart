import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// بطاقة عرض منتج ضمن شبكة السوق.
class ProductCard extends StatelessWidget {
  final String name, artisan, price;

  const ProductCard({
    super.key,
    required this.name,
    required this.artisan,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.15))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: const Center(child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 40)),
        )),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(artisan, style: TextStyle(color: AppColors.subText, fontSize: 11)),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$price د.ع', style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة $name للسلة'), backgroundColor: AppColors.gold.withOpacity(0.8))),
              child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.add, color: Colors.black, size: 16)),
            ),
          ]),
        ])),
      ]),
    );
  }
}
