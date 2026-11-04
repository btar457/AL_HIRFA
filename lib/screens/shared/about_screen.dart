import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import 'contact_support_screen.dart';
import '../../core/settings/app_prefs.dart';

/// شاشة "عن AL-HIRFA" (SHARED-6).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildContactTile({required IconData icon, required String label, required String value, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 18),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13)),
            const Spacer(),
            if (value.isNotEmpty) Text(value, style: TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.bold)),
            if (value.isEmpty && onTap != null) Icon(Icons.arrow_back_ios, color: AppColors.subText, size: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(tr('عن AL-HIRFA', 'About AL-HIRFA'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('HERITAGE IRAQI CRAFTSMANSHIP', style: TextStyle(color: AppColors.subText, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Center(child: Text(tr('الإصدار v1.0.0', 'Version 1.0.0'), style: TextStyle(color: AppColors.subText, fontSize: 12))),
            const SizedBox(height: 4),
            Center(child: Text('Established Baghdad 2024', style: TextStyle(color: AppColors.subText, fontSize: 12))),
            const SizedBox(height: 24),
            Divider(color: AppColors.gold.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              tr('تأسست AL-HIRFA لتكون جسراً بين الحرفي العراقي الأصيل والمشتري الباحث عن قطعة تحمل روح العراق. نؤمن بأن كل قطعة يدوية تحكي قصة، ونعمل على حماية هذه الحرف من الاندثار عبر منصة عادلة تحفظ حقوق الحرفي والمشتري وشركاء الشحن على حدٍّ سواء.', 'AL-HIRFA was founded as a bridge between authentic Iraqi artisans and buyers looking for pieces that carry the spirit of Iraq. We believe every handmade piece tells a story, and we work to keep these crafts alive through a fair platform that protects artisans and buyers alike.'),
              style: TextStyle(color: AppColors.text, fontSize: 14, height: 24 / 14),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 28),
            Text(tr('تواصل معنا', 'Contact us'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildContactTile(
                    icon: Icons.email_outlined,
                    label: tr('البريد الإلكتروني', 'Email'),
                    value: 'support@alhirfa.iq',
                    onTap: () => _open(Uri(scheme: 'mailto', path: 'support@alhirfa.iq')),
                  ),
                  Divider(color: AppColors.subText.withOpacity(0.15), height: 1),
                  _buildContactTile(
                    icon: Icons.chat_outlined,
                    label: tr('واتساب', 'WhatsApp'),
                    value: '+964 781 627 8766',
                    onTap: () => _open(Uri.parse('https://wa.me/9647816278766')),
                  ),
                  Divider(color: AppColors.subText.withOpacity(0.15), height: 1),
                  _buildContactTile(
                    icon: Icons.language,
                    label: tr('الموقع الإلكتروني', 'Website'),
                    value: 'alhirfa.iq',
                    onTap: () => _open(Uri.parse('https://alhirfa.iq')),
                  ),
                  Divider(color: AppColors.subText.withOpacity(0.15), height: 1),
                  _buildContactTile(
                    icon: Icons.support_agent_outlined,
                    label: tr('راسل الدعم من داخل التطبيق', 'Message support in the app'),
                    value: '',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactSupportScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(tr('الجهة المسؤولة قانونياً عن المنصة', 'Legal entity responsible for the platform'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildContactTile(icon: Icons.person_outline, label: tr('المالك والمسؤول', 'Owner'), value: 'Mustafa Alshlany'),
                  Divider(color: AppColors.subText.withOpacity(0.15), height: 1),
                  _buildContactTile(
                    icon: Icons.mail_outline,
                    label: tr('البريد الرسمي', 'Official email'),
                    value: 'mustafaalshlany@gmail.com',
                    onTap: () => _open(Uri(scheme: 'mailto', path: 'mustafaalshlany@gmail.com')),
                  ),
                  Divider(color: AppColors.subText.withOpacity(0.15), height: 1),
                  _buildContactTile(icon: Icons.location_on_outlined, label: tr('الموقع', 'Location'), value: tr('بغداد، العراق', 'Baghdad, Iraq')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(tr('صنع بكل فخر في العراق 🇮🇶', 'Proudly made in Iraq 🇮🇶'), style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
