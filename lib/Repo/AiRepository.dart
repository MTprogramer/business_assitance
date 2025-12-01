import 'dart:convert';
import 'package:http/http.dart' as http;

class AiRepository {
  final String apiKey = "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";


  Future<String> getAiReply(List<Map<String, String>> history) async {
    const url = "https://api.openai.com/v1/chat/completions";

    final body = {
      "model": "gpt-5.1",
      "messages": history
    };
    print("📤 AI Request: ${jsonEncode(body)}");
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    print("📥 Raw AI Response: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply =
      data["choices"][0]["message"]["content"].toString().trimLeft();
      print("✅ Parsed AI Reply: $reply");

      return reply;
    } else {
      print("❌ API ERROR: ${response.statusCode} => ${response.body}");
      throw Exception("AI Error: ${response.statusCode}");
    }
  }
}
