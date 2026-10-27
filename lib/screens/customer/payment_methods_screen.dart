import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// شاشة طرق الدفع (CUSTOMER-13).
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('طرق الدفع', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMethodCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'الدفع عند الاستلام',
              subtitle: 'ادفع كاشاً عند استلام طلبك',
              trailing: const Icon(Icons.check_circle, color: AppColors.gold),
              enabled: true,
            ),
            _buildMethodCard(
              icon: Icons.phone_iphone,
              title: 'ZainCash',
              subtitle: 'ادفع عبر محفظة زين كاش',
              trailing: _buildComingSoonChip(),
              enabled: false,
            ),
            _buildMethodCard(
              icon: Icons.credit_card,
              title: 'Qi Card',
              subtitle: 'ادفع عبر بطاقة كي',
              trailing: _buildComingSoonChip(),
              enabled: false,
            ),
            _buildMethodCard(
              icon: Icons.public,
              title: 'Payoneer',
              subtitle: 'للمدفوعات الدولية',
              trailing: _buildComingSoonChip(),
              enabled: false,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.3))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.lightBlueAccent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'حالياً الدفع عند الاستلام فقط متاح. طرق دفع إضافية قريباً!',
                      style: TextStyle(color: AppColors.text, fontSize: 13, height: 24 / 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.subText.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text('قريباً', style: TextStyle(color: AppColors.subText, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMethodCard({required IconData icon, required String title, required String subtitle, required Widget trailing, required bool enabled}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
