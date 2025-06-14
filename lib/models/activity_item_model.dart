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
  }) : dateRecorded = dateRecorded ?? DateTime.now();

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
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
    );
  }

  // Add this getter for username (you'll need to implement user lookup separately)
  String get username => 'User $userId';

  // Add this getter for avatar (you'll need to implement avatar lookup separately)
  String? get userAvatar => null;
}


