import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// شاشة "عن AL-HIRFA" (SHARED-6).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _buildContactTile({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('عن AL-HIRFA', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('HERITAGE IRAQI CRAFTSMANSHIP', style: TextStyle(color: AppColors.subText, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Center(child: Text('الإصدار v1.0.0', style: TextStyle(color: AppColors.subText, fontSize: 12))),
            const SizedBox(height: 4),
            Center(child: Text('Established Baghdad 2024', style: TextStyle(color: AppColors.subText, fontSize: 12))),
            const SizedBox(height: 24),
            Divider(color: AppColors.gold.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'تأسست AL-HIRFA لتكون جسراً بين الحرفي العراقي الأصيل والمشتري الباحث عن قطعة تحمل روح العراق. نؤمن بأن كل قطعة يدوية تحكي قصة، ونعمل على حماية هذه الحرف من الاندثار عبر منصة عادلة تحفظ حقوق الحرفي والمشتري وشركاء الشحن على حدٍّ سواء.',
              style: TextStyle(color: AppColors.text, fontSize: 14, height: 24 / 14),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 28),
            const Text('تواصل معنا', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildContactTile(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: 'support@alhirfa.iq'),
                  Divider(color: AppColors.subText.withOpacity(0.15), height: 1),
                  _buildContactTile(icon: Icons.chat_outlined, label: 'واتساب', value: '+964 770 000 0000'),
                  Divider(color: AppColors.subText.withOpacity(0.15), height: 1),
                  _buildContactTile(icon: Icons.language, label: 'الموقع الإلكتروني', value: 'alhirfa.iq'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text('صنع بكل فخر في العراق 🇮🇶', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
