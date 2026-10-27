import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/error_handler.dart';
import '../../models/support_message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/support_service.dart';

String _formatDate(DateTime date) {
  const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// راسل الدعم من داخل التطبيق — يصل مباشرة لكل حسابات الإدارة فور الإرسال
/// (بديل/مكمِّل للبريد وواتساب الخارجيين في about_screen.dart).
class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});
  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  Future<void> _send() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null || _messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    try {
      await SupportService.instance.sendMessage(
        uid: user.uid,
        name: user.name,
        role: user.role,
        message: _messageController.text.trim(),
      );
      _messageController.clear();
      if (!mounted) return;
      AppError.showSnackbar(context, 'تم إرسال رسالتك، سيتواصل معك الدعم قريباً', isError: false);
    } catch (e) {
      if (!mounted) return;
      AppError.showSnackbar(context, AppError.getFirebaseError(e));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().currentUser?.uid;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('تواصل مع الدعم', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: uid == null
            ? Center(child: Text('سجّل الدخول للتواصل مع الدعم', style: TextStyle(color: AppColors.subText)))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('اكتب رسالتك وستصل مباشرة لفريق الدعم داخل التطبيق.', style: TextStyle(color: AppColors.subText, fontSize: 13, height: 22 / 13)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'اكتب مشكلتك أو استفسارك هنا...',
                      hintStyle: TextStyle(color: AppColors.subText),
                      filled: true,
                      fillColor: AppColors.card,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.gold.withOpacity(0.4))),
                      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.gold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, disabledBackgroundColor: AppColors.gold.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _isSending ? null : _send,
                      child: _isSending
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('إرسال', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('رسائلك السابقة', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  StreamBuilder<List<SupportMessageModel>>(
                    stream: SupportService.instance.getMyMessages(uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('تعذّر تحميل رسائلك', style: TextStyle(color: AppColors.subText));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                      }
                      final messages = snapshot.data!;
                      if (messages.isEmpty) {
                        return Text('لا توجد رسائل سابقة', style: TextStyle(color: AppColors.subText));
                      }
                      return Column(children: messages.map(_buildMessageCard).toList());
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageCard(SupportMessageModel m) {
    final resolved = m.status == 'resolved';
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
              Text(_formatDate(m.createdAt), style: TextStyle(color: AppColors.subText, fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: (resolved ? Colors.green : AppColors.gold).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(resolved ? 'تم الردّ' : 'قيد المراجعة', style: TextStyle(color: resolved ? Colors.green : AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(m.message, style: const TextStyle(color: AppColors.text, fontSize: 13, height: 22 / 13)),
          if (m.adminReply != null && m.adminReply!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ردّ الدعم', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(m.adminReply!, style: const TextStyle(color: AppColors.text, fontSize: 13, height: 22 / 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
