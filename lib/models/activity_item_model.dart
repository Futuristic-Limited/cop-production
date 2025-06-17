class ActivityItem {
  final String id;
  final String userId;
  final String component;
  final String type;
  final String action;
  final String content;
  final String primaryLink;
  final String itemId;
  final String secondaryItemId;
  final DateTime dateRecorded;
  final bool hideSitewide;
  final int mpttLeft;
  final int mpttRight;
  final bool isSpam;
  final String privacy;
  final String status;
  final ActivityUser? user;
  final List<ActivityComment> comments;
  final String? groupId;

  ActivityItem({
    required this.id,
    required this.userId,
    required this.component,
    required this.type,
    required this.action,
    required this.content,
    required this.primaryLink,
    required this.itemId,
    required this.secondaryItemId,
    required this.dateRecorded,
    this.hideSitewide = false,
    this.mpttLeft = 0,
    this.mpttRight = 0,
    this.isSpam = false,
    this.privacy = 'public',
    this.status = 'published',
    this.user,
    this.comments = const [],
    this.groupId,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    // Filter out sensitive user data
    final userJson = json['user'] != null ? Map<String, dynamic>.from(json['user']) : null;
    if (userJson != null) {
      userJson.removeWhere((key, value) =>
          ['user_pass', 'access_token', 'refresh_token', 'token_expires_at', 'refresh_token_expires_at'].contains(key));
    }

    // Parse comments
    final commentsJson = json['comments'] as List<dynamic>? ?? [];
    final comments = commentsJson.map((commentJson) => ActivityComment.fromJson(commentJson)).toList();

    return ActivityItem(
      id: json['id']?.toString() ?? '0',
      userId: json['user_id']?.toString() ?? '0',
      component: json['component']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      primaryLink: json['primary_link']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '0',
      secondaryItemId: json['secondary_item_id']?.toString() ?? '0',
      dateRecorded: DateTime.tryParse(json['date_recorded']?.toString() ?? '') ?? DateTime.now(),
      hideSitewide: json['hide_sitewide']?.toString() == '1',
      mpttLeft: int.tryParse(json['mptt_left']?.toString() ?? '0') ?? 0,
      mpttRight: int.tryParse(json['mptt_right']?.toString() ?? '0') ?? 0,
      isSpam: json['is_spam']?.toString() == '1',
      privacy: json['privacy']?.toString() ?? 'public',
      status: json['status']?.toString() ?? 'published',
      user: userJson != null ? ActivityUser.fromJson(userJson) : null,
      comments: comments,
      groupId: json['group_id']?.toString(),  // Add this line
    );
  }

  String get username => user?.displayName ?? 'User $userId';
  String? get userAvatar => user?.avatarUrl;
}

class ActivityComment {
  final String id;
  final String userId;
  final String component;
  final String type;
  final String action;
  final String content;
  final String primaryLink;
  final String itemId;
  final String secondaryItemId;
  final DateTime dateRecorded;
  final bool hideSitewide;
  final int mpttLeft;
  final int mpttRight;
  final bool isSpam;
  final String privacy;
  final String status;
  final ActivityUser? user;
  final List<ActivityComment> replies;

  ActivityComment({
    required this.id,
    required this.userId,
    required this.component,
    required this.type,
    required this.action,
    required this.content,
    required this.primaryLink,
    required this.itemId,
    required this.secondaryItemId,
    required this.dateRecorded,
    this.hideSitewide = false,
    this.mpttLeft = 0,
    this.mpttRight = 0,
    this.isSpam = false,
    this.privacy = 'public',
    this.status = 'published',
    this.user,
    this.replies = const [],
  });

  factory ActivityComment.fromJson(Map<String, dynamic> json) {
    // Filter out sensitive user data
    final userJson = json['user'] != null ? Map<String, dynamic>.from(json['user']) : null;
    if (userJson != null) {
      userJson.removeWhere((key, value) =>
          ['user_pass', 'access_token', 'refresh_token', 'token_expires_at', 'refresh_token_expires_at'].contains(key));
    }

    // Parse replies
    final repliesJson = json['replies'] as List<dynamic>? ?? [];
    final replies = repliesJson.map((replyJson) => ActivityComment.fromJson(replyJson)).toList();

    return ActivityComment(
      id: json['id']?.toString() ?? '0',
      userId: json['user_id']?.toString() ?? '0',
      component: json['component']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      primaryLink: json['primary_link']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '0',
      secondaryItemId: json['secondary_item_id']?.toString() ?? '0',
      dateRecorded: DateTime.tryParse(json['date_recorded']?.toString() ?? '') ?? DateTime.now(),
      hideSitewide: json['hide_sitewide']?.toString() == '1',
      mpttLeft: int.tryParse(json['mptt_left']?.toString() ?? '0') ?? 0,
      mpttRight: int.tryParse(json['mptt_right']?.toString() ?? '0') ?? 0,
      isSpam: json['is_spam']?.toString() == '1',
      privacy: json['privacy']?.toString() ?? 'public',
      status: json['status']?.toString() ?? 'published',
      user: userJson != null ? ActivityUser.fromJson(userJson) : null,
      replies: replies,
    );
  }

  String get username => user?.displayName ?? 'User $userId';
  String? get userAvatar => user?.avatarUrl;
}

class ActivityUser {
  final String id;
  final String userLogin;
  final String userNicename;
  final String userEmail;
  final String? userUrl;
  final DateTime userRegistered;
  final String displayName;
  final String? avatarUrl;

  ActivityUser({
    required this.id,
    required this.userLogin,
    required this.userNicename,
    required this.userEmail,
    this.userUrl,
    required this.userRegistered,
    required this.displayName,
    this.avatarUrl,
  });

  factory ActivityUser.fromJson(Map<String, dynamic> json) {
    return ActivityUser(
      id: json['ID']?.toString() ?? '0',
      userLogin: json['user_login']?.toString() ?? '',
      userNicename: json['user_nicename']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      userUrl: json['user_url']?.toString(),
      userRegistered: DateTime.tryParse(json['user_registered']?.toString() ?? '') ?? DateTime.now(),
      displayName: json['display_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}


