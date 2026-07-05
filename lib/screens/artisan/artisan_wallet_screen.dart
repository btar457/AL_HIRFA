import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../models/wallet_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/wallet_service.dart';

String _formatPrice(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class ArtisanWalletScreen extends StatelessWidget {
  const ArtisanWalletScreen({super.key});

  void _showWithdrawSheet(BuildContext context, String artisanUid, int availableBalance) {
    final amountController = TextEditingController();
    final ibanController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('طلب سحب', style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('الرصيد المتاح للسحب: ${_formatPrice(availableBalance)} د.ع', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                const SizedBox(height: 20),
                Text('المبلغ المطلوب سحبه', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'مثال: 200000',
                    hintStyle: TextStyle(color: AppColors.subText),
                    filled: true,
                    fillColor: AppColors.background,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('الحساب المصرفي (IBAN)', style: TextStyle(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: ibanController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    hintText: 'IQ98 IHRF ....',
                    hintStyle: TextStyle(color: AppColors.subText),
                    filled: true,
                    fillColor: AppColors.background,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final amount = int.tryParse(amountController.text.trim()) ?? 0;
                            if (amount <= 0 || ibanController.text.trim().isEmpty) {
                              AppError.showSnackbar(sheetContext, 'أدخل مبلغاً صحيحاً وIBAN صالحاً');
                              return;
                            }
                            setSheetState(() => isSubmitting = true);
                            try {
                              await WalletService.instance.requestWithdrawal(artisanUid: artisanUid, amount: amount, iban: ibanController.text.trim());
                              if (!sheetContext.mounted) return;
                              Navigator.pop(sheetContext);
                              AppError.showSnackbar(context, 'تم إرسال طلب السحب بنجاح', isError: false);
                            } catch (e) {
                              setSheetState(() => isSubmitting = false);
                              if (!sheetContext.mounted) return;
                              AppError.showSnackbar(sheetContext, e.toString().replaceFirst('Exception: ', ''));
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Text('تأكيد السحب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artisanUid = context.watch<AuthProvider>().currentUser?.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('محفظتي', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: artisanUid == null
            ? Center(child: Text('سجّل الدخول لعرض محفظتك', style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<WalletModel>(
                stream: WalletService.instance.getArtisanWallet(artisanUid),
                builder: (context, walletSnapshot) {
                  final wallet = walletSnapshot.data ?? const WalletModel();
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildBalanceCard(context, artisanUid, wallet),
                      const SizedBox(height: 16),
                      _buildStatsRow(wallet),
                      const SizedBox(height: 24),
                      const Text('سجل المعاملات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      StreamBuilder<List<OrderModel>>(
                        stream: OrderService.instance.getArtisanOrders(artisanUid),
                        builder: (context, orderSnapshot) {
                          final delivered = (orderSnapshot.data ?? const []).where((o) => o.status == 'delivered').toList()
                            ..sort((a, b) => (b.deliveredAt ?? b.createdAt).compareTo(a.deliveredAt ?? a.createdAt));
                          if (delivered.isEmpty) {
                            return Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text('لا توجد معاملات بعد', style: TextStyle(color: AppColors.subText))));
                          }
                          return Column(children: delivered.map(_buildTransactionTile).toList());
                        },
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, String artisanUid, WalletModel wallet) {
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
          Text('${_formatPrice(wallet.availableBalance)} د.ع', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          if (wallet.pendingBalance > 0) ...[
            const SizedBox(height: 4),
            Text('${_formatPrice(wallet.pendingBalance)} د.ع قيد الاحتجاز (72 ساعة)', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: AppColors.gold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => _showWithdrawSheet(context, artisanUid, wallet.availableBalance),
            child: const Text('طلب سحب', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(WalletModel wallet) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('إجمالي الأرباح', '${_formatPrice(wallet.totalEarnings)} د.ع', AppColors.gold)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('متاح للسحب', '${_formatPrice(wallet.availableBalance)} د.ع', Colors.green)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard('قيد الاحتجاز', '${_formatPrice(wallet.pendingBalance)} د.ع', Colors.orange)),
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

  Widget _buildTransactionTile(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.arrow_upward, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(_formatDate(order.deliveredAt ?? order.createdAt), style: TextStyle(color: AppColors.subText, fontSize: 11)),
              ],
            ),
          ),
          Text('+ ${_formatPrice(order.artisanEarnings)} د.ع', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
