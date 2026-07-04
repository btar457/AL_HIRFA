import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// بطاقة إحصائية صغيرة (رقم + تسمية) تُستخدم في لوحات الحرفي والمؤسس.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.15))),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 11)),
      ]),
    );
  }
}
