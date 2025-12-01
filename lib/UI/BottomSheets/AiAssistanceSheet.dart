
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../Controller/AIAssistantController.dart';
import '../../Models/MessageModel.dart';

class AIAssistantPanel extends StatelessWidget {
  AIAssistantPanel({super.key});

  final TextEditingController inputController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final AiController aiController = Get.find<AiController>();

  // Helper method to perform the scroll action
  void _scrollToBottom() {
    // Only scroll if the controller is attached and we have content
    if (_scrollController.hasClients) {
      // Use addPostFrameCallback to ensure scroll runs after the new message is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }
  Widget buildMessage(ChatMessage msg) {
    bool isUser = msg.role == "user";

    return Row(
      mainAxisAlignment:
      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Avatar only for AI messages
        if (!isUser)
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage("assets/images/robot.png"),
          ),
        if (!isUser) const SizedBox(width: 8),

        /// Bubble
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(msg.text),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        height: 480,
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: -5,
              color: Colors.black.withOpacity(0.15),
            )
          ],
        ),

        child: Column(
          children: [
            // Header
            Row(
              children: [
                Image.asset("assets/images/robot.png", height: 32),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "AI Assistant",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),

            const SizedBox(height: 10),

            /// MESSAGE LIST
            Expanded(
              child: Obx(() {
                if (aiController.messages.isNotEmpty) {
                  _scrollToBottom();
                }
                return ListView(
                  controller: _scrollController,
                  reverse: false,
                  children: [
                    ...aiController.messages.map((msg) => buildMessage(msg)),
                    if (aiController.isSearching.value)
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                            AssetImage("assets/images/robot.png"),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Searching........",
                            style: TextStyle(
                                fontSize: 16, color: Colors.black54),
                          )
                        ],
                      ),
                  ],
                );
              }),
            ),

            /// INPUT FIELD
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: "Type something...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (v) {
                      if (aiController.writing.value) return;
                      aiController.sendMessage(v);
                      inputController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (aiController.writing.value) return;
                    aiController.sendMessage(inputController.text);
                    inputController.clear();
                  },
                  icon: const Icon(Icons.send, color: Colors.blue),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}