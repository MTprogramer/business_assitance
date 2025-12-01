// lib/controllers/ai_controller.dart
import 'dart:async';
import 'package:business_assistance/Repo/AiRepository.dart';
import 'package:get/get.dart';

import '../Models/MessageModel.dart';


class AiController extends GetxController {
  final AiRepository repository;

  AiController({required this.repository});

  // observable state
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool writing = false.obs;
  final Duration typingDelay = const Duration(milliseconds: 30);

  void _streamResponse(String responseText) {
    // 1. Create a new message with empty text and add it to the list
    final streamingMessage = ChatMessage(
      role: "assistant",
      text: "",
    );
    messages.add(streamingMessage);

    final int messageIndex = messages.length - 1;
    int currentIndex = 0;

    Timer.periodic(typingDelay, (timer) {
      if (currentIndex < responseText.length) {
        writing.value = true;
        ChatMessage currentMessage = messages[messageIndex];
        currentMessage.text = currentMessage.text + responseText[currentIndex];

        // 3. Force the observable list to update the UI
        messages.refresh();

        currentIndex++;
      } else {
        writing.value = false;
        timer.cancel();
      }
    });
  }


  /// Call from UI when user sends message
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // add user message immediately
    messages.add(ChatMessage(role: 'user', text: text));

    isSearching.value = true;

    final history = _buildHistory();
    repository.getAiReply(history).then((resultText) {
      isSearching.value = false;
      _streamResponse(resultText);
      // messages.add(ChatMessage(role: 'assistant', text: resultText));
    }).catchError((err) {

      Timer(const Duration(seconds: 5), () {
        isSearching.value = false;
        messages.add(ChatMessage(
          role: 'ai',
          text: 'Unable to fetch results. Please try again.',
        ));
      });
    });
  }
  /// Convert your ChatMessage list into OpenAI's format
  List<Map<String, String>> _buildHistory() {
    final lastMessages = messages.length > 10
        ? messages.sublist(messages.length - 10)
        : messages;

    return lastMessages
        .map((m) => {"role": m.role, "content": m.text})
        .toList();
  }

  void clear() {
    messages.clear();
    isSearching.value = false;
  }


}
