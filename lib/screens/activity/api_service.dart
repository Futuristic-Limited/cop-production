// lib/services/api_service_v3.dart
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

  // Updated parser based on v1's working implementation
  // ActivityFeedResponse _parseFeedResponse(http.Response response) {
  //   if (response.statusCode == 200) {
  //     try {
  //       final jsonData = jsonDecode(response.body);
  //
  //       // Handle case where response is a List (empty array)
  //       if (jsonData is List) {
  //         return ActivityFeedResponse(posts: [], discussions: []);
  //       }
  //
  //       // Handle case where response is a Map
  //       if (jsonData is Map<String, dynamic>) {
  //         // Check for empty responses where keys might be missing
  //         final posts = jsonData['posts'] is List ? jsonData['posts'] : [];
  //         final discussions = jsonData['discussions'] is List ? jsonData['discussions'] : [];
  //
  //         return ActivityFeedResponse(
  //           posts: (posts as List).map((item) => ActivityItem.fromJson(item)).toList(),
  //           discussions: (discussions as List).map((item) => ActivityItem.fromJson(item)).toList(),
  //         );
  //       }
  //
  //       // Default empty response for unexpected formats
  //       return ActivityFeedResponse(posts: [], discussions: []);
  //     } catch (e, stackTrace) {
  //       _handleError('_parseFeedResponse', e, stackTrace);
  //       return ActivityFeedResponse(posts: [], discussions: []);
  //     }
  //   } else if (response.statusCode == 401) {
  //     throw Exception('Session expired - please login again');
  //   } else {
  //     // Return empty feed for 404 and other errors
  //     return ActivityFeedResponse(posts: [], discussions: []);
  //   }
  // }

  ActivityFeedResponse _parseFeedResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);

        if (jsonData is List) {
          return ActivityFeedResponse(posts: [], discussions: []);
        }

        if (jsonData is Map<String, dynamic>) {
          final posts = (jsonData['posts'] as List? ?? [])
              .map((item) => ActivityItem.fromJson(item).copyWith(type: 'post'))
              .toList();

          final discussions = (jsonData['discussions'] as List? ?? [])
              .map((item) => ActivityItem.fromJson(item).copyWith(
              type: 'discussion',
              component: 'groups',
              action: 'bbp_topic_create'
          ))
              .toList();

          return ActivityFeedResponse(
            posts: posts,
            discussions: discussions,
          );
        }

        return ActivityFeedResponse(posts: [], discussions: []);
      } catch (e, stackTrace) {
        _handleError('_parseFeedResponse', e, stackTrace);
        return ActivityFeedResponse(posts: [], discussions: []);
      }
    } else if (response.statusCode == 401) {
      throw Exception('Session expired - please login again');
    } else {
      return ActivityFeedResponse(posts: [], discussions: []);
    }
  }

  ActivityItem _parseActivityItemResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ActivityItem.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Session expired - please login again');
    } else {
      throw Exception('Failed to load item: ${response.statusCode}');
    }
  }

  ActivityComment _parseCommentResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return ActivityComment.fromJson(responseData['comment'] ?? responseData);
    } else if (response.statusCode == 401) {
      throw Exception('Session expired - please login again');
    } else {
      throw Exception('Failed to load comment: ${response.statusCode}');
    }
  }

  Map<String, dynamic> _processMediaFiles(List<File> mediaFiles, List<String> uploadedIds) {
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
      } else if (['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'].contains(extension)) {
        documentIds.add(uploadedId);
      }
    }

    return {
      if (imageIds.isNotEmpty) 'bp_media_ids': imageIds,
      if (videoIds.isNotEmpty) 'bp_videos': videoIds,
      if (documentIds.isNotEmpty) 'bp_documents': documentIds,
    };
  }

  Future<ActivityFeedResponse> getActivityFeed() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}activities/feeds'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Safely extract each section with fallback to empty lists
        final userGroupsPosts = _extractSection(data, 'user_groups_posts');
        final followedMembersPosts = _extractSection(data, 'followed_members_posts');
        final mentions = _extractSection(data, 'mentions');
        final followedGroupsActivity = _extractSection(data, 'followed_groups_activity');

        return ActivityFeedResponse(
          posts: [
            ...userGroupsPosts.posts,
            ...followedMembersPosts.posts,
            ...mentions.posts,
            ...followedGroupsActivity.posts,
          ],
          discussions: [
            ...userGroupsPosts.discussions,
            ...followedMembersPosts.discussions,
            ...mentions.discussions,
            ...followedGroupsActivity.discussions,
          ],
        );
      } else {
        return ActivityFeedResponse(posts: [], discussions: []);
      }
    } catch (e) {
      return ActivityFeedResponse(posts: [], discussions: []);
    }
  }

  // ActivityFeedResponse _extractSection(Map<String, dynamic> data, String key) {
  //   final section = data[key];
  //   if (section == null || section is! Map<String, dynamic>) {
  //     return ActivityFeedResponse(posts: [], discussions: []);
  //   }
  //
  //   return ActivityFeedResponse(
  //     posts: (section['posts'] as List? ?? []).map((item) => ActivityItem.fromJson(item)).toList(),
  //     discussions: (section['discussions'] as List? ?? []).map((item) => ActivityItem.fromJson(item)).toList(),
  //   );
  // }

  ActivityFeedResponse _extractSection(Map<String, dynamic> data, String key) {
    final section = data[key];
    if (section == null || section is! Map<String, dynamic>) {
      return ActivityFeedResponse(posts: [], discussions: []);
    }

    return ActivityFeedResponse(
      posts: (section['posts'] as List? ?? [])
          .map((item) => ActivityItem.fromJson(item).copyWith(type: 'post'))
          .toList(),
      discussions: (section['discussions'] as List? ?? [])
          .map((item) => ActivityItem.fromJson(item).copyWith(
          type: 'discussion',
          component: 'groups',
          action: 'bbp_topic_create'
      ))
          .toList(),
    );
  }

  Future<ActivityFeedResponse> getUserGroupPosts() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}user/groups/posts'),
        headers: await _getHeaders(),
      );
      return _parseFeedResponse(response);
    } catch (e, stackTrace) {
      _handleError('getUserGroupPosts', e, stackTrace);
      return ActivityFeedResponse(posts: [], discussions: []);
    }
  }

  Future<ActivityFeedResponse> getFollowedMembersPosts() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}followed/members/posts'),
        headers: await _getHeaders(),
      );
      return _parseFeedResponse(response);
    } catch (e, stackTrace) {
      _handleError('getFollowedMembersPosts', e, stackTrace);
      return ActivityFeedResponse(posts: [], discussions: []);
    }
  }

  Future<ActivityFeedResponse> getMentions() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}mentions'),
        headers: await _getHeaders(),
      );
      return _parseFeedResponse(response);
    } catch (e, stackTrace) {
      _handleError('getMentions', e, stackTrace);
      return ActivityFeedResponse(posts: [], discussions: []);
    }
  }

  Future<ActivityFeedResponse> getFollowedGroupsActivities() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.get(
        Uri.parse('${apiUrl}followed/groups/activities'),
        headers: await _getHeaders(),
      );

      // Special handling for empty responses
      if (response.statusCode == 204 || response.body.isEmpty) {
        return ActivityFeedResponse(posts: [], discussions: []);
      }

      return _parseFeedResponse(response);
    } catch (e, stackTrace) {
      _handleError('getFollowedGroupsActivities', e, stackTrace);
      return ActivityFeedResponse(posts: [], discussions: []);
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
      return _parseActivityItemResponse(response);
    } catch (e, stackTrace) {
      _handleError('createPost', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityItem> updatePost(String postId, String content, {String? groupId}) async {
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
      return _parseActivityItemResponse(response);
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

  Future<ActivityComment> addComment(String itemId, String content, {bool isDiscussion = false}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];

      final response = await http.post(
        Uri.parse('${apiUrl}/feed/comment/$itemId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );
      return _parseCommentResponse(response);
    } catch (e, stackTrace) {
      _handleError('addComment', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> updateComment(String commentId, String content, {bool isDiscussion = false}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];

      final response = await http.put(
        Uri.parse('${apiUrl}/feed/comment/update/$commentId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );
      return _parseCommentResponse(response);
    } catch (e, stackTrace) {
      _handleError('updateComment', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId, {bool isDiscussion = false}) async {
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

  Future<ActivityComment> replyToComment(String commentId, String content, {bool isDiscussion = false}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];

      final response = await http.post(
        Uri.parse('${apiUrl}/feed/comment/reply/$commentId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );
      return _parseCommentResponse(response);
    } catch (e, stackTrace) {
      _handleError('replyToComment', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> updateReply(String replyId, String content, {bool isDiscussion = false}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];

      final response = await http.put(
        Uri.parse('${apiUrl}/feed/comment/reply/update/$replyId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );
      return _parseCommentResponse(response);
    } catch (e, stackTrace) {
      _handleError('updateReply', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteReply(String replyId, {bool isDiscussion = false}) async {
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

  Future<ActivityComment> replyToReply(String replyId, String content, {bool isDiscussion = false}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.post(
        Uri.parse('${apiUrl}/feed/comment/reply/nested/$replyId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );

      return _parseCommentResponse(response);
    } catch (e, stackTrace) {
      _handleError('replyToReply', e, stackTrace);
      rethrow;
    }
  }

  Future<ActivityComment> updateNestedReply(String nestedReplyId, String content, {bool isDiscussion = false}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.put(
        Uri.parse('${apiUrl}/feed/comment/nested/reply/update/$nestedReplyId'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );

      return _parseCommentResponse(response);
    } catch (e, stackTrace) {
      _handleError('updateNestedReply', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteNestedReply(String nestedReplyId, {bool isDiscussion = false}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      final response = await http.delete(
        Uri.parse('${apiUrl}/feed/comment/nested/reply/delete/$nestedReplyId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete nested reply: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('deleteNestedReply', e, stackTrace);
      rethrow;
    }
  }
}


