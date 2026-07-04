import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// إضافة منتج جديد — سيتم بناؤها بالكامل في الخطوة التالية من نفس المواصفات.
class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, iconTheme: const IconThemeData(color: AppColors.gold), title: const Text('إضافة منتج جديد', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold))),
        body: const Center(child: Text('إضافة منتج جديد', style: TextStyle(color: AppColors.text))),
      ),
    );
  }
}
