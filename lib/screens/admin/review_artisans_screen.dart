import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum _ArtisanReviewStatus { pending, approved, rejected }

class _PendingArtisan {
  final String name;
  final String city;
  final String craft;
  final int experienceYears;
  final int sampleCount;
  _ArtisanReviewStatus status;
  _PendingArtisan({required this.name, required this.city, required this.craft, required this.experienceYears, required this.sampleCount, this.status = _ArtisanReviewStatus.pending});
}

/// مراجعة طلبات الحرفيين الجدد (ADMIN-4).
class ReviewArtisansScreen extends StatefulWidget {
  const ReviewArtisansScreen({super.key});
  @override
  State<ReviewArtisansScreen> createState() => _ReviewArtisansScreenState();
}

class _ReviewArtisansScreenState extends State<ReviewArtisansScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  final List<_PendingArtisan> _artisans = [
    _PendingArtisan(name: 'كريم عبد الرزاق', city: 'بغداد', craft: 'نحاسيات', experienceYears: 15, sampleCount: 10),
    _PendingArtisan(name: 'هدى سالم', city: 'النجف', craft: 'نسيج حرير', experienceYears: 8, sampleCount: 6),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_PendingArtisan> _for(_ArtisanReviewStatus status) => _artisans.where((a) => a.status == status).toList();

  void _approve(_PendingArtisan artisan) {
    setState(() => artisan.status = _ArtisanReviewStatus.approved);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تمت الموافقة على ${artisan.name} وتفعيل حسابه')));
  }

  void _reject(_PendingArtisan artisan) {
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
            decoration: InputDecoration(hintText: 'سبب الرفض', hintStyle: TextStyle(color: AppColors.subText), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4)))),
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
                setState(() => artisan.status = _ArtisanReviewStatus.rejected);
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
            _buildList(_for(_ArtisanReviewStatus.pending), showActions: true),
            _buildList(_for(_ArtisanReviewStatus.approved), showActions: false),
            _buildList(_for(_ArtisanReviewStatus.rejected), showActions: false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_PendingArtisan> artisans, {required bool showActions}) {
    if (artisans.isEmpty) return Center(child: Text('لا توجد طلبات', style: TextStyle(color: AppColors.subText)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: artisans.length,
      itemBuilder: (context, i) => _buildCard(artisans[i], showActions: showActions),
    );
  }

  Widget _buildCard(_PendingArtisan artisan, {required bool showActions}) {
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
                    Text('${artisan.city} • ${artisan.craft}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                    Text('${artisan.experienceYears} سنوات خبرة', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  ],
                ),
              ),
              if (artisan.status == _ArtisanReviewStatus.pending)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text('PENDING', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 6, mainAxisSpacing: 6),
            itemCount: 4,
            itemBuilder: (context, i) => Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: const LinearGradient(colors: [Color(0xFF2A1A08), Color(0xFF3A2A10)])),
              child: i == 3
                  ? Center(child: Text('+${artisan.sampleCount - 3}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)))
                  : const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
            ),
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
            const SizedBox(height: 4),
            TextButton(onPressed: () {}, child: const Text('عرض الملف الكامل', style: TextStyle(color: AppColors.gold))),
          ],
        ],
      ),
    );
  }
}
