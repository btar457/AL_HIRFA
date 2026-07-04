import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// الملف الشخصي للحرفي — سيتم بناؤه بالكامل في خطوة لاحقة من نفس المواصفات.
class ArtisanProfileScreen extends StatelessWidget {
  const ArtisanProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('حسابي', style: TextStyle(color: AppColors.text))),
      ),
    );
  }
}
