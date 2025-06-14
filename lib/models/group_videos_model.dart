class GroupActivityVideo {
  final int id;
  final String groupName;
  final String userLogin;
  final List<MediaItem> media;

  GroupActivityVideo({
    required this.id,
    required this.groupName,
    required this.userLogin,
    required this.media,
  });

  factory GroupActivityVideo.fromJson(Map<String, dynamic> json) {
    return GroupActivityVideo(
      id: json['id'],
      groupName: json['activity_data']['group_name'] ?? '',
      userLogin: json['bp_videos'] != null && json['bp_videos'].isNotEmpty
          ? json['bp_videos'][0]['user_login'] ?? ''
          : '',
      media: json['bp_videos'] != null
          ? List<MediaItem>.from(json['bp_videos'].map((m) => MediaItem.fromJson(m)))
          : [],
    );
  }
}

class MediaItem {
  final int id;
  final String type;
  final String url;
  final String thumb;
  final String duration; // NEW

  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    required this.thumb,
    required this.duration, // NEW
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final attachmentData = json['attachment_data'] ?? {};
    final meta = attachmentData['meta'] ?? {};

    return MediaItem(
      id: json['id'],
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      thumb: attachmentData['thumb'] ?? '',
      duration: meta['length_formatted'] ?? '', // NEW
    );
  }

  @override
  String toString() {
    return 'MediaItem(id: $id, type: $type, url: $url, thumb: $thumb, duration: $duration)';
  }
}


