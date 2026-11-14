import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../core/settings/app_prefs.dart';
import '../../core/utils/error_handler.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';

String _fmt(int value) {
  final str = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}

String _date(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

/// ملخّص حساب حرفي واحد: منتجاته، مبيعاته، والعمولة المستحقة والمسدَّدة.
/// كل الأرقام مشتقّة من الطلبات والمنتجات مباشرة (لا حقول مجمَّعة مخزّنة).
class ArtisanLedger {
  final UserModel artisan;
  final List<ProductModel> products;
  final List<OrderModel> orders;

  ArtisanLedger(this.artisan, this.products, this.orders);

  int get activeProducts => products.where((p) => p.status == 'active').length;
  int get pendingProducts => products.where((p) => p.status == 'pending').length;
  int get visibleProducts => products.where((p) => p.status != 'deleted').length;

  List<OrderModel> get delivered => orders.where((o) => o.status == 'delivered').toList();
  List<OrderModel> get inProgress => orders.where((o) => !const {'delivered', 'cancelled', 'disputed'}.contains(o.status)).toList();

  int get salesTotal => delivered.fold(0, (a, o) => a + o.price);
  /// عمولة طلبات مُسلَّمة لم تُسدَّد بعد — مستحقة فعلاً.
  int get owed => delivered.where((o) => !o.commissionPaid).fold(0, (a, o) => a + o.platformFee);
  /// عمولة طلبات لم تُسلَّم بعد — تقديرية.
  int get pending => inProgress.fold(0, (a, o) => a + o.platformFee);
  /// ما سدّده الحرفي فعلاً.
  int get paid => delivered.where((o) => o.commissionPaid).fold(0, (a, o) => a + o.platformFee);
  List<String> get owedOrderIds => delivered.where((o) => !o.commissionPaid && o.platformFee > 0).map((o) => o.id).toList();
}

/// سجلّ الحرفيين للإدارة: كل حرفي، منتجاته، مبيعاته، وما عليه من عمولة وما سدّده.
class AdminArtisansLedgerScreen extends StatefulWidget {
  const AdminArtisansLedgerScreen({super.key});

  @override
  State<AdminArtisansLedgerScreen> createState() => _AdminArtisansLedgerScreenState();
}

class _AdminArtisansLedgerScreenState extends State<AdminArtisansLedgerScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _sort = 'owed'; // owed / sales / name

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArtisanLedger> _build(List<UserModel> artisans, List<ProductModel> products, List<OrderModel> orders) {
    final ledgers = artisans
        .where((a) => !a.deleted)
        .map((a) => ArtisanLedger(
              a,
              products.where((p) => p.artisanUid == a.uid).toList(),
              orders.where((o) => o.artisanUid == a.uid).toList(),
            ))
        .where((l) => _query.isEmpty || l.artisan.name.toLowerCase().contains(_query) || l.artisan.email.toLowerCase().contains(_query) || l.artisan.city.contains(_query))
        .toList();
    switch (_sort) {
      case 'sales':
        ledgers.sort((a, b) => b.salesTotal.compareTo(a.salesTotal));
      case 'name':
        ledgers.sort((a, b) => a.artisan.name.compareTo(b.artisan.name));
      default:
        ledgers.sort((a, b) => b.owed != a.owed ? b.owed.compareTo(a.owed) : b.salesTotal.compareTo(a.salesTotal));
    }
    return ledgers;
  }

  Widget _totalsBar(List<ArtisanLedger> all) {
    final owed = all.fold(0, (a, l) => a + l.owed);
    final paid = all.fold(0, (a, l) => a + l.paid);
    final sales = all.fold(0, (a, l) => a + l.salesTotal);
    Widget cell(String label, int v, Color c) => Expanded(
          child: Column(
            children: [
              Text(_fmt(v), style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 11)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Row(
        children: [
          cell(tr('مبيعات مُسلَّمة', 'Delivered sales'), sales, AppColors.text),
          cell(tr('عمولة مستحقة', 'Commission owed'), owed, Colors.redAccent),
          cell(tr('عمولة مسدَّدة', 'Commission paid'), paid, Colors.green),
        ],
      ),
    );
  }

  Widget _card(ArtisanLedger l) {
    final a = l.artisan;
    final status = !a.isActive
        ? (a.banned ? tr('محظور', 'Banned') : tr('موقوف', 'Suspended'))
        : a.approvalStatus == 'pending'
            ? tr('بانتظار الموافقة', 'Pending approval')
            : null;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminArtisanLedgerDetailScreen(artisanUid: a.uid))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: l.owed > 0 ? Colors.redAccent.withOpacity(0.5) : AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.gold.withOpacity(0.2),
                  child: Text(a.name.isNotEmpty ? a.name.characters.first : '?', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.name, style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(a.city.isEmpty ? a.email : '${a.city} · ${a.email}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                    ],
                  ),
                ),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: Text(status, style: const TextStyle(color: Colors.orange, fontSize: 11)),
                  ),
                Icon(Icons.chevron_left, color: AppColors.subText),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _stat(tr('منتجات نشطة', 'Active'), '${l.activeProducts}/${l.visibleProducts}'),
                _stat(tr('طلبات مُسلَّمة', 'Delivered'), '${l.delivered.length}'),
                _stat(tr('المبيعات', 'Sales'), _fmt(l.salesTotal)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _stat(tr('مستحق عليه', 'Owes'), _fmt(l.owed), color: l.owed > 0 ? Colors.redAccent : null),
                _stat(tr('سدّد', 'Paid'), _fmt(l.paid), color: l.paid > 0 ? Colors.green : null),
                _stat(tr('تقديري (قيد التنفيذ)', 'Pending (in progress)'), _fmt(l.pending)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color ?? AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: TextStyle(color: AppColors.subText, fontSize: 10)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          iconTheme: IconThemeData(color: AppColors.gold),
          title: Text(tr('سجلّ الحرفيين', 'Artisans ledger'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.sort, color: AppColors.gold),
              color: AppColors.card,
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'owed', child: Text(tr('الأعلى عمولة مستحقة', 'Most commission owed'), style: TextStyle(color: AppColors.text))),
                PopupMenuItem(value: 'sales', child: Text(tr('الأعلى مبيعاً', 'Top sales'), style: TextStyle(color: AppColors.text))),
                PopupMenuItem(value: 'name', child: Text(tr('حسب الاسم', 'By name'), style: TextStyle(color: AppColors.text))),
              ],
            ),
          ],
        ),
        body: StreamBuilder<List<UserModel>>(
          stream: AdminService.instance.getUsersByRole('artisan'),
          builder: (context, artisansSnap) => StreamBuilder<List<ProductModel>>(
            stream: ProductService.instance.getAllProducts(),
            builder: (context, productsSnap) => StreamBuilder<List<OrderModel>>(
              stream: OrderService.instance.getAllOrders(),
              builder: (context, ordersSnap) {
                final error = artisansSnap.error ?? productsSnap.error ?? ordersSnap.error;
                if (error != null) {
                  return Center(child: Text(AppError.getFirebaseError(error), textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText)));
                }
                if (!artisansSnap.hasData || !productsSnap.hasData || !ordersSnap.hasData) {
                  return Center(child: CircularProgressIndicator(color: AppColors.gold));
                }
                final all = _build(artisansSnap.data!, productsSnap.data!, ordersSnap.data!);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: AppColors.text),
                        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                        decoration: InputDecoration(
                          hintText: tr('ابحث بالاسم أو البريد أو المدينة', 'Search by name, email or city'),
                          hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: AppColors.gold),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold)),
                        ),
                      ),
                    ),
                    _totalsBar(all),
                    Expanded(
                      child: all.isEmpty
                          ? Center(child: Text(tr('لا يوجد حرفيون', 'No artisans'), style: TextStyle(color: AppColors.subText)))
                          : ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: all.map(_card).toList()),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// تفاصيل حرفي واحد: بياناته، منتجاته، طلباته، وسجل تسديد العمولة.
