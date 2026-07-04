import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/artisan_order.dart';
import 'artisan_order_detail_screen.dart';

class ArtisanOrdersScreen extends StatefulWidget {
  const ArtisanOrdersScreen({super.key});
  @override
  State<ArtisanOrdersScreen> createState() => _ArtisanOrdersScreenState();
}

class _ArtisanOrdersScreenState extends State<ArtisanOrdersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  final List<ArtisanOrder> _orders = [
    ArtisanOrder(orderNumber: '#HRF-9821', date: '٣ يوليو ٢٠٢٦', productName: 'إناء نحاسي منقوش', price: '125,000', buyerName: 'سارة العبيدي', buyerPhone: '07701234567', province: 'بغداد', neighborhood: 'الكرادة', status: ArtisanOrderStatus.newOrder),
    ArtisanOrder(orderNumber: '#HRF-9815', date: '٢ يوليو ٢٠٢٦', productName: 'طبق نحاسي مزخرف', price: '90,000', buyerName: 'محمد الكناني', buyerPhone: '07709876543', province: 'البصرة', neighborhood: 'العشار', status: ArtisanOrderStatus.newOrder),
    ArtisanOrder(orderNumber: '#HRF-9788', date: '٢٨ يونيو ٢٠٢٦', productName: 'إبريق نحاسي بصري', price: '210,000', buyerName: 'نور الزهراوي', buyerPhone: '07715558888', province: 'النجف', neighborhood: 'حي السلام', status: ArtisanOrderStatus.inProgress, shippingCompany: 'شركة بغداد السريعة للشحن', shippingRepPhone: '07701112222'),
    ArtisanOrder(orderNumber: '#HRF-9750', date: '٢٥ يونيو ٢٠٢٦', productName: 'شمعدان نحاسي قديم', price: '65,000', buyerName: 'علي حسين', buyerPhone: '07733334444', province: 'أربيل', neighborhood: 'عنكاوا', status: ArtisanOrderStatus.inProgress),
    ArtisanOrder(orderNumber: '#HRF-9690', date: '١٥ يونيو ٢٠٢٦', productName: 'مرآة نحاسية منقوشة', price: '150,000', buyerName: 'زينب كريم', buyerPhone: '07745556666', province: 'كربلاء', neighborhood: 'باب بغداد', status: ArtisanOrderStatus.completed),
    ArtisanOrder(orderNumber: '#HRF-9611', date: '٢ يونيو ٢٠٢٦', productName: 'صينية نحاسية كبيرة', price: '180,000', buyerName: 'حسن عبود', buyerPhone: '07767778888', province: 'الموصل', neighborhood: 'الدواسة', status: ArtisanOrderStatus.rejected),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ArtisanOrder> _ordersFor(ArtisanOrderStatus status) => _orders.where((o) => o.status == status).toList();

  void _acceptOrder(ArtisanOrder order) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('قبول الطلب؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('بعد قبولك سيُرسل إشعار لشركات الشحن.', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                setState(() => order.status = ArtisanOrderStatus.inProgress);
                Navigator.pop(context);
              },
              child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _rejectOrder(ArtisanOrder order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('رفض الطلب', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: reasonController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'سبب الرفض',
              hintStyle: TextStyle(color: AppColors.subText),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text('تراجع', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                setState(() => order.status = ArtisanOrderStatus.rejected);
                Navigator.pop(context);
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
    final newOrdersCount = _ordersFor(ArtisanOrderStatus.newOrder).length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('الطلبات الواردة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'جديدة 🔴'), Tab(text: 'قيد التنفيذ 🟡'), Tab(text: 'مكتملة ✅'), Tab(text: 'مرفوضة ❌')],
          ),
        ),
        body: Column(
          children: [
            if (newOrdersCount > 0) _buildNewOrdersBanner(newOrdersCount),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersList(_ordersFor(ArtisanOrderStatus.newOrder)),
                  _buildOrdersList(_ordersFor(ArtisanOrderStatus.inProgress)),
                  _buildOrdersList(_ordersFor(ArtisanOrderStatus.completed)),
                  _buildOrdersList(_ordersFor(ArtisanOrderStatus.rejected)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrdersBanner(int count) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text('لديك $count طلبات جديدة بانتظار المراجعة', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<ArtisanOrder> orders) {
    if (orders.isEmpty) {
      return Center(child: Text('لا توجد طلبات', style: TextStyle(color: AppColors.subText)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildOrderCard(orders[i]),
    );
  }

  Widget _buildOrderCard(ArtisanOrder order) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArtisanOrderDetailScreen(order: order))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber, style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(order.date, style: TextStyle(color: AppColors.subText, fontSize: 11)),
              ],
            ),
            const Divider(color: Color(0xFF2A2A2A)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)]),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.gold, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('د.ع ${order.price}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(order.buyerName, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.subText, size: 13), const SizedBox(width: 4), Expanded(child: Text('${order.province} - ${order.neighborhood}', style: TextStyle(color: AppColors.subText, fontSize: 11)))]),
                      const SizedBox(height: 2),
                      Row(children: [const Icon(Icons.call_outlined, color: AppColors.subText, size: 13), const SizedBox(width: 4), Text(order.buyerPhone, style: TextStyle(color: AppColors.subText, fontSize: 11))]),
                    ],
                  ),
                ),
              ],
            ),
            if (order.status == ArtisanOrderStatus.newOrder) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _acceptOrder(order),
                  child: const Text('قبول الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _rejectOrder(order),
                  child: const Text('رفض الطلب', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            if (order.status == ArtisanOrderStatus.inProgress) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  order.shippingCompany != null ? 'جاري الشحن' : 'بانتظار الشحن',
                  style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              if (order.shippingCompany != null) ...[
                const SizedBox(height: 6),
                Text(order.shippingCompany!, style: TextStyle(color: AppColors.subText, fontSize: 12)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
