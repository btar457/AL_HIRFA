import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// طلبات الحرفي — سيتم بناؤها بالكامل في خطوة لاحقة من نفس المواصفات.
class ArtisanOrdersScreen extends StatelessWidget {
  const ArtisanOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('الطلبات الواردة', style: TextStyle(color: AppColors.text))),
      ),
    );
  }
}
