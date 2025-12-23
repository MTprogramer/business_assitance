// You must have `package:file_picker/file_picker.dart` imported
import 'dart:typed_data'; // Needed for Uint8List

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:file_picker/file_picker.dart'; // REQUIRED
import 'package:url_launcher/url_launcher.dart';

import '../../Controller/AIAssistantController.dart';
import '../../Models/MessageModel.dart';

// Helper class to store selected file information (UPDATED to include bytes)
class SelectedFile {
  final String name;
  final String path;
  final String type; // 'image' or 'document'
  final String extension; // 'image' or 'document'
  final Uint8List? bytes; // <--- NEW: Crucial for rendering the preview
  SelectedFile(this.name, this.path, this.type, this.bytes,  this.extension);
}
class AIAssistantPanel extends StatefulWidget {
  AIAssistantPanel({super.key});

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final TextEditingController inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Ensure your controller is updated to use the full `SelectedFile`
  final AiController aiController = Get.find<AiController>();

  SelectedFile? _selectedFile;

  // Shows the file picking options to the user
  Future<String?> _showFilePickerOptions() async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Attach a File", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Colors.blue),
                title: const Text('Pick Image'),
                onTap: () => Navigator.pop(context, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: Colors.blue),
                title: const Text('Pick Document'),
                onTap: () => Navigator.pop(context, 'document'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _pickFile() async {
    if (aiController.writing.value) {
      return;
    }

    final choice = await _showFilePickerOptions();

    if (choice == null) {
      return;
    }

    FilePickerResult? result;

    // IMPORTANT: Ensure withData: true is always used to get bytes for preview
    if (choice == 'image') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Needed for Image.memory preview
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf','doc','docx','txt','csv','xls','xlsx'],
        withData: true, // Needed to send file data to controller/backend
      );
    }

    if (result == null) {
      return;
    }

    PlatformFile file = result.files.first;

    String fileExtension = file.extension ?? '';
    // DOCX files are currently not supported for extraction in the controller
    if (fileExtension.toLowerCase() == 'docx') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The '.docx' file type is currently not supported for content extraction."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop processing the file
    }

    setState(() {
      _selectedFile = SelectedFile(
        file.name,
        file.path ?? 'web-file',
        choice,
        file.bytes,
        file.extension ?? '',
      );
    });
  }

  // Method to clear the selected file
  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  // Helper method to perform the scroll action
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Existing message bubble widget (UPDATED to display file/image and AI-generated image)
  Widget buildMessage(ChatMessage msg) {
    bool isUser = msg.role == "user";

    // 1. Widget to display the attached file/image (User's side)
    Widget fileContent = const SizedBox.shrink();
    if (isUser && msg.fileName != null) {
      if (msg.fileType == 'image' && msg.fileBytes != null) {
        // Display Image Thumbnail
        fileContent = Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
              msg.fileBytes!,
              width: 150, // Set a max width for the preview
              height: 150, // Set a max height
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        // Display Document File Info
        fileContent = Padding(
          padding: EdgeInsets.only(bottom: msg.text.isNotEmpty ? 8.0 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined, size: 24, color: isUser ? Colors.blue.shade700 : Colors.grey.shade700),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  msg.fileName!,
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: isUser ? Colors.black87 : Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    }


    // 2. NEW: Widget to display AI-generated image and download button (AI's side)
    Widget aiImageContent = const SizedBox.shrink();
    if (!isUser && msg.imageUrl != null && msg.imageUrl!.startsWith('http')) {
      aiImageContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              msg.imageUrl!,
              width: 200, // Fixed width for chart/image preview
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download Image'),
            onPressed: () async {
              final uri = Uri.parse(msg.imageUrl!);
              if (await canLaunchUrl(uri)) {
                // Opens the URL, allowing the user to view/download the image
                await launchUrl(uri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open ${msg.imageUrl!}')),
                );
              }
            },
          ),
          // Add a divider if text is present below the image
          if (msg.text.isNotEmpty) const Divider(height: 16, thickness: 0.5),
        ],
      );
    }


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
            child: Column( // Use Column to stack all contents
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. User's attached file/image
                if (isUser) fileContent,
                // 2. AI's generated image/chart
                if (!isUser) aiImageContent,
                // 3. Render the message text (only if it's not empty)
                if (msg.text.isNotEmpty)
                  Text(msg.text),
                // Only show text content (which includes the streaming text)
                if (msg.text.isEmpty && (msg.fileName != null || msg.imageUrl != null))
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // The UI widget to show selected file
  Widget _buildSelectedFileChip() {
    if (_selectedFile == null) return const SizedBox.shrink();

    IconData icon = _selectedFile!.type == 'image'
        ? Icons.image_outlined
        : Icons.description_outlined;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(
          _selectedFile!.name,
          style: const TextStyle(fontSize: 14),
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: _clearFile,
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue.shade200, width: 0.5),
        ),
      ),
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
                    const SizedBox(height: 8),
                  ],
                );
              }),
            ),

            /// FILE DISPLAY (Above the input field)
            _buildSelectedFileChip(),

            /// INPUT FIELD
            Row(
              children: [
                // Attachment Button
                Obx(() => IconButton(
                  onPressed: aiController.writing.value || aiController.isSearching.value ? null : _pickFile,
                  icon: Icon(
                    _selectedFile != null ? Icons.attach_file : Icons.attachment,
                    color: _selectedFile != null ? Colors.blue.shade700 : Colors.grey,
                  ),
                  tooltip: _selectedFile != null
                      ? "File selected: ${_selectedFile!.name}"
                      : "Attach File",
                )),

                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: "Type a message or describe your file...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (v) {
                      if (aiController.writing.value || aiController.isSearching.value) return;
                      // Only send if there's text or a file selected
                      if (v.trim().isNotEmpty || _selectedFile != null) {
                        aiController.sendMessage(
                          v,
                          selectedFile: _selectedFile,
                        );
                        inputController.clear();
                        _clearFile(); // Clear the file after sending
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Send Button
                Obx(() => Container(
                  decoration: BoxDecoration(
                    color: aiController.writing.value || aiController.isSearching.value ? Colors.grey : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: aiController.writing.value || aiController.isSearching.value ? null : () {
                      // Only send if there's text or a file selected
                      if (inputController.text.trim().isNotEmpty || _selectedFile != null) {
                        aiController.sendMessage(
                          inputController.text,
                          selectedFile: _selectedFile,
                        );
                        inputController.clear();
                        _clearFile(); // Clear the file after sending
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                    splashRadius: 24,
                  ),
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}