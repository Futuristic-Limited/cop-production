import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:APHRC_COP/services/token_preference.dart';

class ForumService {
  final String wpApi = dotenv.env['WP_API_URL'] ?? 'https://default.api/';

  /// Retrieve token from SaveAccessTokenService
  Future<String?> _getAccessToken() async {
    return await SaveAccessTokenService.getBuddyToken();
  }

  /// Fetch the group details
  Future<List<dynamic>> fetchCommunities(String groupId) async {
    print('Slug goes here, $groupId');
    final url = '${wpApi}wp-json/buddyboss/v1/groups?per_page=100';
    print('The group id, $groupId');
    print('Fetching communities from: $url'); // Debugging line

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data from the forum API: $data'); // Debugging line
        // This API returns a List directly, not wrapped in a 'groups' key
        return data as List<dynamic>;
      } else {
        throw Exception(
          'Failed to load communities: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching communities: $e');
    }
  }
  
}
