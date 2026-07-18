import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/settlement_model.dart';
import '../../models/user_model.dart';
import '../../models/withdrawal_request_model.dart';
import '../../services/admin_service.dart';
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

/// التسويات المالية الأسبوعية (ADMIN-7).
class AdminFinancialsScreen extends StatefulWidget {
  const AdminFinancialsScreen({super.key});
  @override
  State<AdminFinancialsScreen> createState() => _AdminFinancialsScreenState();
}

class _AdminFinancialsScreenState extends State<AdminFinancialsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmShippingSettlement(String shippingUid) async {
    final settlement = await WalletService.instance.calculateSettlement(shippingUid);
    await WalletService.instance.confirmSettlement(settlement.id);
    if (mounted) setState(() {});
  }

  Future<void> _markShippingSettlementLate(String shippingUid) async {
    final settlement = await WalletService.instance.calculateSettlement(shippingUid);
    await WalletService.instance.applyLatePenalty(settlement.id);
    if (mounted) setState(() {});
  }

  void _rejectWithdrawal(WithdrawalRequestModel withdrawal) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('رفض طلب السحب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(hintText: 'السبب (مثلاً: IBAN غير صحيح)', hintStyle: TextStyle(color: AppColors.subText), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تراجع', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                await WalletService.instance.rejectWithdrawal(withdrawal.id, reason);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('تأكيد الرفض', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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
          title: const Text('التسويات المالية', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder(
                future: AdminService.instance.getMonthlyRevenueBreakdown(),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF8B6B1F), AppColors.gold])),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('إجمالي الإيرادات هذا الشهر', style: TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text('${_formatPrice(data?.total ?? 0)} د.ع', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _miniStat('عمولة المنتجات', _formatPrice(data?.productCommission ?? 0))),
                          Expanded(child: _miniStat('عمولة الشحن', _formatPrice(data?.shippingCommission ?? 0))),
                        ]),
                      ],
                    ),
                  );
                },
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.gold,
              labelColor: AppColors.gold,
              unselectedLabelColor: AppColors.subText,
              tabs: const [Tab(text: 'شركات الشحن'), Tab(text: 'طلبات سحب الحرفيين')],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShippingSettlements(),
                  _buildWithdrawalRequests(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value د.ع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ],
    );
  }

  Widget _buildShippingSettlements() {
    return StreamBuilder<List<UserModel>>(
      stream: AdminService.instance.getUsersByRole('shipping'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        final companies = snapshot.data!.where((c) => c.approvalStatus == 'approved' && c.isActive).toList();
        if (companies.isEmpty) return Center(child: Text('لا توجد شركات شحن نشطة', style: TextStyle(color: AppColors.subText)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: companies.length,
          itemBuilder: (context, i) {
            final company = companies[i];
            return FutureBuilder<SettlementModel>(
              future: WalletService.instance.previewCurrentWeekSettlement(company.uid),
              builder: (context, settlementSnapshot) {
                final settlement = settlementSnapshot.data;
                final due = settlement?.platformDue ?? 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(company.companyName.isNotEmpty ? company.companyName : company.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('${settlement?.deliveriesCount ?? 0} توصيلة هذا الأسبوع', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${_formatPrice(due)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          if (due > 0)
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              alignment: WrapAlignment.end,
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                  onPressed: () => _confirmShippingSettlement(company.uid),
                                  child: const Text('تأكيد الاستلام', style: TextStyle(color: AppColors.gold, fontSize: 11)),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                  onPressed: () => _markShippingSettlementLate(company.uid),
                                  child: const Text('تسجيل تأخر السداد', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                                ),
                              ],
                            )
                          else
                            Text('لا يوجد مستحق', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWithdrawalRequests() {
    return StreamBuilder<List<WithdrawalRequestModel>>(
      stream: WalletService.instance.getWithdrawalRequests(status: 'pending'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        final withdrawals = snapshot.data!;
        if (withdrawals.isEmpty) return Center(child: Text('لا توجد طلبات سحب معلَّقة', style: TextStyle(color: AppColors.subText)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: withdrawals.length,
          itemBuilder: (context, i) {
            final withdrawal = withdrawals[i];
            return FutureBuilder<UserModel?>(
              future: AdminService.instance.getUserById(withdrawal.artisanUid),
              builder: (context, userSnapshot) {
                final artisan = userSnapshot.data;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(artisan?.name ?? '...', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('IBAN: ${withdrawal.iban}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${_formatPrice(withdrawal.amount)} د.ع', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                onPressed: () => _rejectWithdrawal(withdrawal),
                                child: const Text('رفض', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                onPressed: () => WalletService.instance.confirmWithdrawal(withdrawal.id),
                                child: const Text('تأكيد الصرف', style: TextStyle(color: AppColors.gold, fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
