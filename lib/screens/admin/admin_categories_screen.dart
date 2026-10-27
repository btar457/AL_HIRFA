import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/categories.dart';
import '../../services/product_service.dart';

/// إدارة التصنيفات (ADMIN-11).
///
/// ملاحظة: تصنيفات AL-HIRFA (فخار، نحاسيات، منسوجات...) قائمة ثابتة مرتبطة
/// بصور مضمَّنة في التطبيق (kAppCategories) — وليست بيانات مُدارة في وقت
/// التشغيل. هذه الشاشة تعرض عدد المنتجات الحقيقي لكل فئة، وليست أداة لإضافة/
/// حذف فئات (ذلك يتطلب إعادة بناء التصنيف نفسه عبر Firestore + رفع صور،
/// وهي ميزة أكبر بكثير من إصلاح شاشة — أخبرني إن أردتها).
class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = kAppCategories.where((c) => c.id != 'all').toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('إدارة الفئات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          separatorBuilder: (context, i) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final category = categories[i];
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(category.imagePath, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.nameAr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
                        FutureBuilder<int>(
                          future: ProductService.instance.getActiveProductCountByCategory(category.id),
                          builder: (context, snapshot) => Text('${snapshot.data ?? 0} منتج', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