class AdminArtisanLedgerDetailScreen extends StatelessWidget {
  final String artisanUid;
  const AdminArtisanLedgerDetailScreen({super.key, required this.artisanUid});

  Future<void> _recordPayment(BuildContext context, ArtisanLedger l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: AppPrefs.dir,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(tr('تسجيل استلام العمولة', 'Record commission payment'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text(
            tr('أكِّد فقط بعد استلام ${_fmt(l.owed)} د.ع نقداً من ${l.artisan.name}. سيُعلَّم ${l.owedOrderIds.length} طلب كمسدَّد.',
                'Confirm only after receiving ${_fmt(l.owed)} IQD in cash from ${l.artisan.name}. ${l.owedOrderIds.length} order(s) will be marked as paid.'),
            style: TextStyle(color: AppColors.subText, height: 1.6),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('إلغاء', 'Cancel'), style: TextStyle(color: AppColors.subText))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('تأكيد الاستلام', 'Confirm receipt')),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    try {
      await OrderService.instance.markArtisanCommissionPaid(l.artisan.uid, l.owedOrderIds);
      if (context.mounted) AppError.showSnackbar(context, tr('تم تسجيل التسديد', 'Payment recorded'), isError: false);
    } catch (e) {
      if (context.mounted) AppError.showSnackbar(context, AppError.getFirebaseError(e));
    }
  }

  String _statusLabel(String s) => switch (s) {
        'active' => tr('نشط', 'Active'),
        'pending' => tr('بانتظار المراجعة', 'Pending'),
        'rejected' => tr('مرفوض', 'Rejected'),
        'suspended' => tr('موقوف', 'Suspended'),
        'deleted' => tr('محذوف', 'Deleted'),
        'delivered' => tr('مُسلَّم', 'Delivered'),
        'cancelled' => tr('ملغي', 'Cancelled'),
        'disputed' => tr('نزاع', 'Disputed'),
        'seller_approved' => tr('مقبول — قيد التوصيل', 'Accepted — delivering'),
        _ => tr('قيد التنفيذ', 'In progress'),
      };

  Widget _summary(BuildContext context, ArtisanLedger l, String phone) {
    Widget row(String label, String value, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(color: AppColors.subText, fontSize: 13))),
              Text(value, style: TextStyle(color: color ?? AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.artisan.name, style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text([l.artisan.city, l.artisan.email].where((e) => e.isNotEmpty).join(' · '), style: TextStyle(color: AppColors.subText, fontSize: 12)),
          if (phone.isNotEmpty)
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: AlignmentDirectional.centerStart),
              onPressed: () => launchUrl(Uri.parse('tel:$phone')),
              icon: Icon(Icons.phone, color: AppColors.gold, size: 18),
              label: Text(phone, textDirection: TextDirection.ltr, style: TextStyle(color: AppColors.gold)),
            ),
          Divider(color: AppColors.subText.withOpacity(0.2)),
          row(tr('المنتجات (نشطة / الكل)', 'Products (active / all)'), '${l.activeProducts} / ${l.visibleProducts}'),
          row(tr('طلبات مُسلَّمة', 'Delivered orders'), '${l.delivered.length}'),
          row(tr('طلبات قيد التنفيذ', 'Orders in progress'), '${l.inProgress.length}'),
          row(tr('إجمالي المبيعات المُسلَّمة', 'Total delivered sales'), '${_fmt(l.salesTotal)} ${tr('د.ع', 'IQD')}'),
          Divider(color: AppColors.subText.withOpacity(0.2)),
          row(tr('عمولة مستحقة (مؤكَّدة)', 'Commission owed (confirmed)'), '${_fmt(l.owed)} ${tr('د.ع', 'IQD')}', color: l.owed > 0 ? Colors.redAccent : null),
          row(tr('عمولة تقديرية (طلبات لم تُسلَّم)', 'Estimated (undelivered orders)'), '${_fmt(l.pending)} ${tr('د.ع', 'IQD')}'),
          row(tr('عمولة مسدَّدة', 'Commission paid'), '${_fmt(l.paid)} ${tr('د.ع', 'IQD')}', color: l.paid > 0 ? Colors.green : null),
          if (l.owed > 0) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () => _recordPayment(context, l),
                icon: const Icon(Icons.payments_outlined),
                label: Text(tr('تسجيل استلام ${_fmt(l.owed)} د.ع', 'Record receipt of ${_fmt(l.owed)} IQD'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _productsTab(ArtisanLedger l) {
    final items = l.products.where((p) => p.status != 'deleted').toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (items.isEmpty) return Center(child: Text(tr('لا توجد منتجات', 'No products'), style: TextStyle(color: AppColors.subText)));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items
          .map((p) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: p.images.isNotEmpty
                      ? Image.network(p.images.first, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 48, height: 48))
                      : Container(width: 48, height: 48, color: AppColors.card),
                ),
                title: Text(p.name, style: TextStyle(color: AppColors.text, fontSize: 14)),
                subtitle: Text(
                  '${_fmt(p.price)} ${tr('د.ع', 'IQD')} · ${tr('الكمية', 'Qty')}: ${p.stock ?? '—'} · ${tr('بيع', 'Sold')}: ${p.salesCount}',
                  style: TextStyle(color: AppColors.subText, fontSize: 11),
                ),
                trailing: Text(_statusLabel(p.status), style: TextStyle(color: p.status == 'active' ? Colors.green : Colors.orange, fontSize: 11)),
              ))
          .toList(),
    );
  }

  Widget _ordersTab(ArtisanLedger l) {
    final items = l.orders.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (items.isEmpty) return Center(child: Text(tr('لا توجد طلبات', 'No orders'), style: TextStyle(color: AppColors.subText)));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items.map((o) {
        final commissionText = o.status != 'delivered'
            ? ''
            : o.commissionPaid
                ? tr('العمولة مسدَّدة', 'Commission paid')
                : tr('العمولة غير مسدَّدة', 'Commission unpaid');
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${o.productName} · ${o.orderNumber}', style: TextStyle(color: AppColors.text, fontSize: 13)),
          subtitle: Text(
            '${_date(o.createdAt)} · ${_fmt(o.price)} ${tr('د.ع', 'IQD')} · ${tr('عمولة', 'Fee')} ${_fmt(o.platformFee)}${commissionText.isEmpty ? '' : ' · $commissionText'}',
            style: TextStyle(color: AppColors.subText, fontSize: 11),
          ),
          trailing: Text(_statusLabel(o.status), style: TextStyle(color: o.status == 'delivered' ? Colors.green : AppColors.subText, fontSize: 11)),
        );
      }).toList(),
    );
  }

  Widget _paymentsTab(ArtisanLedger l) {
    final paid = l.delivered.where((o) => o.commissionPaid).toList();
    if (paid.isEmpty) return Center(child: Text(tr('لم يُسجَّل أي تسديد بعد', 'No payments recorded yet'), style: TextStyle(color: AppColors.subText)));
    // تجميع حسب يوم التسجيل — كل ضغطة "تسجيل استلام" تظهر كدفعة واحدة.
    final byDay = <String, List<OrderModel>>{};
    for (final o in paid) {
      byDay.putIfAbsent(o.commissionPaidAt != null ? _date(o.commissionPaidAt!) : tr('قبل تفعيل السجل', 'Before history'), () => []).add(o);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: days.map((d) {
        final list = byDay[d]!;
        final total = list.fold(0, (a, o) => a + o.platformFee);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text('${_fmt(total)} ${tr('د.ع', 'IQD')}', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          subtitle: Text('$d · ${tr('${list.length} طلب', '${list.length} order(s)')}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppPrefs.dir,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            iconTheme: IconThemeData(color: AppColors.gold),
            title: Text(tr('حساب الحرفي', 'Artisan account'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          ),
          body: FutureBuilder<UserModel?>(
            future: AdminService.instance.getUserById(artisanUid),
            builder: (context, userSnap) {
              if (userSnap.hasError) return Center(child: Text(AppError.getFirebaseError(userSnap.error!), style: TextStyle(color: AppColors.subText)));
              if (!userSnap.hasData) return Center(child: CircularProgressIndicator(color: AppColors.gold));
              final artisan = userSnap.data!;
              return StreamBuilder<List<ProductModel>>(
                stream: ProductService.instance.getArtisanProducts(artisanUid),
                builder: (context, productsSnap) => StreamBuilder<List<OrderModel>>(
                  stream: OrderService.instance.getArtisanOrders(artisanUid),
                  builder: (context, ordersSnap) {
                    final error = productsSnap.error ?? ordersSnap.error;
                    if (error != null) return Center(child: Text(AppError.getFirebaseError(error), style: TextStyle(color: AppColors.subText)));
                    if (!productsSnap.hasData || !ordersSnap.hasData) return Center(child: CircularProgressIndicator(color: AppColors.gold));
                    final l = ArtisanLedger(artisan, productsSnap.data!, ordersSnap.data!);
                    return NestedScrollView(
                      headerSliverBuilder: (context, _) => [
                        SliverToBoxAdapter(child: _summary(context, l, artisan.phone)),
                        SliverToBoxAdapter(
                          child: TabBar(
                            labelColor: AppColors.gold,
                            unselectedLabelColor: AppColors.subText,
                            indicatorColor: AppColors.gold,
                            tabs: [
                              Tab(text: tr('المنتجات (${l.visibleProducts})', 'Products (${l.visibleProducts})')),
                              Tab(text: tr('الطلبات (${l.orders.length})', 'Orders (${l.orders.length})')),
                              Tab(text: tr('التسديدات', 'Payments')),
                            ],
                          ),
                        ),
                      ],
                      body: TabBarView(children: [_productsTab(l), _ordersTab(l), _paymentsTab(l)]),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
