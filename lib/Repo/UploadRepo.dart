

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Uploadrepo {

  /// Upload image bytes to tmpfiles.org with a unique filename
  Future<String?> uploadImageBytes(Uint8List? bytes, String baseName) async {
    final uri = Uri.parse("https://tmpfiles.org/api/v1/upload");

    print("Uploading image...");
    if (bytes == null) return '';

    // Append current milliseconds to the filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = "$baseName-$timestamp.png";

    final request = http.MultipartRequest("POST", uri);
    request.files.add(http.MultipartFile.fromBytes(
      "file",
      bytes,
      filename: fileName,
    ));
    print("Uploading image: $fileName");


    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print("Image uploaded successfully: ${response.body}");
      final data = jsonDecode(response.body);
      return data['data']['url'];// public URL for the uploaded image
    } else {
      print("Error uploading image: ${response.statusCode} => ${response.body}");
      return null;
    }
  }
}