import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// الشروط والأحكام الكاملة (راجع AL-HIRFA-Legal-Rules.md — "ملخص القوانين للمستخدمين").
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _buyerRules = [
    'ادفع كاشاً عند الاستلام فقط',
    'افحص المنتج قبل الدفع للمندوب',
    'يحق لك رفض المنتج التالف',
    'قيّم تجربتك خلال 7 أيام',
    'للشكاوى: تواصل معنا خلال 24 ساعة',
  ];

  static const _artisanRules = [
    'انشر منتجات حقيقية بصور حقيقية',
    'رد على الطلبات خلال 48 ساعة',
    'عمولة المنصة 10% من كل بيعة',
    'أرباحك تُحوَّل بعد 72 ساعة من التسليم',
    '3 رفضات متتالية = تحذير رسمي',
  ];

  static const _shippingRules = [
    'أجر ثابت 4,500 د.ع لكل توصيل',
    'أول من يقبل يأخذ الطلب',
    'سدّد مستحقات المنصة كل جمعة',
    'التأخر في السداد = غرامة 2% أسبوعياً',
    'التأمين المودع يحمي الطرفين',
  ];

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
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'توضّح هذه الشروط حقوق والتزامات كل طرف على منصة AL-HIRFA. باستخدامك للمنصة فإنك توافق على الالتزام بها.',
              style: TextStyle(color: AppColors.subText, fontSize: 13, height: 24 / 14),
            ),
            const SizedBox(height: 24),
            _buildSection(title: 'للمشتري', rules: _buyerRules),
            const SizedBox(height: 24),
            _buildSection(title: 'للحرفي', rules: _artisanRules),
            const SizedBox(height: 24),
            _buildSection(title: 'لشركة الشحن', rules: _shippingRules),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<String> rules}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...rules.map((rule) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                Expanded(child: Text(rule, style: const TextStyle(color: AppColors.text, fontSize: 14, height: 24 / 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
