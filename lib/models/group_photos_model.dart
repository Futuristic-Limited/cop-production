class GroupMedia {
  final int id;
  final String groupName;
  final String userLogin;
  final String displayName;
  final String userNicename;
  final MediaItem media;
  final String dateCreated;
  final String privacy;
  final String visibility;
  final String type;

  GroupMedia({
    required this.id,
    required this.groupName,
    required this.userLogin,
    required this.displayName,
    required this.userNicename,
    required this.media,
    required this.dateCreated,
    required this.privacy,
    required this.visibility,
    required this.type,
  });

  factory GroupMedia.fromJson(Map<String, dynamic> json) {
    return GroupMedia(
      id: json['id'],
      groupName: json['group_name'] ?? '',
      userLogin: json['user_login'] ?? '',
      displayName: json['display_name'] ?? '',
      userNicename: json['user_nicename'] ?? '',
      dateCreated: json['date_created'] ?? '',
      privacy: json['privacy'] ?? '',
      visibility: json['visibility'] ?? '',
      type: json['type'] ?? '',
      media: MediaItem.fromJson(json),
    );
  }
}

class MediaItem {
  final int id;
  final String type;
  final String url;
  final String thumb;
  final String fullImage;
  final String downloadUrl;
  final String title;
  final String description;
  final Map<String, dynamic>? userPermissions;
  final Map<String, dynamic>? meta;

  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    required this.thumb,
    required this.fullImage,
    required this.downloadUrl,
    required this.title,
    required this.description,
    this.userPermissions,
    this.meta,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final attachmentData = json['attachment_data'] ?? {};
    final meta = attachmentData['meta'] ?? {};

    return MediaItem(
      id: json['id'],
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      thumb: attachmentData['thumb'] ?? '',
      fullImage: attachmentData['full'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userPermissions: json['user_permissions'] is Map
          ? Map<String, dynamic>.from(json['user_permissions'])
          : null,
      meta: meta is Map ? Map<String, dynamic>.from(meta) : null,
    );
  }

  @override
  String toString() {
    return 'MediaItem(id: $id, type: $type, url: $url)';
  }
}