class ActivityItem {
  final int id;
  final int userId;
  final String component;
  final String type;
  final String action;
  final String content;
  final int itemId;
  final DateTime dateRecorded;
  final String? userAvatar;
  final String username;
  final List<ActivityMeta> meta;

  ActivityItem({
    required this.id,
    required this.userId,
    required this.component,
    required this.type,
    required this.action,
    required this.content,
    required this.itemId,
    required this.dateRecorded,
    this.userAvatar,
    required this.username,
    required this.meta,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      component: json['component']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      itemId: int.tryParse(json['item_id']?.toString() ?? '0') ?? 0,
      dateRecorded: DateTime.parse(json['date_recorded']?.toString() ?? DateTime.now().toString()),
      userAvatar: json['user_avatar']?.toString(),
      username: json['username']?.toString() ?? 'Unknown', // Note: username isn't in the response
      meta: [], // The response doesn't show meta data
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'component': component,
      'type': type,
      'action': action,
      'content': content,
      'item_id': itemId,
      'date_recorded': dateRecorded.toIso8601String(),
      'user_avatar': userAvatar,
      'username': username,
      'meta': meta.map((m) => m.toJson()).toList(),
    };
  }
}


