/// رسالة ضمن محادثة مستشار الجودة والأصالة.
class ChatMessage {
  final bool isUser;
  final String text;
  final String time;

  const ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
  });
}
