import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/common/role_card.dart';
import '../shared/main_nav.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('AL-HIRFA', style: TextStyle(color: AppColors.gold, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 4)),
                const SizedBox(height: 8),
                Text('اختر نوع حسابك للبدء', style: TextStyle(color: AppColors.subText, fontSize: 15)),
                const SizedBox(height: 48),
                RoleCard(icon: Icons.shopping_bag_outlined, title: 'مشتري', subtitle: 'اقتنِ قطعاً فريدة', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()))),
                const SizedBox(height: 16),
                RoleCard(icon: Icons.gavel_outlined, title: 'حرفي', subtitle: 'اعرض إبداعاتك', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav(initialIndex: 3)))),
                const SizedBox(height: 16),
                RoleCard(icon: Icons.local_shipping_outlined, title: 'شركة شحن', subtitle: 'انضم كشريك لوجستي', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()))),
                const SizedBox(height: 16),
                RoleCard(icon: Icons.admin_panel_settings_outlined, title: 'إدارة', subtitle: 'بوابة المؤسس', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav(initialIndex: 4)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
