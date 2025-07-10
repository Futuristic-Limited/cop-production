import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:APHRC_COP/services/token_preference.dart';

class CommunityService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'https://default.api/';
  final String wpApi = dotenv.env['WP_API_URL'] ?? 'https://default.api/';

  /// Retrieve token from SaveAccessTokenService
  Future<String?> _getToken() async {
    return await SaveAccessTokenService.getAccessToken();
  }

  /// Fetch community groups from API
  ///
  Future<List<dynamic>> fetchCommunitiesCustomAPI() async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}groups'),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data'); // Debugging line
        return data['groups'] as List<dynamic>; // <-- FIXED LINE
      } else {
        throw Exception(
          'Failed to load communities: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching communities: $e');
    }
  }

  Future<List<dynamic>> fetchCommunitiesV1() async {
    final token = await _getToken();

    try {
      final response = await http.get(
        Uri.parse('${wpApi}wp-json/buddyboss/v1/groups?per_page=100'),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data'); // Debugging line
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

  Future<List<dynamic>> fetchCommunities() async {
    final url = '${wpApi}wp-json/buddyboss/v1/groups?per_page=100';
    print('Fetching communities from: $url'); // Debugging line

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data'); // Debugging line
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

  /// Join a community group via API using its ID
  Future<bool> joinCommunity(String groupId) async {
    final token = await _getToken();

    try {
      final response = await http.post(
        Uri.parse('${baseUrl}join_group'),
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'group_id': groupId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to join community: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error joining community: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchJoinedGroups() async {
    final token = await _getToken(); // Ensure _getToken is implemented properly

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/joined'),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['groups'] is List) {
          return List<Map<String, dynamic>>.from(body['groups']);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
          'Failed to load joined groups: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching joined groups: $e');
    }
  }

  Future<int?> fetchUserIdFromToken(String token) async {
    final url = Uri.parse(
      '{$baseUrl}/groups/', // Change to your API URL
    ); // Change to your API URL

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Assuming the JSON structure contains 'user_id' like { "user_id": 123, ... }
      if (data != null && data['user_id'] != null) {
        return data['user_id'] as int;
      } else {
        // user_id not found in response
        return null;
      }
    } else {
      // API call failed
      throw Exception('Failed to fetch user id: ${response.statusCode}');
    }
  }



  Future<bool?> checkUserGroupMembership(String token, String userId, int groupId) async {
    final url = Uri.parse(
      '${baseUrl}/groups/check/$groupId/$userId', // Fixed string interpolation
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data != null && data['is_member'] != null) {
        return data['is_member'] as bool; // Changed to bool
      } else {
        // is_member not found in response
        return null;
      }
    } else {
      // API call failed
      throw Exception('Failed to fetch user membership: ${response.statusCode}');
    }
  }

  Future<List<int>> getJoinedGroupIds() async {
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/groups/index'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List joinedGroups = data['user']['joined_groups'] ?? [];
        return joinedGroups.map<int>((group) => int.parse(group['group_id'])).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching joined groups: $e');
      return [];
    }
  }
}
