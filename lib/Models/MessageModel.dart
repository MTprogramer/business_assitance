import 'dart:typed_data'; // Needed for Uint8List

class ChatMessage {
  String text;
  final String role; // 'user' or 'assistant'
  final String? fileName;
  final Uint8List? fileBytes; // To display images/provide file data
  final String? fileType; // 'image' or 'document'
  final String? imageUrl; // 'image' or 'document'
  final String extractedText; // 'image' or 'document'

  ChatMessage({
    required this.text,
    required this.role,
    this.fileName,
    this.fileType,
    this.fileBytes,
    this.imageUrl,
    this.extractedText = "",
  });

  ChatMessage copyWith({
    String? role,
    String? text,
    String? fileName,
    String? fileType,
    Uint8List? fileBytes,
    String? imageUrl,
    String? extractedText,
  }) {
    return ChatMessage(
      role: role ?? this.role,
      text: text ?? this.text,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileBytes: fileBytes ?? this.fileBytes,
      imageUrl: imageUrl ?? this.imageUrl,
      extractedText: extractedText ?? this.extractedText,
    );
  }
}