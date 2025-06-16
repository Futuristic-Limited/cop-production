import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
        // Combine all feed types into one list
        final combined = [
          ..._parseResponse(data['user_groups_posts'] ?? []),
          ..._parseResponse(data['followed_members_posts'] ?? []),
          ..._parseResponse(data['mentions'] ?? []),
          ..._parseResponse(data['followed_groups_activity'] ?? []),
        ];
        // Sort by date (newest first)
        combined.sort((a, b) => b.dateRecorded.compareTo(a.dateRecorded));
        return combined;
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
        throw Exception('Failed to load followed members posts: ${response.statusCode}');
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
        throw Exception('Failed to load followed groups activities: ${response.statusCode}');
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
        throw Exception('Failed to load mentions: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _handleError('getMentions', e, stackTrace);
    }
  }
}

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({Key? key}) : super(key: key);

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  late Future<List<ActivityItem>> _allActivities;
  late Future<List<ActivityItem>> _myGroupPosts;
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
      _myGroupPosts = _apiService.getUserGroupPosts();
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
          title: const Text('Feeds'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'My Posts'),
              Tab(text: 'Following'),
              Tab(text: 'Mentions'),
              Tab(text: 'Group Feed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActivityList(_allActivities, 'all'),
            _buildActivityList(_myGroupPosts, 'my_posts'),
            _buildActivityList(_followingActivities, 'following'),
            _buildActivityList(_mentionsActivities, 'mentions'),
            _buildActivityList(_followedGroupsActivities, 'group_feed'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreatePostDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildActivityList(Future<List<ActivityItem>> futureActivities, String feedType) {
    return FutureBuilder<List<ActivityItem>>(
      future: futureActivities,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error.toString());
        }

        final activities = snapshot.data ?? [];
        if (activities.isEmpty) {
          return _buildEmptyState(feedType, context);
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPostDetails(context, activity),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildUserAvatar(activity),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.username,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isMention)
                RichText(
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
              else
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 16),
              _buildPostActions(isDiscussion, isUpdate, isMention),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(ActivityItem activity) {
    return ClipOval(
      child: (activity.userAvatar != null && activity.userAvatar!.isNotEmpty)
          ? CachedNetworkImage(
        imageUrl: activity.userAvatar!,
        placeholder: (context, url) => Image.asset(
          'assets/default_avatar.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/default_avatar.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      )
          : Image.asset(
        'assets/default_avatar.png',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildPostActions(bool isDiscussion, bool isUpdate, bool isMention) {
    return Row(
      children: [
        const Spacer(),
        if (isDiscussion)
          Chip(
            label: const Text('Discussion'),
            backgroundColor: Colors.blue[50],
            labelStyle: const TextStyle(color: Colors.blue),
          ),
        if (isUpdate)
          Chip(
            label: const Text('Update'),
            backgroundColor: Colors.green[50],
            labelStyle: const TextStyle(color: Colors.green),
          ),
        if (isMention)
          Chip(
            label: const Text('Mention'),
            backgroundColor: Colors.purple[50],
            labelStyle: const TextStyle(color: Colors.purple),
          ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
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
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String feedType, BuildContext context) {
    final emptyStateData = {
      'all': {
        'icon': Icons.feed,
        'message': 'No activities available',
      },
      'my_posts': {
        'icon': Icons.person,
        'message': 'You haven\'t posted in any groups yet',
      },
      'following': {
        'icon': Icons.people,
        'message': 'No posts from people you follow',
      },
      'mentions': {
        'icon': Icons.alternate_email,
        'message': 'No mentions yet',
      },
      'group_feed': {
        'icon': Icons.group,
        'message': 'No posts in your groups yet',
      },
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyStateData[feedType]!['icon'] as IconData,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            emptyStateData[feedType]!['message'] as String,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Refresh'),
          ),
        ],
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
    String text = htmlText.replaceAllMapped(
        RegExp(r'''<a class=['"]bp-suggestions-mention['"].*?>@(\w+)</a>'''),
            (match) => '@${match.group(1)}'
    );
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&[^;]+;'), '')
        .replaceAll(RegExp(r'\n'), ' ')
        .trim();
  }

  void _showPostDetails(BuildContext context, ActivityItem activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _buildUserAvatar(activity),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.username,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _formatTimeAgo(activity.dateRecorded),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(_stripHtmlTags(activity.content)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'What are you thinking about?',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Handle post submission
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}


