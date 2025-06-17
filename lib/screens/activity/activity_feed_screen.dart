import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/activity_item_model.dart';
import 'api_service.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({Key? key}) : super(key: key);

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  late Future<List<ActivityItem>> _allActivities;
  final ApiService _apiService = ApiService();
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _allActivities.then((activities) {
      if (activities.isNotEmpty) {
        setState(() {
          _currentUserId = activities.first.userId;
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _allActivities = _apiService.getAllActivities();
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return DateFormat('MMM d, y').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  String _stripHtmlTags(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&[^;]+;'), '')
        .trim();
  }

  // POST OPERATIONS (existing)
  void _showEditPostDialog(BuildContext context, ActivityItem post) {
    _postController.text = _stripHtmlTags(post.content);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _postController,
                decoration: InputDecoration(
                  hintText: 'Edit your post',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 5,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (_postController.text.trim().isNotEmpty) {
                        try {
                          await _apiService.updatePost(
                            post.id,
                            _postController.text,
                            groupId: post.groupId,
                          );
                          _postController.clear();
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post updated successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update post: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // COMMENT OPERATIONS (updated)
  void _showEditCommentDialog(BuildContext context, ActivityComment comment) {
    final controller = TextEditingController(text: _stripHtmlTags(comment.content));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Edit your comment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.text.trim().isNotEmpty) {
                        try {
                          await _apiService.updateComment(comment.id, controller.text);
                          controller.clear();
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comment updated successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update comment: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteComment(BuildContext context, ActivityComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteComment(comment.id);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
      }
    }
  }

  void _handleCommentAction(BuildContext context, ActivityItem post, ActivityComment comment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (comment.userId == _currentUserId)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditCommentDialog(context, comment);
              },
            ),
          if (comment.userId == _currentUserId)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteComment(context, comment);
              },
            ),
        ],
      ),
    );
  }

  // REPLY OPERATIONS (similar to comments)
  void _showEditReplyDialog(BuildContext context, ActivityComment reply) {
    final controller = TextEditingController(text: _stripHtmlTags(reply.content));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Edit your reply',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.text.trim().isNotEmpty) {
                        try {
                          await _apiService.updateReply(reply.id, controller.text);
                          controller.clear();
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reply updated successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update reply: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteReply(BuildContext context, ActivityComment reply) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteReply(reply.id);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete reply: $e')),
        );
      }
    }
  }

  // COMMENT DISPLAY WIDGETS
  Widget _buildFullComment(BuildContext context, ActivityComment comment, ActivityItem post, {bool isReply = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isReply ? 16 : 20,
              child: ClipOval(
                child: (comment.userAvatar != null && comment.userAvatar!.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: comment.userAvatar!,
                  placeholder: (context, url) => Image.asset('assets/default_avatar.png'),
                  errorWidget: (context, url, error) => Image.asset('assets/default_avatar.png'),
                  fit: BoxFit.cover,
                  width: isReply ? 32 : 40,
                  height: isReply ? 32 : 40,
                )
                    : Image.asset('assets/default_avatar.png'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(_stripHtmlTags(comment.content)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatTimeAgo(comment.dateRecorded),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (!isReply)
                        InkWell(
                          onTap: () => _showReplyDialog(context, post, comment),
                          child: Text(
                            'Reply',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 16),
              onPressed: () => isReply
                  ? _handleReplyAction(context, post, comment)
                  : _handleCommentAction(context, post, comment),
            ),
          ],
        ),
        if (comment.replies.isNotEmpty && !isReply)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: comment.replies
                  .map((reply) => _buildFullComment(context, reply, post, isReply: true))
                  .toList(),
            ),
          ),
        const Divider(height: 32),
      ],
    );
  }

  void _handleReplyAction(BuildContext context, ActivityItem post, ActivityComment reply) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reply.userId == _currentUserId)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditReplyDialog(context, reply);
              },
            ),
          if (reply.userId == _currentUserId)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteReply(context, reply);
              },
            ),
        ],
      ),
    );
  }

  // REST OF THE CODE (existing implementation)
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity Feed'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Refresh feed',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'My Posts'),
              Tab(text: 'Following'),
              Tab(text: 'Mentions'),
              Tab(text: 'Groups'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActivityList(_allActivities, 'all'),
            _buildActivityList(_apiService.getUserGroupPosts(), 'my_posts'),
            _buildActivityList(_apiService.getFollowedMembersPosts(), 'following'),
            _buildActivityList(_apiService.getMentions(), 'mentions'),
            _buildActivityList(_apiService.getFollowedGroupsActivities(), 'groups'),
          ],
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
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildActivityItem(context, activities[index]),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem activity) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ClipOval(
              child: (activity.userAvatar != null && activity.userAvatar!.isNotEmpty)
                  ? CachedNetworkImage(
                imageUrl: activity.userAvatar!,
                placeholder: (context, url) => Image.asset('assets/default_avatar.png'),
                errorWidget: (context, url, error) => Image.asset('assets/default_avatar.png'),
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              )
                  : Image.asset('assets/default_avatar.png'),
            ),
            title: Text(activity.username),
            subtitle: Text(_formatTimeAgo(activity.dateRecorded)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showPostActions(context, activity),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _stripHtmlTags(activity.content),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => _showCommentDialog(context, activity),
                  tooltip: 'Comment',
                ),
                const Spacer(),
                Text(
                  '${activity.comments.length} ${activity.comments.length == 1 ? 'comment' : 'comments'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          if (activity.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...activity.comments.take(2).map((comment) => _buildCommentPreview(context, comment, activity)),
                  if (activity.comments.length > 2)
                    TextButton(
                      onPressed: () => _showPostDetails(context, activity),
                      child: Text('View all ${activity.comments.length} comments'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentPreview(BuildContext context, ActivityComment comment, ActivityItem post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: ClipOval(
                  child: (comment.userAvatar != null && comment.userAvatar!.isNotEmpty)
                      ? CachedNetworkImage(
                    imageUrl: comment.userAvatar!,
                    placeholder: (context, url) => Image.asset('assets/default_avatar.png'),
                    errorWidget: (context, url, error) => Image.asset('assets/default_avatar.png'),
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                  )
                      : Image.asset('assets/default_avatar.png'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.username,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 16),
                onPressed: () => _handleCommentAction(context, post, comment),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stripHtmlTags(comment.content),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    Text(
                      _formatTimeAgo(comment.dateRecorded),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _showReplyDialog(context, post, comment),
                      child: Text(
                        'Reply',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (comment.replies.isNotEmpty)
                  ...comment.replies.map((reply) => _buildNestedReplies(context, reply, post)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNestedReplies(BuildContext context, ActivityComment reply, ActivityItem post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              child: ClipOval(
                child: (reply.userAvatar != null && reply.userAvatar!.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: reply.userAvatar!,
                  placeholder: (context, url) => Image.asset('assets/default_avatar.png'),
                  errorWidget: (context, url, error) => Image.asset('assets/default_avatar.png'),
                  fit: BoxFit.cover,
                  width: 28,
                  height: 28,
                )
                    : Image.asset('assets/default_avatar.png'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.username,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _stripHtmlTags(reply.content),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      Text(
                        _formatTimeAgo(reply.dateRecorded),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => _showReplyDialog(context, post, reply),
                        child: Text(
                          'Reply',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, size: 14),
              onPressed: () => _handleReplyAction(context, post, reply),
            ),
          ],
        ),
        if (reply.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: reply.replies
                  .map((nestedReply) => _buildNestedReplies(context, nestedReply, post))
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _showPostActions(BuildContext context, ActivityItem post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (post.userId == _currentUserId)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditPostDialog(context, post);
              },
            ),
          if (post.userId == _currentUserId)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePost(context, post);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePost(BuildContext context, ActivityItem post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deletePost(post.id);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      }
    }
  }

  void _showCommentDialog(BuildContext context, ActivityItem post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Replying to ${post.username}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: () {},
                    tooltip: 'Add image',
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (_commentController.text.trim().isNotEmpty) {
                        try {
                          await _apiService.addComment(post.id, _commentController.text);
                          _commentController.clear();
                          Navigator.pop(context);
                          _loadData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add comment: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Post Comment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext context, ActivityItem post, ActivityComment comment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Replying to ${comment.username}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Write a reply...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (_replyController.text.trim().isNotEmpty) {
                        try {
                          await _apiService.replyToComment(comment.id, _replyController.text);
                          _replyController.clear();
                          Navigator.pop(context);
                          _loadData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add reply: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Post Reply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostDetails(BuildContext context, ActivityItem post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: (post.userAvatar != null && post.userAvatar!.isNotEmpty)
                              ? CachedNetworkImage(
                            imageUrl: post.userAvatar!,
                            placeholder: (context, url) => Image.asset('assets/default_avatar.png'),
                            errorWidget: (context, url, error) => Image.asset('assets/default_avatar.png'),
                            fit: BoxFit.cover,
                            width: 48,
                            height: 48,
                          )
                              : Image.asset('assets/default_avatar.png'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.username),
                              Text(_formatTimeAgo(post.dateRecorded)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_stripHtmlTags(post.content)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            Navigator.pop(context);
                            _showCommentDialog(context, post);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            if (_commentController.text.trim().isNotEmpty) {
                              try {
                                await _apiService.addComment(post.id, _commentController.text);
                                _commentController.clear();
                                _loadData();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to add comment: $e')),
                                );
                              }
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...post.comments.map((comment) => _buildFullComment(context, comment, post)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading feed',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String feedType, BuildContext context) {
    final emptyStateData = {
      'all': {
        'icon': Icons.feed,
        'message': 'No activities yet',
        'action': 'Be the first to post!',
      },
      'my_posts': {
        'icon': Icons.person,
        'message': 'No posts yet',
        'action': 'Share your thoughts with your groups',
      },
      'following': {
        'icon': Icons.people,
        'message': 'No posts from people you follow',
        'action': 'Follow more people to see their posts',
      },
      'mentions': {
        'icon': Icons.alternate_email,
        'message': 'No mentions yet',
        'action': 'Get involved in conversations',
      },
      'groups': {
        'icon': Icons.group,
        'message': 'No group posts yet',
        'action': 'Join or create groups to see activity',
      },
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyStateData[feedType]!['icon'] as IconData,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            emptyStateData[feedType]!['message'] as String,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emptyStateData[feedType]!['action'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


