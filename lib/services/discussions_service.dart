import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/discussions_model.dart';
import 'package:APHRC_COP/services/token_preference.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';

class DiscussionService {
  Future<String?> _getToken() async {
    return await SaveAccessTokenService.getAccessToken();
  }

  Future<DiscussionsResponse?> discussionList($group) async {
    final url = Uri.parse('$apiBaseUrl/discussions/' + $group);
    final token = await _getToken();

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final json = jsonDecode(response.body);
    final data = json['data'];
    //print(json);
    if (response.statusCode == 200) {
      if (data == null) {
        return DiscussionsResponse(error: 'No data field in response');
      }

      if (data is List) {
        return DiscussionsResponse.fromJson(data);
      }

      if (data is Map && data.containsKey('error')) {
        return DiscussionsResponse(error: data['error']);
      }

      return DiscussionsResponse(error: 'Unexpected data format');
    } else {
      final error =
          data != null && data is Map && data.containsKey('error')
              ? data['error']
              : 'Unknown server error';
      return DiscussionsResponse(error: error);
    }
  }

  static Future<String?> getUserId() async {
    return await SharedPrefsService.getUserId();
  }

  static Future<bool> discussionEdit(String id, String description) async {

      final url = Uri.parse('$apiBaseUrl/discussions-save-edit');
      final token = await SharedPrefsService.getAccessToken();
      final userId = await SharedPrefsService.getUserId();
      final body = jsonEncode({
        'id': id,
        'post_description': description,
        'post_author': userId,
      });

      // print("++++++++++");
      // print(body);
      // print("++++++++++");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        //print(json);
        if (json['success'] == true) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    }
    // try {
    //   final response = await http.post(
    //     Uri.parse('YOUR_API_ENDPOINT_HERE'),
    //     body: {
    //       'id': id,
    //       'description': description,
    //     },
    //   );
    //   return response.statusCode == 200;
    // } catch (e) {
    //   return false;
    // }


  Future<DiscussionsResponse?> discussionReplies(String discussionID) async {
    final url = Uri.parse('$apiBaseUrl/discussion-replys/$discussionID');
    final token = await _getToken();


    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final json = jsonDecode(response.body);
    final data = json['data'];
    // print(json);
    if (response.statusCode == 200) {
      if (data == null) {
        return DiscussionsResponse(error: 'No data field in response');
      }

      if (data is List) {
        return DiscussionsResponse.fromJson(data);
      }

      if (data is Map && data.containsKey('error')) {
        return DiscussionsResponse(error: data['error']);
      }

      return DiscussionsResponse(error: 'Unexpected data format');
    } else {
      final error =
          data != null && data is Map && data.containsKey('error')
              ? data['error']
              : 'Unknown server error';
      return DiscussionsResponse(error: error);
    }
  }

  Future<bool> postDiscussion(
    String title,
    String description, {
    String post_parent = "0",
    Discussions? discussion,
    String? groupd,
  }) async {
    final url = Uri.parse('$apiBaseUrl/discussions-save');
    final token = await _getToken();
    //final userId = SharedPrefsService.getUserId();

    final userId = await SharedPrefsService.getUserId();

    final body = jsonEncode({
      'post_title': title,
      'post_description': description,
      'post_parent': post_parent,
      'discussion_id': discussion?.post_parent,
      'id': discussion?.ID,
      'post_author': userId,
      'groupd': groupd,
    });

    // print("++++++++++");
    // print(body);
    // print("++++++++++");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['success'] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
