import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum _AccountStatus { active, suspended, banned }

class _AdminUser {
  final String name;
  final String subtitle;
  final _AccountStatus status;
  final List<String> violations;
  const _AdminUser({required this.name, required this.subtitle, required this.status, this.violations = const []});
}

/// إدارة حسابات المستخدمين (حرفيون/مشترون/شركات شحن) — ADMIN-3.
class AdminAccountsScreen extends StatefulWidget {
  const AdminAccountsScreen({super.key});
  @override
  State<AdminAccountsScreen> createState() => _AdminAccountsScreenState();
}

class _AdminAccountsScreenState extends State<AdminAccountsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);
  String _statusFilter = 'الكل';
  final _searchController = TextEditingController();

  static const _artisans = [
    _AdminUser(name: 'أبو مصطفى', subtitle: 'نحاسيات — بغداد', status: _AccountStatus.active, violations: ['رفض طلب بدون سبب — ١٠ يونيو']),
    _AdminUser(name: 'زينب كريم', subtitle: 'فخار وخزف — النجف', status: _AccountStatus.suspended, violations: ['3 رفضات متتالية — ٢٥ يونيو', 'وصف غير دقيق — ١٠ يونيو']),
  ];
  static const _buyers = [
    _AdminUser(name: 'سارة العبيدي', subtitle: 'sara.alobaidi@example.com', status: _AccountStatus.active),
    _AdminUser(name: 'محمد الكناني', subtitle: 'm.kinani@example.com', status: _AccountStatus.banned, violations: ['احتيال مالي مؤكد — ١٥ مايو']),
  ];
  static const _shippingCompanies = [
    _AdminUser(name: 'شركة بغداد السريعة للشحن', subtitle: 'بغداد، النجف، كربلاء', status: _AccountStatus.active),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_AdminUser> _filter(List<_AdminUser> users) {
    return users.where((u) {
      if (_statusFilter != 'الكل') {
        final matches = switch (_statusFilter) {
          'نشط' => u.status == _AccountStatus.active,
          'معلق' => u.status == _AccountStatus.suspended,
          'محظور' => u.status == _AccountStatus.banned,
          _ => true,
        };
        if (!matches) return false;
      }
      if (_searchController.text.isNotEmpty && !u.name.contains(_searchController.text)) return false;
      return true;
    }).toList();
  }

  void _showActionSheet(_AdminUser user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: const Icon(Icons.warning_amber_outlined, color: Colors.amber), title: const Text('تحذير', style: TextStyle(color: AppColors.text)), onTap: () => Navigator.pop(sheetContext)),
              ListTile(leading: const Icon(Icons.pause_circle_outline, color: Colors.orange), title: const Text('تعليق الحساب', style: TextStyle(color: AppColors.text)), onTap: () => Navigator.pop(sheetContext)),
              ListTile(leading: const Icon(Icons.block, color: Colors.redAccent), title: const Text('حظر نهائي', style: TextStyle(color: AppColors.text)), onTap: () => Navigator.pop(sheetContext)),
              if (user.status == _AccountStatus.suspended)
                ListTile(leading: const Icon(Icons.check_circle_outline, color: Colors.green), title: const Text('رفع التعليق', style: TextStyle(color: AppColors.text)), onTap: () => Navigator.pop(sheetContext)),
            ],
          ),
        ),
      ),
    );
  }

  void _showViolations(_AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('سجل مخالفات ${user.name}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
          content: user.violations.isEmpty
              ? Text('لا توجد مخالفات مسجّلة.', style: TextStyle(color: AppColors.subText))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: user.violations.map((v) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• $v', style: TextStyle(color: AppColors.subText, fontSize: 13)))).toList(),
                ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق', style: TextStyle(color: AppColors.gold))),
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
          title: const Text('إدارة الحسابات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.subText,
            tabs: const [Tab(text: 'الحرفيون'), Tab(text: 'المشترون'), Tab(text: 'شركات الشحن')],
          ),
        ),
        body: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_filter(_artisans)),
                  _buildList(_filter(_buyers)),
                  _buildList(_filter(_shippingCompanies)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو البريد',
                hintStyle: TextStyle(color: AppColors.subText, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 18),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _statusFilter,
            dropdownColor: AppColors.card,
            style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
            underline: const SizedBox.shrink(),
            items: ['الكل', 'نشط', 'معلق', 'محظور'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (value) => setState(() => _statusFilter = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<_AdminUser> users) {
    if (users.isEmpty) return Center(child: Text('لا يوجد مستخدمون', style: TextStyle(color: AppColors.subText)));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: users.length,
      itemBuilder: (context, i) => _buildUserCard(users[i]),
    );
  }

  Widget _buildUserCard(_AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: () => _showViolations(user),
        child: Row(
          children: [
            CircleAvatar(radius: 25, backgroundColor: AppColors.gold.withOpacity(0.2), child: const Icon(Icons.person, color: AppColors.gold)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(user.subtitle, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                ],
              ),
            ),
            _buildStatusChip(user.status),
            IconButton(icon: const Icon(Icons.more_vert, color: AppColors.subText), onPressed: () => _showActionSheet(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(_AccountStatus status) {
    late final Color color;
    late final String label;
    switch (status) {
      case _AccountStatus.active:
        color = Colors.green;
        label = 'نشط';
        break;
      case _AccountStatus.suspended:
        color = Colors.orange;
        label = 'معلق';
        break;
      case _AccountStatus.banned:
        color = Colors.redAccent;
        label = 'محظور';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
