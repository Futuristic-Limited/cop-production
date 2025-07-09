class ActivityFeedResponse {
  final List<ActivityItem> posts;
  final List<ActivityItem> discussions;

  ActivityFeedResponse({
    List<ActivityItem>? posts,
    List<ActivityItem>? discussions,
  })  : posts = posts ?? [],
        discussions = discussions ?? [];

  factory ActivityFeedResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ActivityFeedResponse(
        posts: (json['posts'] as List<dynamic>?)
            ?.map((item) => ActivityItem.fromJson(item))
            .toList(),
        discussions: (json['discussions'] as List<dynamic>?)
            ?.map((item) => ActivityItem.fromJson(item))
            .toList(),
      );
    } catch (e) {
      return ActivityFeedResponse();
    }
  }

  List<ActivityItem> getAllItems() {
    return [...posts, ...discussions]..sort((a, b) =>
        b.dateRecorded.compareTo(a.dateRecorded));
  }
}

class ActivityItem {
  final String id;
  final String userId;
  final String component;
  final String type;
  final String action;
  final String content;
  final String primaryLink;
  final String itemId;
  final String? secondaryItemId;
  final DateTime dateRecorded;
  final bool hideSitewide;
  final int mpttLeft;
  final int mpttRight;
  final bool isSpam;
  final String privacy;
  final String status;
  final ActivityUser? user;
  final List<ActivityComment> comments;
  final List<ActivityMedia> media;
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
    this.secondaryItemId,
    required this.dateRecorded,
    this.hideSitewide = false,
    this.mpttLeft = 0,
    this.mpttRight = 0,
    this.isSpam = false,
    this.privacy = 'public',
    this.status = 'published',
    this.user,
    this.comments = const [],
    this.media = const [],
    this.groupId,
  });

  // NEW: copyWith method added here
  ActivityItem copyWith({
    String? id,
    String? userId,
    String? component,
    String? type,
    String? action,
    String? content,
    String? primaryLink,
    String? itemId,
    String? secondaryItemId,
    DateTime? dateRecorded,
    bool? hideSitewide,
    int? mpttLeft,
    int? mpttRight,
    bool? isSpam,
    String? privacy,
    String? status,
    ActivityUser? user,
    List<ActivityComment>? comments,
    List<ActivityMedia>? media,
    String? groupId,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      component: component ?? this.component,
      type: type ?? this.type,
      action: action ?? this.action,
      content: content ?? this.content,
      primaryLink: primaryLink ?? this.primaryLink,
      itemId: itemId ?? this.itemId,
      secondaryItemId: secondaryItemId ?? this.secondaryItemId,
      dateRecorded: dateRecorded ?? this.dateRecorded,
      hideSitewide: hideSitewide ?? this.hideSitewide,
      mpttLeft: mpttLeft ?? this.mpttLeft,
      mpttRight: mpttRight ?? this.mpttRight,
      isSpam: isSpam ?? this.isSpam,
      privacy: privacy ?? this.privacy,
      status: status ?? this.status,
      user: user ?? this.user,
      comments: comments ?? this.comments,
      media: media ?? this.media,
      groupId: groupId ?? this.groupId,
    );
  }

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

    // Parse media
    final mediaJson = json['media'] as List<dynamic>? ?? [];
    final media = mediaJson.map((mediaJson) => ActivityMedia.fromJson(mediaJson)).toList();

    return ActivityItem(
      id: json['id']?.toString() ?? '0',
      userId: json['user_id']?.toString() ?? '0',
      component: json['component']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      primaryLink: json['primary_link']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '0',
      secondaryItemId: json['secondary_item_id']?.toString(),
      dateRecorded: DateTime.tryParse(json['date_recorded']?.toString() ?? '') ?? DateTime.now(),
      hideSitewide: json['hide_sitewide']?.toString() == '1',
      mpttLeft: int.tryParse(json['mptt_left']?.toString() ?? '0') ?? 0,
      mpttRight: int.tryParse(json['mptt_right']?.toString() ?? '0') ?? 0,
      isSpam: json['is_spam']?.toString() == '1',
      privacy: json['privacy']?.toString() ?? 'public',
      status: json['status']?.toString() ?? 'published',
      user: userJson != null ? ActivityUser.fromJson(userJson) : null,
      comments: comments,
      media: media,
      groupId: json['group_id']?.toString(),
    );
  }

  bool get isDiscussion => type == 'bbp_topic_create';
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

class ActivityMedia {
  final String url;
  final String type;

  ActivityMedia({
    required this.url,
    required this.type,
  });

  factory ActivityMedia.fromJson(Map<String, dynamic> json) {
    return ActivityMedia(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? 'file',
    );
  }
}



