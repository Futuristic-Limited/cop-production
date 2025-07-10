class GroupDocument {
  final int id;
  final String groupName;
  final String userLogin;
  final String displayName;
  final DocumentItem document;
  final String dateCreated;
  final String privacy;
  final String visibility;
  final String type;

  GroupDocument({
    required this.id,
    required this.groupName,
    required this.userLogin,
    required this.displayName,
    required this.document,
    required this.dateCreated,
    required this.privacy,
    required this.visibility,
    required this.type,
  });

  factory GroupDocument.fromJson(Map<String, dynamic> json) {
    return GroupDocument(
      id: json['id'],
      groupName: json['group_name'] ?? '',
      userLogin: json['user_login'] ?? '',
      displayName: json['display_name'] ?? '',
      dateCreated: json['date_created'] ?? '',
      privacy: json['privacy'] ?? '',
      visibility: json['visibility'] ?? '',
      type: json['type'] ?? '',
      document: DocumentItem.fromJson(json),
    );
  }
}

class DocumentItem {
  final int id;
  final String title;
  final String type;
  final String extension;
  final String extensionDescription;
  final String url;
  final String downloadUrl;
  final String size;
  final String filename;
  final String? thumbnailUrl;
  final Map<String, dynamic>? userPermissions;

  DocumentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.extension,
    required this.extensionDescription,
    required this.url,
    required this.downloadUrl,
    required this.size,
    required this.filename,
    this.thumbnailUrl,
    this.userPermissions,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    final attachmentData = json['attachment_data'] ?? {};
    final thumb = attachmentData['thumb'] ??
        attachmentData['activity_thumb'] ??
        attachmentData['activity_thumb_pdf'] ?? '';

    return DocumentItem(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      extension: json['extension'] ?? '',
      extensionDescription: json['extension_description'] ?? '',
      url: json['url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      size: json['size'] ?? '',
      filename: json['filename'] ?? '',
      thumbnailUrl: thumb,
      userPermissions: json['user_permissions'] is Map
          ? Map<String, dynamic>.from(json['user_permissions'])
          : null,
    );
  }

  @override
  String toString() {
    return 'DocumentItem(id: $id, title: $title, type: $type, extension: $extension, size: $size)';
  }
}