// lib/controllers/ai_controller.dart
import 'dart:async';
import 'package:archive/archive.dart';
import 'package:business_assistance/Repo/CustomDBRepo.dart';
import 'package:business_assistance/Repo/UploadRepo.dart';
import 'package:business_assistance/UI/BottomSheets/AiAssistanceSheet.dart';
import 'package:business_assistance/Utils/InstructionTypes.dart';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../Models/MessageModel.dart';
import '../Repo/AiRepository.dart';
import '../Utils/DB_ConstantInstrunctions.dart';


class AiController extends GetxController {
  final AiRepository repository;
  final Uploadrepo uploadrepo;
  final CustomDBRepo customDBRepo;

  AiController({required this.repository, required this.uploadrepo, required this.customDBRepo});

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

  Future<String> extractTextFromDocx(SelectedFile file) async {
    if (file.bytes == null) return '';

    final archive = ZipDecoder().decodeBytes(file.bytes!);
    final documentXml = archive
        .firstWhere((f) => f.name == 'word/document.xml', orElse: () => throw 'No document.xml found')
        .content as List<int>;
    //
    // final xmlDoc = XmlDocument.parse(String.fromCharCodes(documentXml));
    // final text = xmlDoc.findAllElements('t').map((node) => node.text).join(' ');

    return "text";
  }

