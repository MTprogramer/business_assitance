class ChatMessage {
  final String role; // "user" or "ai"
  String text;

  ChatMessage({required this.role, required this.text});
}
