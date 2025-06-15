import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/activity_item_model.dart';
import '../../services/token_preference.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({Key? key}) : super(key: key);

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  late Future<List<ActivityItem>> _allActivities;
  late Future<List<ActivityItem>> _groupActivities;
  late Future<List<ActivityItem>> _followingActivities;
  late Future<List<ActivityItem>> _mentionsActivities;
  late Future<List<ActivityItem>> _followedGroupsActivities;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _allActivities = _apiService.getAllActivities();
      _groupActivities = _apiService.getUserGroupPosts();
      _followingActivities = _apiService.getFollowedMembersPosts();
      _mentionsActivities = _apiService.getMentions();
      _followedGroupsActivities = _apiService.getFollowedGroupsActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity Feed'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Groups'),
              Tab(text: 'Following'),
              Tab(text: 'Mentions'),
              Tab(text: 'Followed Groups'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildActivityList(_allActivities),
            _buildActivityList(_groupActivities),
            _buildActivityList(_followingActivities),
            _buildActivityList(_mentionsActivities),
            _buildActivityList(_followedGroupsActivities),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement create new activity
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildActivityList(Future<List<ActivityItem>> futureActivities) {
    return FutureBuilder<List<ActivityItem>>(
      future: futureActivities,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load activities',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final activities = snapshot.data ?? [];

        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  snapshot.connectionState == ConnectionState.done && futureActivities == _mentionsActivities
                      ? Icons.alternate_email
                      : Icons.info_outline,
                  size: 48,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  futureActivities == _mentionsActivities
                      ? 'No mentions yet'
                      : 'No activities available',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadData();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: activities.length,
            itemBuilder: (context, index) => _buildActivityCard(context, activities[index]),
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityItem activity) {
    final timeAgo = _formatTimeAgo(activity.dateRecorded);
    final content = _stripHtmlTags(activity.content);
    final isDiscussion = activity.type.contains('bbp_');
    final isUpdate = activity.type == 'activity_update';
    final isMention = activity.content.contains('@') ||
        activity.type.contains('mention') ||
        activity.component == 'mentions';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: activity.userAvatar != null && activity.userAvatar!.isNotEmpty
                      ? NetworkImage(activity.userAvatar!)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.username,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            isMention
                ? RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: content,
                    style: TextStyle(
                      color: Colors.black,
                      backgroundColor: Colors.purple.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            )
                : Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                const Text('0'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {},
                ),
                const Text('0'),
                const Spacer(),
                if (isDiscussion)
                  Chip(
                    label: const Text('Discussion'),
                    backgroundColor: Colors.blue[50],
                  ),
                if (isUpdate)
                  Chip(
                    label: const Text('Update'),
                    backgroundColor: Colors.green[50],
                  ),
                if (isMention)
                  Chip(
                    label: const Text('Mention'),
                    backgroundColor: Colors.purple[50],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return DateFormat('MMM d, y').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String _stripHtmlTags(String htmlText) {
    // First handle mentions
    String text = htmlText.replaceAllMapped(
        RegExp(r'''<a class=['"]bp-suggestions-mention['"].*?>@(\w+)</a>'''),
            (match) => '@${match.group(1)}'
    );

    // Then remove all other HTML tags
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&[^;]+;'), '') // Handle HTML entities
        .replaceAll(RegExp(r'\n'), ' ')
        .trim();
  }
}

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await SaveAccessTokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Never _handleError(String methodName, dynamic error, StackTrace stackTrace) {
    print('Error in $methodName: $error\n$stackTrace');
    throw Exception('Failed to fetch data: $error');
  }

  List<ActivityItem> _parseResponse(dynamic data) {
    if (data == null) return [];
    final activitiesList = data is List ? data : [data];
    return activitiesList.map<ActivityItem>((json) {
      try {
        return ActivityItem.fromJson(json);
      } catch (e) {
        print('Error parsing activity item: $e\nJSON: $json');
        return ActivityItem(
          content: json['content']?.toString() ?? 'Error loading activity',
          dateRecorded: DateTime.now(),
        );
      }
    }).where((item) => item != null).toList();
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
        return _parseResponse(data['user_groups_posts']);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - please login again');
      } else {
        throw Exception('Failed to load all activities: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('getAllActivities', e, stackTrace);
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
        throw Exception('Failed to load user group posts: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('getUserGroupPosts', e, stackTrace);
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
            'Failed to load followed members posts. Status: ${response.statusCode}\n'
                'Response: ${response.body}'
        );
      }
    } catch (e, stackTrace) {
      _handleError('getFollowedMembersPosts', e, stackTrace);
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
            'Failed to load followed groups activities. Status: ${response.statusCode}\n'
                'Response: ${response.body}'
        );
      }
    } catch (e, stackTrace) {
      _handleError('getFollowedGroupsActivities', e, stackTrace);
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
        throw Exception(
            'Failed to load mentions. Status: ${response.statusCode}\n'
                'Response: ${response.body}'
        );
      }
    } catch (e, stackTrace) {
      _handleError('getMentions', e, stackTrace);
    }
  }
}


