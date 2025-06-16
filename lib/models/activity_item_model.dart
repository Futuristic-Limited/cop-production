class ActivityItem {
  final int id;
  final int userId;
  final String component;
  final String type;
  final String action;
  final String content;
  final String primaryLink;
  final int itemId;
  final int secondaryItemId;
  final DateTime dateRecorded;
  final String privacy;
  final String status;
  final ActivityUser? user;

  ActivityItem({
    this.id = 0,
    this.userId = 0,
    this.component = '',
    this.type = '',
    this.action = '',
    this.content = '',
    this.primaryLink = '',
    this.itemId = 0,
    this.secondaryItemId = 0,
    DateTime? dateRecorded,
    this.privacy = 'public',
    this.status = 'published',
    this.user,
  }) : dateRecorded = dateRecorded ?? DateTime.now();

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    // Filter out sensitive user data
    final userJson = json['user'] != null ? Map<String, dynamic>.from(json['user']) : null;
    if (userJson != null) {
      userJson.removeWhere((key, value) =>
          ['user_pass', 'access_token', 'refresh_token', 'token_expires_at', 'refresh_token_expires_at'].contains(key));
    }

    return ActivityItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      component: json['component']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      primaryLink: json['primary_link']?.toString() ?? '',
      itemId: int.tryParse(json['item_id']?.toString() ?? '0') ?? 0,
      secondaryItemId: int.tryParse(json['secondary_item_id']?.toString() ?? '0') ?? 0,
      dateRecorded: DateTime.tryParse(json['date_recorded']?.toString() ?? '') ?? DateTime.now(),
      privacy: json['privacy']?.toString() ?? 'public',
      status: json['status']?.toString() ?? 'published',
      user: userJson != null ? ActivityUser.fromJson(userJson) : null,
    );
  }

  String get username => user?.displayName ?? 'User $userId';
  String? get userAvatar => user?.avatarUrl;
}

class ActivityUser {
  final int id;
  final String userLogin;
  final String userNicename;
  final String displayName;
  final String? avatarUrl;

  ActivityUser({
    required this.id,
    required this.userLogin,
    required this.userNicename,
    required this.displayName,
    this.avatarUrl,
  });

  factory ActivityUser.fromJson(Map<String, dynamic> json) {
    return ActivityUser(
      id: int.tryParse(json['ID']?.toString() ?? '0') ?? 0,
      userLogin: json['user_login']?.toString() ?? '',
      userNicename: json['user_nicename']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}


