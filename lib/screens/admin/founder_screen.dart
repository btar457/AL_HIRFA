import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/action_card.dart';

class FounderScreen extends StatelessWidget {
  const FounderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('بوابة المؤسس', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('مؤمن ٢٥٦ بت', style: TextStyle(color: Colors.green, fontSize: 10)),
          )],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(child: StatCard(label: 'العمولات', value: '١٢,٥٠٠ د.ع', color: Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'الحرفيون', value: '٢٤ نشط', color: AppColors.gold)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(label: 'الامتثال', value: '١٠٠٪', color: Colors.green)),
            ]),
            const SizedBox(height: 20),
            const Text('إجراءات الجودة', style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const ActionCard(title: 'مراجعة منتج جديد', subtitle: 'التحقق من أصالة العمل المرفوع', icon: Icons.fact_check_outlined),
            const SizedBox(height: 10),
            const ActionCard(title: 'تقارير مالية', subtitle: 'العمولات والمستحقات الأسبوعية', icon: Icons.bar_chart_outlined),
            const SizedBox(height: 10),
            const ActionCard(title: 'إدارة الحسابات', subtitle: 'مراجعة وتعليق الحسابات المخالفة', icon: Icons.manage_accounts_outlined),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(border: Border.all(color: Colors.redAccent.withOpacity(0.4)), borderRadius: BorderRadius.circular(10)),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('نظام العقوبات الفوري — البند ٥.٣', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('في حال ثبوت التهرب أو بيع مواد مقلدة، يتم تطبيق الحظر الكلي فوراً.', style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
