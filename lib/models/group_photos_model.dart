class GroupActivity {
  final int id;
  final String groupName;
  final String userLogin;
  final List<MediaItem> media;

  GroupActivity({
    required this.id,
    required this.groupName,
    required this.userLogin,
    required this.media,
  });

  factory GroupActivity.fromJson(Map<String, dynamic> json) {
    return GroupActivity(
      id: json['id'],
      groupName: json['activity_data']['group_name'] ?? '',
      userLogin: json['bp_media_ids'] != null && json['bp_media_ids'].isNotEmpty
          ? json['bp_media_ids'][0]['user_login'] ?? ''
          : '',
      media: json['bp_media_ids'] != null
          ? List<MediaItem>.from(json['bp_media_ids'].map((m) => MediaItem.fromJson(m)))
          : [],
    );
  }
}

class MediaItem {
  final int id;
  final String type;
  final String url;

  MediaItem({
    required this.id,
    required this.type,
    required this.url,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
