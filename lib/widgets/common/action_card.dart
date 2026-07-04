import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// بطاقة إجراء قابلة للنقر تُستخدم في بوابة المؤسس.
class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.15))),
      child: Row(children: [
        Icon(icon, color: AppColors.gold, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: AppColors.subText, fontSize: 12)),
        ])),
        const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 14),
      ]),
    );
  }
}
