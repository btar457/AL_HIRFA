import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'artisan_chat_screen.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, title: const Text('الاستوديو', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)), centerTitle: true),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 64),
            const SizedBox(height: 24),
            const Text('مستشار الأصالة التراثية', style: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('استشر الذكاء الاصطناعي لتدقيق جودة عملك الفني وصياغة الوصف قبل النشر', style: TextStyle(color: AppColors.subText, fontSize: 14, height: 1.6), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtisanChatScreen())),
              child: const Text('ابدأ المحادثة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ]),
        )),
      ),
    );
  }
}
