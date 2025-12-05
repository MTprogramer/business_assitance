import 'dart:convert';
import 'package:http/http.dart' as http;

class AiRepository {
  final String apiKey = "";
  Future<String> getAiReply(List<Map<String, dynamic>> history) async {
    const url = "https://api.openai.com/v1/responses";

    print("History: $history");

    final body = {
      "model": "gpt-4.1", // or any multimodal GPT model
      "input": history,         // use the history you already built
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
      final outputList = data['output'] as List<dynamic>?;

      String reply = "";

// Check if output exists
      if (outputList != null && outputList.isNotEmpty) {
        final firstMessage = outputList[0] as Map<String, dynamic>;
        final contentList = firstMessage['content'] as List<dynamic>?;

        if (contentList != null && contentList.isNotEmpty) {
          for (var content in contentList) {
            if (content['type'] == 'output_text') {
              reply = content['text']?.toString().trim() ?? "";
              break; // Stop after first output_text
            }
          }
        }
      }

      print("✅ Parsed AI Reply: $reply");
      return reply;
    } else {
      print("❌ API ERROR: ${response.statusCode} => ${response.body}");
      throw Exception("AI Error: ${response.statusCode}");
    }
  }

  // Future<String> getAiReply(List<Map<String, dynamic>> history) async {
  //   const url = "https://api.openai.com/v1/chat/completions";
  //
  //   final body = {
  //     "model": "gpt-5.1",
  //     "messages": history
  //   };
  //   print("📤 AI Request: ${jsonEncode(body)}");
  //   final response = await http.post(
  //     Uri.parse(url),
  //     headers: {
  //       "Authorization": "Bearer $apiKey",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode(body),
  //   );
  //   print("📥 Raw AI Response: ${response.body}");
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final reply =
  //     data["choices"][0]["message"]["content"].toString().trimLeft();
  //     print("✅ Parsed AI Reply: $reply");
  //
  //     return reply;
  //   } else {
  //     print("❌ API ERROR: ${response.statusCode} => ${response.body}");
  //     throw Exception("AI Error: ${response.statusCode}");
  //   }
  // }
}
