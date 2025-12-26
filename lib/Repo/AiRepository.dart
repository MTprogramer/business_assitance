import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiRepository {
  final apiKey = String.fromEnvironment("API_KEY" , defaultValue: "");
  // final apiKey = "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";


  Future<Map<String, String>> getAiReply(List<Map<String, dynamic>> history) async {
    const url = "https://api.openai.com/v1/responses";

    print("key  : $apiKey");
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

      print(outputList);
      String reply = "";

      Map<String, String> map  = {};

// Check if output exists
      if (outputList != null && outputList.isNotEmpty) {
        final firstMessage = outputList[0] as Map<String, dynamic>;
        final contentList = firstMessage['content'] as List<dynamic>?;

        if (contentList != null && contentList.isNotEmpty) {
          for (var content in contentList) {
            if (content['type'] == 'output_text') {
              reply = content['text']?.toString().trim() ?? "";

              try {
                var parsed = jsonDecode(reply) as Map<String, dynamic>;

                final bool isDbRelated = parsed['isDbRelated'] == true;
                final String? schemaQuery = parsed['schemaQuery'] as String?;
                final String? responseText = parsed['response'] as String?;

                if (isDbRelated && schemaQuery != null && schemaQuery.isNotEmpty) {
                  map = {"type": "query", "response": schemaQuery};
                } else if (responseText != null && responseText.isNotEmpty) {
                  map = {"type": "stream", "response": responseText};
                } else {
                  map = {"type": "stream", "response": reply};
                }
              } catch (_) {
                map = {"type": "stream", "response": reply};
              }

              break; // Stop after first output_text
            }
          }
        }
      }

      print("✅ Parsed AI Reply: $reply");
      return map;
    } else {
      print("❌ API ERROR: ${response.statusCode} => ${response.body}");
      throw Exception("AI Error: ${response.statusCode}");
    }
  }

  Future<String> generateImage(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/images/generations');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-image-1',
        'prompt': prompt,
        'n': 1,
        'size': '1024x1024',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Image generation failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['data'][0]['b64_json'];
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
