import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../models/wallet_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/wallet_service.dart';
import '../../core/settings/app_prefs.dart';

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
  const monthsAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final months = AppPrefs.isEnglish ? monthsEn : monthsAr;
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// سجل مبيعات الحرفي — معلوماتي بحت. قسم الشحن مغلق مؤقتاً والحرفي يستلم
/// كامل مبلغ كل طلب كاشاً من الزبون مباشرة عند التسليم (لا تحتجز المنصة أي
/// مبلغ له ولا "تُحرِّره" لاحقاً)، لذا لا يوجد هنا أي زر "طلب سحب" — عمولة
/// المنصة (5%) دَين على الحرفي هو من يسدّده، لا العكس (راجع
/// admin_commissions_owed_screen.dart). WalletService.requestWithdrawal
/// ودالة الإدارة confirmWithdrawal تبقيان في الكود لتسوية أي طلب سحب قديم
/// معلَّق من قبل هذا التغيير، دون نقطة دخول جديدة تُنشئ طلبات مشابهة.
class ArtisanWalletScreen extends StatelessWidget {
  const ArtisanWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final artisanUid = context.watch<AuthProvider>().currentUser?.uid;

    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: Text(tr('محفظتي', 'My wallet'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        ),
        body: artisanUid == null
            ? Center(child: Text(tr('سجّل الدخول لعرض محفظتك', 'Sign in to see your wallet'), style: TextStyle(color: AppColors.subText)))
            : StreamBuilder<WalletModel>(
                stream: WalletService.instance.getArtisanWallet(artisanUid),
                builder: (context, walletSnapshot) {
                  final wallet = walletSnapshot.data ?? const WalletModel();
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildBalanceCard(wallet),
                      const SizedBox(height: 24),
                      Text(tr('سجل المعاملات', 'Transactions'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      StreamBuilder<List<OrderModel>>(
                        stream: OrderService.instance.getArtisanOrders(artisanUid),
                        builder: (context, orderSnapshot) {
                          final delivered = (orderSnapshot.data ?? const []).where((o) => o.status == 'delivered').toList()
                            ..sort((a, b) => (b.deliveredAt ?? b.createdAt).compareTo(a.deliveredAt ?? a.createdAt));
                          if (delivered.isEmpty) {
                            return Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text(tr('لا توجد معاملات بعد', 'No transactions yet'), style: TextStyle(color: AppColors.subText))));
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

  Widget _buildBalanceCard(WalletModel wallet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [AppColors.gold, Color(0xFF8B6B1F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('إجمالي مبيعاتك المُسلَّمة', 'Total delivered sales'), style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          Text(tr('${_formatPrice(wallet.totalEarnings)} د.ع', '${_formatPrice(wallet.totalEarnings)} IQD'), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            tr('استلمتَ هذه المبالغ كاشاً من الزبائن مباشرة عند التسليم — لا رصيد تطلب سحبه من المنصة.', 'You received these amounts in cash from buyers on delivery — there\'s no balance to withdraw from the platform.'),
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, height: 18 / 11),
          ),
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
                Text(order.productName, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(_formatDate(order.deliveredAt ?? order.createdAt), style: TextStyle(color: AppColors.subText, fontSize: 11)),
              ],
            ),
          ),
          Text(tr('+ ${_formatPrice(order.artisanEarnings)} د.ع', '+ ${_formatPrice(order.artisanEarnings)} IQD'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
