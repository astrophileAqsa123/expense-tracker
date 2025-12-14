import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CloudinaryService {
  static const String cloudName = "dzqscmrj2";
  static const String uploadPreset = "profile_preset";

  static Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields["upload_preset"] = uploadPreset
      ..fields["public_id"] =
          "profile_${DateTime.now().millisecondsSinceEpoch}"
      ..files.add(
        await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
          contentType: MediaType("image", "jpeg"),
        ),
      );

    final response = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final resStr = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Cloudinary upload failed: ${response.statusCode} $resStr");
    }

    final jsonMap = jsonDecode(resStr) as Map<String, dynamic>;
    final url = jsonMap["secure_url"] as String?;
    if (url == null || url.isEmpty) {
      throw Exception("Cloudinary response missing secure_url");
    }

    return url;
  }
}
