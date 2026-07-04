import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// إدارة منتجات الحرفي — سيتم بناؤها بالكامل في خطوة لاحقة من نفس المواصفات.
class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('منتجاتي', style: TextStyle(color: AppColors.text))),
      ),
    );
  }
}
