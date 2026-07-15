import 'package:flutter/material.dart';
import '../../core/constants/app_rules.dart';
import '../../core/constants/colors.dart';
import '../../models/order_model.dart';
import '../../models/settlement_model.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
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

/// إدارة شركات الشحن (ADMIN-5).
class AdminShippingScreen extends StatefulWidget {
  const AdminShippingScreen({super.key});
  @override
  State<AdminShippingScreen> createState() => _AdminShippingScreenState();
}

class _AdminShippingScreenState extends State<AdminShippingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _promptReject(UserModel company) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('رفض الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(hintText: 'سبب الرفض', hintStyle: TextStyle(color: AppColors.subText), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
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
                await AdminService.instance.rejectAccount(company.uid, reason);
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

  void _promptSuspend(UserModel company) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('تعليق الشركة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(hintText: 'السبب', hintStyle: TextStyle(color: AppColors.subText), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تراجع', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                await AdminService.instance.suspendUser(company.uid, reason);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('تأكيد التعليق', style: TextStyle(fontWeight: FontWeight.bold)),
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
          automaticallyImplyLeading: false,
          title: const Text('إدارة شركات الشحن', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'قيد المراجعة'), Tab(text: 'نشطة'), Tab(text: 'معلقة')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildList('pending'),
            _buildList('active'),
            _buildList('suspended'),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String tab) {
    return StreamBuilder<List<UserModel>>(
      stream: AdminService.instance.getUsersByRole('shipping'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('تعذّر تحميل الشركات', style: TextStyle(color: AppColors.subText)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }
        final companies = snapshot.data!.where((c) {
          return switch (tab) {
            'pending' => c.approvalStatus == 'pending',
            'active' => c.approvalStatus == 'approved' && c.isActive,
            'suspended' => c.approvalStatus == 'approved' && !c.isActive,
            _ => false,
          };
        }).toList();
        if (companies.isEmpty) return Center(child: Text('لا توجد شركات', style: TextStyle(color: AppColors.subText)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: companies.length,
          itemBuilder: (context, i) => _buildCard(companies[i]),
        );
      },
    );
  }

  Widget _buildCard(UserModel company) {
    final isPending = company.approvalStatus == 'pending';
    final isActive = company.approvalStatus == 'approved' && company.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(company.companyName.isNotEmpty ? company.companyName : company.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14))),
              _buildStatusChip(company),
            ],
          ),
          const SizedBox(height: 6),
          Text(company.provinces.isNotEmpty ? company.provinces.join('، ') : company.city, style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('سجل تجاري: ${company.registrationNumber.isNotEmpty ? company.registrationNumber : '—'}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          Text('مبلغ التأمين: ${_formatPrice(AppRules.securityDeposit)} د.ع', style: TextStyle(color: AppColors.subText, fontSize: 12)),
          if (isActive) ...[
            const SizedBox(height: 8),
            Divider(color: AppColors.subText.withOpacity(0.15)),
            StreamBuilder<List<OrderModel>>(
              stream: OrderService.instance.getShippingOrders(company.uid),
              builder: (context, orderSnapshot) {
                final now = DateTime.now();
                final delivered = (orderSnapshot.data ?? const []).where((o) => o.status == 'delivered').toList();
                final thisMonth = delivered.where((o) => (o.deliveredAt ?? o.createdAt).year == now.year && (o.deliveredAt ?? o.createdAt).month == now.month).length;
                return Text('التوصيلات هذا الشهر: $thisMonth', style: TextStyle(color: AppColors.subText, fontSize: 12));
              },
            ),
            const SizedBox(height: 4),
            FutureBuilder<SettlementModel>(
              future: WalletService.instance.previewCurrentWeekSettlement(company.uid),
              builder: (context, settlementSnapshot) {
                final due = settlementSnapshot.data?.platformDue ?? 0;
                return Row(children: [
                  Text('المستحق لـ AL-HIRFA هذا الأسبوع: ${_formatPrice(due)} د.ع — ', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  Text(due == 0 ? 'لا يوجد مستحق' : 'بانتظار التسوية', style: TextStyle(color: due == 0 ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                ]);
              },
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (isPending) ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => AdminService.instance.approveAccount(company.uid, roleLabel: 'شركة الشحن', message: 'تهانينا! تمت الموافقة على شركة الشحن، يمكنكم الآن تسجيل الدخول واستلام طلبات التوصيل'),
                    child: const Text('موافقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => _promptReject(company),
                    child: const Text('رفض', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ] else if (isActive) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => _promptSuspend(company),
                    child: const Text('تعليق', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => AdminService.instance.liftSuspension(company.uid),
                    child: const Text('رفع التعليق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(UserModel company) {
    late final Color color;
    late final String label;
    if (company.approvalStatus == 'pending') {
      color = AppColors.gold;
      label = 'قيد المراجعة';
    } else if (company.approvalStatus == 'rejected') {
      color = Colors.redAccent;
      label = 'مرفوضة';
    } else if (!company.isActive) {
      color = Colors.orange;
      label = 'معلقة';
    } else {
      color = Colors.green;
      label = 'نشطة';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
