import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/notifiers/profile_photo_notifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';

Future<void> uploadProfileImage(File imageFile) async {
  try {
    final token = await SharedPrefsService.getAccessToken();
    if (token == null) {
      print('❌ No token found');
      return;
    }

    final uri = Uri.parse('$apiUrl/profile/photo');
    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath(
        'photo',
        imageFile.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        filename: basename(imageFile.path),
      ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseBody);
      final success = jsonResponse['success'] == true;
      final photoUrl = jsonResponse['photo_url'];

      if (success && photoUrl != null && photoUrl.toString().isNotEmpty) {
        print('✅ Upload successful: $photoUrl');
        await SharedPrefsService.saveProfilePhotoUrl(photoUrl);
        ProfilePhotoNotifier.profilePhotoUrl.value = photoUrl;
      } else {
        print('⚠️ Upload response success=false or missing photo_url');
      }
    } else {
      print('❌ Upload failed: ${response.statusCode}');
      print('Response: $responseBody');
    }

  } catch (e) {
    print('❌ Upload error: $e');
  }
}
