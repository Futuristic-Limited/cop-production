// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/activity_item_model.dart';
import '../../services/token_preference.dart';

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SaveAccessTokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  void _handleError(String methodName, dynamic error, StackTrace stackTrace) {
    debugPrint('Error in $methodName: $error\n$stackTrace');
    throw Exception('Failed to fetch data: $error');
  }

  List<ActivityItem> _parseResponse(List<dynamic> data) {
    return data
        .map((item) {
          try {
            return ActivityItem.fromJson(item as Map<String, dynamic>);
          } catch (e, stackTrace) {
            _handleError('_parseResponse', e, stackTrace);
            return ActivityItem(
              id: 'parse-error-${DateTime.now().millisecondsSinceEpoch}',
              userId: '0',
              component: 'error',
              type: 'error',
              action: '',
              content:
                  _extractContent(item) ?? 'Failed to load activity content',
              primaryLink: '',
              itemId: '0',
              secondaryItemId: '0',
              dateRecorded: DateTime.now(),
              hideSitewide: false,
              mpttLeft: 0,
              mpttRight: 0,
              isSpam: false,
              privacy: 'public',
              status: 'published',
            );
          }
        })
        .where((item) => item.content.isNotEmpty)
        .toList();
  }

  String? _extractContent(dynamic item) {
    try {
      if (item is Map<String, dynamic>) {
        return item['content']?.toString();
      }
      return item.toString();
    } catch (_) {
      return null;
    }
  }

  Future<ActivityItem> createPost(String content, {String? groupId}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.post(
        Uri.parse('${apiUrl}/feed/create'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'content': content,
          if (groupId != null) 'group_id': groupId,
        }),
      );

      if (response.statusCode == 201) {
        return ActivityItem.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('createPost', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityItem> updatePost(
    String postId,
    String content, {
    String? groupId,
  }) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.put(
        Uri.parse('${apiUrl}/feed/update/$postId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'content': content,
          if (groupId != null) 'group_id': groupId,
        }),
      );

      if (response.statusCode == 200) {
        return ActivityItem.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update post: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('updatePost', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.delete(
        Uri.parse('${apiUrl}/feed/delete/$postId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('deletePost', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> addComment(String postId, String content) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.post(
        Uri.parse('${apiUrl}/feed/comment/$postId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'content': content, // Only send content since postId is in URL
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // Ensure the response contains the full comment data
        return ActivityComment.fromJson(
          responseData['comment'] ?? responseData,
        );
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('addComment error', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> updateComment(
    String commentId,
    String content,
  ) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.put(
        Uri.parse('${apiUrl}/feed/comment/update/$commentId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        return ActivityComment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update comment: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('updateComment', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.delete(
        Uri.parse('${apiUrl}/feed/comment/delete/$commentId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('deleteComment', e, stackTrace);
      rethrow;
    }
  }

  // Future<ActivityComment> replyToComment(String commentId, String content) async {
  //   try {
  //     final apiUrl = dotenv.env['API_URL'];
  //     final response = await http.post(
  //       Uri.parse('${apiUrl}/feed/comment/reply/$commentId'),
  //       headers: await _getHeaders(),
  //       body: jsonEncode({'content': content}),
  //     );
  //
  //     if (response.statusCode == 201) {
  //       return ActivityComment.fromJson(jsonDecode(response.body));
  //     } else {
  //       throw Exception('Failed to add reply: ${response.statusCode}');
  //     }
  //   } catch (e, stackTrace) {
  //     _handleError('replyToComment', e, stackTrace);
  //     rethrow;
  //   }
  // }

  Future<ActivityComment> replyToComment(
    String commentId,
    String content,
  ) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      print('Attempting to reply to comment $commentId');
      print('API URL: $apiUrl');
      print('Content being sent: $content');

      final headers = await _getHeaders();
      print('Headers: $headers');

      final body = jsonEncode({'content': content});
      print('Request body: $body');

      final uri = Uri.parse('${apiUrl}/feed/comment/reply/$commentId');
      print('Full URL: ${uri.toString()}');

      final response = await http.post(uri, headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 201) {
        return ActivityComment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to add reply: ${response.statusCode}. Response: ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('Detailed error in replyToComment:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      _handleError('replyToComment', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> updateReply(String replyId, String content) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.put(
        Uri.parse('${apiUrl}/feed/comment/reply/update/$replyId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        return ActivityComment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update reply: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('updateReply', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteReply(String replyId) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.delete(
        Uri.parse('${apiUrl}/feed/comment/reply/delete/$replyId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete reply: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('deleteReply', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> replyToReply(String replyId, String content) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.post(
        Uri.parse('${apiUrl}/feed/comment/reply/nested/$replyId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 201) {
        return ActivityComment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add nested reply: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('replyToReply', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> updateNestedReply(
    String nestedReplyId,
    String content,
  ) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.put(
        Uri.parse('${apiUrl}/feed/comment/nested/reply/update/$nestedReplyId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        return ActivityComment.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to update nested reply: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _handleError('updateNestedReply', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteNestedReply(String nestedReplyId) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.delete(
        Uri.parse('${apiUrl}/feed/comment/nested/reply/delete/$nestedReplyId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to delete nested reply: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _handleError('deleteNestedReply', e, stackTrace);
      rethrow;
    }
  }

  Future<List<ActivityItem>> getAllActivities() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}activities/feeds'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final combined = [
          ..._parseResponse(data['user_groups_posts'] ?? []),
          ..._parseResponse(data['followed_members_posts'] ?? []),
          ..._parseResponse(data['mentions'] ?? []),
          ..._parseResponse(data['followed_groups_activity'] ?? []),
        ];
        combined.sort((a, b) => b.dateRecorded.compareTo(a.dateRecorded));
        return combined;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - please login again');
      } else {
        throw Exception(
          'Failed to load all activities: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _handleError('getAllActivities', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<List<ActivityItem>> getUserGroupPosts() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}user/groups/posts'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _parseResponse(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - please login again');
      } else {
        throw Exception(
          'Failed to load user group posts: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _handleError('getUserGroupPosts', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<List<ActivityItem>> getFollowedMembersPosts() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}followed/members/posts'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _parseResponse(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - please login again');
      } else {
        throw Exception(
          'Failed to load followed members posts: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _handleError('getFollowedMembersPosts', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<List<ActivityItem>> getFollowedGroupsActivities() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}followed/groups/activities'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _parseResponse(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - please login again');
      } else {
        throw Exception(
          'Failed to load followed groups activities: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _handleError('getFollowedGroupsActivities', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<List<ActivityItem>> getMentions() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}mentions'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _parseResponse(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - please login again');
      } else {
        throw Exception('Failed to load mentions: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('getMentions', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<http.Response> postDiscussion({
    required String postId,
    required String content,
    required List<File> mediaFiles,
    required List<String> uploadedIds, // Must match mediaFiles length
    required String accessToken,
    required String apiUrl,
  }) async {
    if (content.isEmpty && postId.isEmpty) {
      throw Exception('Content and Post ID cannot be empty');
    }

    final List<int> imageIds = [];
    final List<int> videoIds = [];
    final List<int> documentIds = [];

    for (int i = 0; i < mediaFiles.length; i++) {
      final filePath = mediaFiles[i].path;
      final extension = filePath.split('.').last.toLowerCase();
      final uploadedId = int.tryParse(uploadedIds[i]) ?? 0;

      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        imageIds.add(uploadedId);
      } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
        videoIds.add(uploadedId);
      } else if ([
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
      ].contains(extension)) {
        documentIds.add(uploadedId);
      }
    }

    final Map<String, dynamic> payload = {
      'content': content,
      if (imageIds.isNotEmpty) 'bp_media_ids': imageIds,
      if (videoIds.isNotEmpty) 'bp_videos': videoIds,
      if (documentIds.isNotEmpty) 'bp_documents': documentIds,
    };

    print('Posting discussion with payload: $payload');

    final response = await http.post(
      Uri.parse('$apiUrl/wp-json/buddyboss/v1/activity/$postId/comment'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    return response;
  }
}
