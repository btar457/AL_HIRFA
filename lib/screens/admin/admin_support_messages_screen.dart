import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/support_message_model.dart';
import '../../services/support_service.dart';

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

const _roleLabels = {'customer': 'مشتري', 'artisan': 'حرفي', 'shipping': 'شركة شحن', 'admin': 'إدارة'};

/// رسائل الدعم المُرسَلة من داخل التطبيق مباشرة — support_service.dart.
class AdminSupportMessagesScreen extends StatelessWidget {
  const AdminSupportMessagesScreen({super.key});

  void _showReplyDialog(BuildContext context, SupportMessageModel message) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('الردّ على ${message.name}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.message, style: TextStyle(color: AppColors.subText, fontSize: 13)),
              const SizedBox(height: 14),
              TextFormField(
                controller: replyController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: 'ردّك (اختياري)',
                  hintStyle: TextStyle(color: AppColors.subText),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.gold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                await SupportService.instance.resolveMessage(message.id, adminReply: replyController.text.trim().isEmpty ? null : replyController.text.trim());
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('تعليم كمُعالَجة', style: TextStyle(fontWeight: FontWeight.bold)),
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
          elevation: 0,
          title: const Text('رسائل الدعم', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: StreamBuilder<List<SupportMessageModel>>(
          stream: SupportService.instance.getAllMessages(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('تعذّر تحميل رسائل الدعم', style: TextStyle(color: AppColors.subText)));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            final messages = snapshot.data!;
            if (messages.isEmpty) {
              return Center(child: Text('لا توجد رسائل دعم', style: TextStyle(color: AppColors.subText)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final resolved = m.status == 'resolved';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: resolved ? null : Border.all(color: AppColors.gold.withOpacity(0.4))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${m.name} (${_roleLabels[m.role] ?? m.role})', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(_formatDate(m.createdAt), style: TextStyle(color: AppColors.subText, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(m.message, style: const TextStyle(color: AppColors.text, fontSize: 13, height: 22 / 13)),
                      if (resolved && m.adminReply != null && m.adminReply!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('ردّك: ${m.adminReply}', style: TextStyle(color: AppColors.subText, fontSize: 12)),
                      ],
                      const SizedBox(height: 10),
                      if (!resolved)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.gold), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            onPressed: () => _showReplyDialog(context, m),
                            child: const Text('الردّ / تعليم كمُعالَجة', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                          ),
                        )
                      else
                        Text('✓ تمّت المعالجة', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