  Future<String> extractTextFromXlsx(SelectedFile file) async {
    if (file.bytes == null) return '';
    final excel = Excel.decodeBytes(file.bytes!);
    String result = '';
    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        result += row.map((cell) => cell?.value.toString() ?? '').join(' ') + '\n';
      }
    }
    return result;
  }

  Future<String> extractTextFromPdf(SelectedFile file) async {
    if (file.bytes == null) return '';

    // Load PDF document from bytes
    final PdfDocument document = PdfDocument(inputBytes: file.bytes);

    // Extract text from all pages
    final String text = PdfTextExtractor(document).extractText();

    // Dispose the document to free memory
    document.dispose();

    return text;
  }
  Future<String> extractTextFromTxt(SelectedFile file) async {
    if (file.bytes == null) return '';
    return String.fromCharCodes(file.bytes!);
  }




  /// Call from UI when user sends message
  Future<void> sendMessage(String text, {SelectedFile? selectedFile}) async {
    if (text.trim().isEmpty) return;
    var instructionType = InstructionTypes.DATABASE;

    // add user message immediately
    messages.add(ChatMessage(role: 'user', text: text , fileName: selectedFile?.name, fileType: selectedFile?.type, fileBytes: selectedFile?.bytes ));
    isSearching.value = true;

    var imageUrl = null;
    if (selectedFile?.type == "image") {
      final url = await uploadrepo.uploadImageBytes(selectedFile?.bytes, selectedFile!.name);
      imageUrl = url?.replaceFirst("http://tmpfiles.org/", "https://tmpfiles.org/dl/");
      final lastIndex = messages.length - 1;
      messages[lastIndex] = messages[lastIndex].copyWith(imageUrl: imageUrl);
      instructionType = InstructionTypes.IMAGE;
      print("imageUrl: $imageUrl");
    }


    String extractedText = '';

    if (selectedFile?.type == "document" && selectedFile != null) {
      instructionType = InstructionTypes.DOCUMENT;
      switch (selectedFile.extension) {
        case 'pdf':
          extractedText = await extractTextFromPdf(selectedFile);
          break;
        case 'txt':
          extractedText = await extractTextFromTxt(selectedFile);
          break;
        case 'docx':
          extractedText = await extractTextFromDocx(selectedFile);
          break;
        case 'xlsx':
          extractedText = await extractTextFromXlsx(selectedFile);
          break;
        default:
          extractedText = 'File type not supported for extraction.';
      }
      print("Extracted Text ${selectedFile.extension}: $extractedText");
    }

    //add extracted text
    final lastIndex = messages.length - 1;
    messages[lastIndex] = messages[lastIndex].copyWith(extractedText: extractedText);

    final instruction = instructionType == InstructionTypes.IMAGE ? DbConstantInstructions.imageInstruction
        : instructionType == InstructionTypes.DOCUMENT ? DbConstantInstructions.documentInstruction
        : DbConstantInstructions.dbInstruction;

    final history = _buildHistory(instruction);
    repository.getAiReply(history).then((resultText) {

      if (resultText["type"] == "query") {
        handleQuery(resultText);
      }else if (resultText["type"] == "stream") {
        isSearching.value = false;
        _streamResponse(resultText["response"].toString());
      }

      // messages.add(ChatMessage(role: 'assistant', text: resultText));
    }).catchError((err) {

      Timer(const Duration(seconds: 5), () {
        isSearching.value = false;
        messages.add(ChatMessage(
          role: 'ai',
          text: 'Server is busy try again after a movement',
        ));
      });
    });
  }


  Future<void> handleQuery(Map<String, String> resultText) async {
    final rawQuery = resultText["response"].toString();
    final safeQuery = sanitizeQuery(rawQuery);
    print("Sanitized Query: $safeQuery");

    try {
      final data = await customDBRepo.runCustomQuery(safeQuery);
      print("Data: $data");

      final history = _buildRefiner(
        instruction: DbConstantInstructions.dbResultRefinerInstruction,
        dbResult: data.toString(),
      );

      final refinedText = await repository.getAiReply(history);
      isSearching.value = false;
      _streamResponse(refinedText["response"].toString());

    } catch (e) {
      print("DB Error: $e");

      // Pass the error message to AI
      final history = _buildRefiner(
        instruction: DbConstantInstructions.dbResultRefinerInstruction,
        dbResult: "ERROR: ${e.toString()}",
      );

      final refinedText = await repository.getAiReply(history);
      isSearching.value = false;
      _streamResponse(refinedText["response"].toString());
    }
  }


  List<Map<String, dynamic>> _buildHistory(String instructions) {
    final List<Map<String, dynamic>> history = [];

    // 1. SYSTEM MESSAGE (ALWAYS FIRST)
    history.add({
      "role": "system",
      "content": [
        {
          "type": "input_text",
          "text": instructions
        }
      ]
    });

    final lastMessages = messages.length > 10
        ? messages.sublist(messages.length - 10)
        : messages;

    history.addAll( messages.where((m) => m.role != "ai").map((m) {
      print("file type: ${m.fileType} base 64: ${m.imageUrl}");

      final message_type = m.role == "user" ? "input_text" : "output_text";

      // Image message"
      // Image message
      if (m.imageUrl != null && m.fileType == "image") {
        return {
          "role": m.role,
          "content": [
            {"type": message_type, "text": m.text},
            {"type": "input_image", "image_url": m.imageUrl} // can be URL or base64 string
          ]
        };
      }

      // Document message (text extracted from file)
      if (m.fileType == "document") {
        print("Extracted Text inside doc condi: ${m.extractedText}");
        return {
          "role": m.role,
          "content": [
            {"type": message_type, "text": "${m.text}\n${m.extractedText}"}
          ]
        };
      }

      // Simple text message
      return {
        "role": m.role,
        "content": [
          {"type": message_type, "text": m.text}
        ]
      };
    }).toList()
    );
    return history;
  }


  String sanitizeQuery(String query) {
    return query.trim().replaceAll(RegExp(r';+$'), '');
  }

  List<Map<String, dynamic>> _buildRefiner({
    required String instruction,
    required String dbResult
  }) {
    final List<Map<String, dynamic>> history = [];

    // SYSTEM
    history.add({
      "role": "system",
      "content": [
        {
          "type": "input_text",
          "text": instruction
        }
      ]
    });

    // USER QUESTION
    history.add({
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": messages.last.text
        }
      ]
    });

    // DATABASE RESULT AS ASSISTANT CONTEXT
    history.add({
      "role": "user",
      "content": [
        {
          "type": "input_text",
          "text": "DATABASE_RESULT:\n$dbResult"
        }
      ]
    });
    return history;
  }


  void clear() {
    messages.clear();
    isSearching.value = false;
  }


}

