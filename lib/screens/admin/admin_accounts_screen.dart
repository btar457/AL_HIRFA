import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../models/violation_model.dart';
import '../../services/admin_service.dart';

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
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

  static const _roles = ['artisan', 'customer', 'shipping'];

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _filter(List<UserModel> users) {
    return users.where((u) {
      if (_statusFilter != 'الكل') {
        final matches = switch (_statusFilter) {
          'نشط' => u.isActive,
          'معلق' => !u.isActive && !u.banned,
          'محظور' => u.banned,
          _ => true,
        };
        if (!matches) return false;
      }
      if (_searchController.text.isNotEmpty && !u.name.contains(_searchController.text) && !u.email.contains(_searchController.text)) return false;
      return true;
    }).toList();
  }

  void _showActionSheet(UserModel user) {
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
              ListTile(
                leading: const Icon(Icons.warning_amber_outlined, color: Colors.amber),
                title: const Text('تحذير', style: TextStyle(color: AppColors.text)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _promptReason(user, 'إرسال تحذير', (reason) => AdminService.instance.warnUser(user.uid, reason));
                },
              ),
              if (user.isActive)
                ListTile(
                  leading: const Icon(Icons.pause_circle_outline, color: Colors.orange),
                  title: const Text('تعليق الحساب', style: TextStyle(color: AppColors.text)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _promptReason(user, 'تعليق الحساب', (reason) => AdminService.instance.suspendUser(user.uid, reason));
                  },
                ),
              if (!user.banned)
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.redAccent),
                  title: const Text('حظر نهائي', style: TextStyle(color: AppColors.text)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _promptReason(user, 'حظر نهائي', (reason) => AdminService.instance.banUser(user.uid, reason));
                  },
                ),
              if (!user.isActive && !user.banned)
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: const Text('رفع التعليق', style: TextStyle(color: AppColors.text)),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await AdminService.instance.liftSuspension(user.uid);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفع التعليق عن ${user.name}')));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _promptReason(UserModel user, String title, Future<void> Function(String reason) action) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) return;
                await action(reason);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showViolations(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('سجل مخالفات ${user.name}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<List<ViolationModel>>(
              stream: AdminService.instance.getUserViolations(user.uid),
              builder: (context, snapshot) {
                final violations = snapshot.data ?? const [];
                if (violations.isEmpty) {
                  return Text('لا توجد مخالفات مسجّلة.', style: TextStyle(color: AppColors.subText));
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: violations.map((v) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• ${v.description} — ${_formatDate(v.createdAt)}', style: TextStyle(color: AppColors.subText, fontSize: 13)))).toList(),
                );
              },
            ),
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
                children: _roles.map(_buildRoleList).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleList(String role) {
    return StreamBuilder<List<UserModel>>(
      stream: AdminService.instance.getUsersByRole(role),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('تعذّر تحميل المستخدمين', style: TextStyle(color: AppColors.subText)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }
        final users = _filter(snapshot.data!);
        if (users.isEmpty) return Center(child: Text('لا يوجد مستخدمون', style: TextStyle(color: AppColors.subText)));
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: users.length,
          itemBuilder: (context, i) => _buildUserCard(users[i]),
        );
      },
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

  Widget _buildUserCard(UserModel user) {
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
                  Text(user.email, style: TextStyle(color: AppColors.subText, fontSize: 12)),
                  if (user.warningCount > 0) Text('${user.warningCount} إنذار', style: TextStyle(color: Colors.amber, fontSize: 11)),
                ],
              ),
            ),
            _buildStatusChip(user),
            IconButton(icon: const Icon(Icons.more_vert, color: AppColors.subText), onPressed: () => _showActionSheet(user)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(UserModel user) {
    final Color color;
    final String label;
    if (user.banned) {
      color = Colors.redAccent;
      label = 'محظور';
    } else if (!user.isActive) {
      color = Colors.orange;
      label = 'معلق';
    } else {
      color = Colors.green;
      label = 'نشط';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
