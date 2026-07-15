import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';

/// إرسال إشعارات جماعية وسجلها (ADMIN-9).
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});
  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  String _targetAudience = 'all';
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  static const _audiences = {
    'all': 'الكل',
    'customer': 'المشترون',
    'artisan': 'الحرفيون',
    'shipping': 'شركات الشحن',
  };

  Future<void> _send() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) return;
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('إرسال الإشعار؟', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Text('سيُرسل الإشعار إلى: ${_audiences[_targetAudience]}', style: TextStyle(color: AppColors.subText)),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                Navigator.pop(dialogContext);
                setState(() => _isSending = true);
                await NotificationService.instance.sendBulkNotification(targetRole: _targetAudience, title: _titleController.text.trim(), body: _bodyController.text.trim());
                _titleController.clear();
                _bodyController.clear();
                if (mounted) setState(() => _isSending = false);
              },
              child: const Text('إرسال', style: TextStyle(fontWeight: FontWeight.bold)),
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
          title: const Text('إدارة الإشعارات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('إرسال إشعار جماعي', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _audiences.entries.map((e) => ChoiceChip(
                label: Text(e.value),
                selected: _targetAudience == e.key,
                onSelected: (_) => setState(() => _targetAudience = e.key),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.gold,
                labelStyle: TextStyle(color: _targetAudience == e.key ? Colors.black : AppColors.text, fontWeight: FontWeight.bold, fontSize: 12),
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(hintText: 'عنوان الإشعار', hintStyle: TextStyle(color: AppColors.subText), filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bodyController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(hintText: 'نص الإشعار', hintStyle: TextStyle(color: AppColors.subText), filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _isSending ? null : _send,
                child: _isSending
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('إرسال', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 28),
            const Text('سجل الإشعارات المرسلة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            StreamBuilder<List<NotificationModel>>(
              stream: NotificationService.instance.getBroadcastLog(),
              builder: (context, snapshot) {
                final log = snapshot.data ?? const [];
                if (log.isEmpty) {
                  return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('لا يوجد إشعارات مرسلة بعد', style: TextStyle(color: AppColors.subText)));
                }
                return Column(
                  children: log.map((n) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('${_audiences[n.targetAudience] ?? n.targetAudience} • ${n.recipientCount} مستلم', style: TextStyle(color: AppColors.subText, fontSize: 11)),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
