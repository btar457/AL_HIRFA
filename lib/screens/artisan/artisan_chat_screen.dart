import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/chat_message.dart';
import '../../models/gemini_audit_result.dart';
import '../../services/gemini_service.dart';

class ArtisanChatScreen extends StatefulWidget {
  const ArtisanChatScreen({super.key});

  @override
  State<ArtisanChatScreen> createState() => _ArtisanChatScreenState();
}

class _ArtisanChatScreenState extends State<ArtisanChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    const ChatMessage(
      isUser: false,
      text: 'أهلاً بك يا فنان الرافدين في بوابة التدقيق الذكية. صف لي منتجك (الاسم والمواد المستخدمة) وسأدقق أصالته فوراً.',
      time: '١٢:٠٠ م',
    ),
  ];
  bool _isSending = false;

  String _now() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour >= 12 ? 'م' : 'ص'}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'APPROVED':
        return 'مقبول ✅';
      case 'REJECTED':
        return 'مرفوض ❌';
      default:
        return 'قيد المراجعة ⏳';
    }
  }

  String _formatAuditResult(GeminiAuditResult result) {
    return '${_statusLabel(result.status)}\n'
        'نسبة الثقة: ${result.confidenceScore}٪\n'
        'التصنيف المقترح: ${result.suggestedCategory}\n\n'
        '${result.reasonArabic}';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(isUser: true, text: text, time: _now()));
      _messages.add(const ChatMessage(
        isUser: false,
        text: 'جاري تحليل المكونات والمواد للتأكد من الأصالة الفنية التراثية...',
        time: 'جاري الكتابة...',
      ));
    });

    try {
      final result = await GeminiService.auditProduct(text);
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(isUser: false, text: _formatAuditResult(result), time: _now()));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(isUser: false, text: 'تعذّر إتمام التدقيق: ${e.toString().replaceFirst('Exception: ', '')}', time: _now()));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppBar(
        title: const Text('مستشار الجودة والأصالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.chatAppBar,
        centerTitle: true,
      ),
      body: Column(
        children: [
            // منطقة عرض الرسائل التفاعلية
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.isUser;
                  return Align(
                    alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.chatUserBubble : AppColors.card,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isUser ? const Radius.circular(0) : const Radius.circular(12),
                          bottomRight: isUser ? const Radius.circular(12) : const Radius.circular(0),
                        ),
                        border: isUser ? null : Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
                      ),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(color: isUser ? Colors.black : Colors.white, fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              msg.time,
                              style: TextStyle(color: isUser ? Colors.black54 : Colors.white30, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // حقل إدخال الرسائل المطور
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.chatAppBar,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isSending,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'اكتب وصف العمل أو استشر الذكاء الاصطناعي...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: AppColors.chatInputFill,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.gold,
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.black, size: 20),
                            onPressed: _sendMessage,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
