import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';

class UserUploadService {
  /// Fetch uploads for the authenticated user
  static Future<List<Map<String, dynamic>>> fetchUserUploads() async {
    final token = await SharedPrefsService.getAccessToken();

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final url = Uri.parse('$apiUrl/user/uploads');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> uploads = body['data'];
      return uploads.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch user uploads: ${response.body}');
    }
  }

  /// Fetch and display image using media ID
  static Future<http.Response> getUserImage(int id) async {
    final token = await SharedPrefsService.getAccessToken();

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final url = Uri.parse('$apiUrl/user/image/$id');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'image/*',
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to fetch image. Status: ${response.statusCode}');
    }
  }
}
