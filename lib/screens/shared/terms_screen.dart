import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// الشروط والأحكام الكاملة — يُستكمل محتواها بالكامل لاحقاً (راجع AL-HIRFA-Legal-Rules.md).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('الشروط والأحكام', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: Text('سيتم عرض الشروط والأحكام الكاملة هنا.', style: TextStyle(color: AppColors.text, fontSize: 14, height: 1.7)),
        ),
      ),
    );
  }
}
