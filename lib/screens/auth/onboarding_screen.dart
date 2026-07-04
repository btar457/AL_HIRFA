import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int? _selectedRole;

  final _roles = const [
    {'emoji': '🛒', 'name': 'مشتري'},
    {'emoji': '🎨', 'name': 'حرفي'},
    {'emoji': '🚚', 'name': 'شركة شحن'},
  ];

  void _continueToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(initialRoleIndex: _selectedRole)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/onboarding_bg.jpg', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.75))),
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('مرحباً في عالم الحرفة العراقية', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('اختر نوع حسابك للبدء', style: TextStyle(color: AppColors.subText, fontSize: 14)),
                    const SizedBox(height: 40),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
                      itemCount: _roles.length,
                      itemBuilder: (context, i) {
                        final selected = _selectedRole == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedRole = i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: selected ? AppColors.gold : AppColors.gold.withOpacity(0.3), width: selected ? 2 : 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_roles[i]['emoji']!, style: const TextStyle(fontSize: 32)),
                                const SizedBox(height: 8),
                                Text(_roles[i]['name']!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: _selectedRole == null ? null : _continueToRegister,
                        child: const Text('ابدأ رحلتك', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
