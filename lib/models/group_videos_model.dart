import 'package:intl/intl.dart';

class GroupActivityVideo {
  final int id;
  final String groupName;
  final String userLogin;  // Already present
  final String userNicename;  // Adding this from JSON
  final String displayName;
  final MediaItem media;
  final String dateCreated;
  final String privacy;
  final String visibility;

  GroupActivityVideo({
    required this.id,
    required this.groupName,
    required this.userLogin,
    required this.userNicename,
    required this.displayName,
    required this.media,
    required this.dateCreated,
    required this.privacy,
    required this.visibility,
  });

  factory GroupActivityVideo.fromJson(Map<String, dynamic> json) {
    return GroupActivityVideo(
      id: json['id'],
      groupName: json['group_name'] ?? '',
      userLogin: json['user_login'] ?? '',
      userNicename: json['user_nicename'] ?? '',  // Added
      displayName: json['display_name'] ?? '',
      dateCreated: json['date_created'] ?? '',
      privacy: json['privacy'] ?? '',
      visibility: json['visibility'] ?? '',
      media: MediaItem.fromJson(json),
    );
  }

  // Helper method to format date
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(dateCreated);
      return DateFormat('MMM d, y • h:mm a').format(dateTime);
    } catch (e) {
      return dateCreated;
    }
  }
}

class MediaItem {
  final int id;
  final String type;
  final String url;
  final String thumb;
  final String duration;
  final String downloadUrl;
  final String title;
  final String description;
  final String? userLogin;  // Added as optional
  final Map<String, dynamic>? userPermissions;

  MediaItem({
    required this.id,
    required this.type,
    required this.url,
    required this.thumb,
    required this.duration,
    required this.downloadUrl,
    required this.title,
    required this.description,
    this.userLogin,
    this.userPermissions,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final attachmentData = json['attachment_data'] ?? {};
    final meta = attachmentData['meta'] ?? {};

    return MediaItem(
      id: json['id'],
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      thumb: attachmentData['thumb'] ?? '',
      duration: meta['length_formatted'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userLogin: json['user_login'] ?? null,
      userPermissions: json['user_permissions'] is Map
          ? Map<String, dynamic>.from(json['user_permissions'])
          : null,
    );
  }

  @override
  String toString() {
    return 'MediaItem(id: $id, type: $type, user: $userLogin, duration: $duration)';
  }
}