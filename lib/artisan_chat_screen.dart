import 'package:flutter/material.dart';

class ArtisanChatScreen extends StatefulWidget {
  const ArtisanChatScreen({super.key});

  @override
  State<ArtisanChatScreen> createState() => _ArtisanChatScreenState();
}

class _ArtisanChatScreenState extends State<ArtisanChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'أهلاً بك يا فنان الرافدين في بوابة التدقيق الذكية. كيف يمكنني مساعدتك في توثيق وتدقيق عملك التراثي اليوم؟',
      'time': '١٢:٠٠ م'
    }
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      // إضافة رسالة الحرفي
      _messages.add({
        'isUser': true,
        'text': _messageController.text,
        'time': 'الآن'
      });
      
      // محاكاة استجابة الذكاء الاصطناعي الفورية بناءً على البرومبت المعتمد
      _messages.add({
        'isUser': false,
        'text': 'جاري تحليل المكونات والمواد للتأكد من الأصالة الفنية التراثية حسب لوائح المنصة...',
        'time': 'جاري الكتابة...'
      });
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), // الثيم الداكن السينمائي
      appBar: AppBar(
        title: const Text('مستشار الجودة والأصالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF161616),
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
                final isUser = msg['isUser'];
                return Align(
                  alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF8B5A2B) : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isUser ? const Radius.circular(0) : const Radius.circular(12),
                        bottomRight: isUser ? const Radius.circular(12) : const Radius.circular(0),
                      ),
                      border: isUser ? null : Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(color: isUser ? Colors.black : Colors.white, fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            msg['time'],
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
            color: const Color(0xFF161616),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'اكتب وصف العمل أو استشر الذكاء الاصطناعي...',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color(0xFF262626),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFD4AF37), // الذهب التراثي
                  child: IconButton(
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
