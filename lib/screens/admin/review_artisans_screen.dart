import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../services/admin_service.dart';

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// مراجعة طلبات الحرفيين الجدد (ADMIN-4).
class ReviewArtisansScreen extends StatefulWidget {
  const ReviewArtisansScreen({super.key});
  @override
  State<ReviewArtisansScreen> createState() => _ReviewArtisansScreenState();
}

class _ReviewArtisansScreenState extends State<ReviewArtisansScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _approve(UserModel artisan) async {
    await AdminService.instance.approveArtisan(artisan.uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت الموافقة على ${artisan.name} وتفعيل حسابه')));
  }

  void _reject(UserModel artisan) {
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
                await AdminService.instance.rejectArtisan(artisan.uid, reason);
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
          title: const Text('مراجعة طلبات الحرفيين الجدد', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
          iconTheme: const IconThemeData(color: AppColors.gold),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'قيد المراجعة'), Tab(text: 'موافق عليه'), Tab(text: 'مرفوض')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildStreamList('pending', showActions: true),
            _buildStreamList('approved', showActions: false),
            _buildStreamList('rejected', showActions: false),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamList(String approvalStatus, {required bool showActions}) {
    return StreamBuilder<List<UserModel>>(
      stream: AdminService.instance.getArtisansByApprovalStatus(approvalStatus),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('تعذّر تحميل الطلبات:\n${snapshot.error}', textAlign: TextAlign.center, style: TextStyle(color: AppColors.subText, fontSize: 12)),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }
        final artisans = snapshot.data!..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (artisans.isEmpty) return Center(child: Text('لا توجد طلبات', style: TextStyle(color: AppColors.subText)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: artisans.length,
          itemBuilder: (context, i) => _buildCard(artisans[i], showActions: showActions),
        );
      },
    );
  }

  Widget _buildCard(UserModel artisan, {required bool showActions}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 26, backgroundColor: AppColors.gold.withOpacity(0.2), child: const Icon(Icons.person, color: AppColors.gold)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(artisan.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${artisan.city} • ${artisan.phone}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                    Text('تاريخ التسجيل: ${_formatDate(artisan.createdAt)}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  ],
                ),
              ),
              if (artisan.approvalStatus == 'pending')
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('PENDING', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () => _approve(artisan),
                child: const Text('موافقة', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: () => _reject(artisan),
                child: const Text('رفض', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
