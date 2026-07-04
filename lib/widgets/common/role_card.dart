import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// بطاقة اختيار نوع الحساب في شاشة الـ Onboarding.
class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(subtitle, style: TextStyle(color: AppColors.subText, fontSize: 13)),
          ]),
          const Spacer(),
          const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 16),
        ]),
      ),
    );
  }
}
