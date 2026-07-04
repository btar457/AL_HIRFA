import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/chat_message.dart';

class _Conversation {
  final String name;
  final String lastMessage;
  final String time;
  final int unread;
  final bool online;
  const _Conversation({required this.name, required this.lastMessage, required this.time, this.unread = 0, this.online = false});
}

/// شاشة قائمة المحادثات (SHARED-2). فتح محادثة يفتح _ConversationScreen داخل الملف نفسه.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static const _conversations = [
    _Conversation(name: 'أبو مصطفى (الحرفي)', lastMessage: 'تم شحن طلبك، سيصلك خلال يومين', time: '10:24', unread: 2, online: true),
    _Conversation(name: 'شركة بغداد السريعة للشحن', lastMessage: 'المندوب في الطريق إليك الآن', time: 'أمس', unread: 0),
    _Conversation(name: 'دعم AL-HIRFA', lastMessage: 'شكراً لتواصلك معنا، تم حل المشكلة', time: 'الإثنين', unread: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.chatBackground,
        appBar: AppBar(
          backgroundColor: AppColors.chatAppBar,
          elevation: 0,
          title: const Text('المحادثات', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.gold),
        ),
        body: ListView.separated(
          itemCount: _conversations.length,
          separatorBuilder: (context, i) => Divider(color: AppColors.subText.withOpacity(0.1), height: 1),
          itemBuilder: (context, i) {
            final c = _conversations[i];
            return ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ConversationScreen(contactName: c.name, online: c.online))),
              leading: Stack(
                children: [
                  CircleAvatar(backgroundColor: AppColors.gold.withOpacity(0.2), child: const Icon(Icons.person, color: AppColors.gold)),
                  if (c.online)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: AppColors.chatBackground, width: 2))),
                    ),
                ],
              ),
              title: Text(c.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.subText, fontSize: 12)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(c.time, style: TextStyle(color: AppColors.subText, fontSize: 11)),
                  if (c.unread > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                      child: Text('${c.unread}', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConversationScreen extends StatefulWidget {
  final String contactName;
  final bool online;
  const _ConversationScreen({required this.contactName, this.online = false});

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = const [
    ChatMessage(isUser: false, text: 'مرحباً، كيف يمكنني مساعدتك؟', time: '10:20'),
    ChatMessage(isUser: true, text: 'أريد الاستفسار عن موعد وصول طلبي', time: '10:22'),
    ChatMessage(isUser: false, text: 'تم شحن طلبك، سيصلك خلال يومين', time: '10:24'),
  ];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(isUser: true, text: text, time: 'الآن'));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.chatBackground,
        appBar: AppBar(
          backgroundColor: AppColors.chatAppBar,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.gold),
          title: Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.gold.withOpacity(0.2), child: const Icon(Icons.person, color: AppColors.gold, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.contactName, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(widget.online ? 'متصل الآن' : 'آخر ظهور منذ ساعة', style: TextStyle(color: widget.online ? Colors.green : AppColors.subText, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) => _buildBubble(_messages[i]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.chatUserBubble : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.time, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                if (message.isUser) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: AppColors.gold, size: 13),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.chatAppBar,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file, color: AppColors.subText), onPressed: () {}),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.chatInputFill, borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(border: InputBorder.none, hintText: 'اكتب رسالة...', hintStyle: TextStyle(color: AppColors.subText)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
