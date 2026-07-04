import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum _TransactionType { income, commission }

class _Transaction {
  final String productName;
  final String date;
  final String amount;
  final _TransactionType type;
  const _Transaction({required this.productName, required this.date, required this.amount, required this.type});
}

class ArtisanWalletScreen extends StatelessWidget {
  const ArtisanWalletScreen({super.key});

  static const _transactions = [
    _Transaction(productName: 'إبريق نحاسي بصري', date: '٢٨ يونيو ٢٠٢٦', amount: '189,000', type: _TransactionType.income),
    _Transaction(productName: 'عمولة AL-HIRFA', date: '٢٨ يونيو ٢٠٢٦', amount: '21,000', type: _TransactionType.commission),
    _Transaction(productName: 'مرآة نحاسية منقوشة', date: '١٥ يونيو ٢٠٢٦', amount: '135,000', type: _TransactionType.income),
    _Transaction(productName: 'عمولة AL-HIRFA', date: '١٥ يونيو ٢٠٢٦', amount: '15,000', type: _TransactionType.commission),
  ];

  void _showWithdrawSheet(BuildContext context) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('طلب سحب', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text('المبلغ المطلوب سحبه', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'مثال: 200,000',
                  hintStyle: TextStyle(color: AppColors.subText),
                  filled: true,
                  fillColor: AppColors.background,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                ),
              ),
              const SizedBox(height: 16),
              Text('IBAN المصرفي (من الملف الشخصي)', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.gold.withOpacity(0.2))),
                child: const Text('IQ98 IHRF •••• •••• 4821', style: TextStyle(color: AppColors.subText)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تأكيد السحب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
          automaticallyImplyLeading: false,
          title: const Text('محفظتي', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBalanceCard(context),
            const SizedBox(height: 16),
            _buildStatsRow(),
            const SizedBox(height: 24),
            const Text('سجل المعاملات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ..._transactions.map(_buildTransactionTile),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFF8B6B1F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الرصيد المتاح', style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          const Text('٨٥٠,٠٠٠ د.ع', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: AppColors.gold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => _showWithdrawSheet(context),
            child: const Text('طلب سحب', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('إجمالي المبيعات', '١,٢٥٠,٠٠٠ د.ع', AppColors.gold)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('عمولة AL-HIRFA', '١٢٥,٠٠٠ د.ع', Colors.redAccent)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('صافي الأرباح', '١,١٢٥,٠٠٠ د.ع', Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(value, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_Transaction transaction) {
    final isIncome = transaction.type == _TransactionType.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: isIncome ? Colors.green : Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(transaction.date, style: TextStyle(color: AppColors.subText, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${transaction.amount} د.ع',
            style: TextStyle(color: isIncome ? Colors.green : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
