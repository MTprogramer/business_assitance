// lib/Repo/ChatRepo.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Controller/AuthController.dart';
import '../Models/MessageModel.dart';


class ChatRepo {
  final SupabaseClient client  = Supabase.instance.client;
  final AuthenticationController authController;

  ChatRepo({required this.authController});

  // Save a single message
  Future<void> saveMessage(ChatMessage message) async {
    final userId = authController.currentUser!.id;
    try {
      await client.from('chat_history').insert({
        'user_id': userId,
        'role': message.role,
        'text': message.text,
        'file_name': message.fileName,
        'file_type': message.fileType,
        'image_url': message.imageUrl,
        'extracted_text': message.extractedText,
      });
    } catch (e) {
      print("Supabase insert error: $e");
    }
  }

  // Fetch all messages for the user
  Future<List<ChatMessage>> fetchHistory() async {
    final userId = authController.currentUser!.id;
    try {
      final response = await client
          .from('chat_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true) as List<dynamic>;

      return response.map((m) {
        return ChatMessage(
          role: m['role'],
          text: m['text'],
          fileName: m['file_name'],
          fileType: m['file_type'],
          imageUrl: m['image_url'],
          extractedText: m['extracted_text'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Supabase fetch error: $e");
      return [];
    }
  }

  // Clear chat history for the user
  Future<void> clearHistory() async {
    final userId = authController.currentUser!.id;
    try {
      await client.from('chat_history').delete().eq('user_id', userId);
    } catch (e) {
      print("Supabase delete error: $e");
    }
  }
}