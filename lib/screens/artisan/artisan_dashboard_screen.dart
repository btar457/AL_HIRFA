import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// لوحة تحكم الحرفي — سيتم بناؤها بالكامل في الشاشة التالية من نفس المواصفات.
class ArtisanDashboardScreen extends StatelessWidget {
  const ArtisanDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('لوحة التحكم', style: TextStyle(color: AppColors.text))),
      ),
    );
  }
}
