import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/follower_model.dart';

class FollowerService {
  static final String baseUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';

  static Future<FollowerData?> fetchFollowerStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/followers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return FollowerData.fromJson(jsonData);
      } else {
        print('Failed to load followers: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching follower stats: $e');
      return null;
    }
  }
}
