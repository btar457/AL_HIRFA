import 'package:flutter/material.dart';
import '../../core/constants/app_rules.dart';
import '../../core/constants/colors.dart';

class _WalletTransaction {
  final String orderNumber;
  final String date;
  final int fee;
  final int commission;
  const _WalletTransaction({required this.orderNumber, required this.date, required this.fee, required this.commission});
}

/// محفظة شركة الشحن (SHIPPING-7).
class ShippingWalletScreen extends StatelessWidget {
  const ShippingWalletScreen({super.key});

  static const _transactions = [
    _WalletTransaction(orderNumber: '#HRF-9690', date: '١٥ يونيو ٢٠٢٦', fee: 4500, commission: 500),
    _WalletTransaction(orderNumber: '#HRF-9611', date: '٢ يونيو ٢٠٢٦', fee: 4500, commission: 500),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('محفظة الشركة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 16),
            _buildInsuranceCard(),
            const SizedBox(height: 16),
            _buildSettlementCard(),
            const SizedBox(height: 20),
            const Text('سجل المعاملات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            ..._transactions.map(_buildTransactionTile),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF8B6B1F), AppColors.gold], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إجمالي الأرباح هذا الشهر', style: TextStyle(color: Colors.white, fontSize: 13)),
          SizedBox(height: 8),
          Text('٢٢٥,٠٠٠ د.ع', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('مبلغ التأمين المودع', '${AppRules.securityDeposit} د.ع', AppColors.gold),
          const SizedBox(height: 6),
          _row('المستخدم', '0 د.ع', AppColors.text),
          const SizedBox(height: 6),
          _row('المتبقي', '${AppRules.securityDeposit} د.ع', Colors.green),
        ],
      ),
    );
  }

  Widget _buildSettlementCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('المستحق لـ AL-HIRFA هذا الأسبوع', '22,500 د.ع', Colors.redAccent),
          const SizedBox(height: 6),
          Text('موعد التسوية: الجمعة القادمة', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {},
              child: const Text('تفاصيل التسوية', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildTransactionTile(_WalletTransaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(t.date, style: TextStyle(color: AppColors.subText, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${t.fee} د.ع', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('-${t.commission} د.ع عمولة', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
