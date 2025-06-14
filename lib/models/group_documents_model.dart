class GroupActivityDocument {
  final int id;
  final String groupName;
  final List<DocumentItem> documents;

  GroupActivityDocument({
    required this.id,
    required this.groupName,
    required this.documents,
  });

  factory GroupActivityDocument.fromJson(Map<String, dynamic> json) {
    return GroupActivityDocument(
      id: json['id'],
      groupName: json['activity_data']['group_name'] ?? '',
      documents: json['bp_documents'] != null
          ? List<DocumentItem>.from(json['bp_documents'].map((d) => DocumentItem.fromJson(d)))
          : [],
    );
  }
}
class DocumentItem {
  final int id;
  final String title;
  final String type;
  final String extension;
  final String url;
  final String size;
  final DateTime date;
  final String userLogin;

  DocumentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.extension,
    required this.url,
    required this.size,
    required this.date,
    required this.userLogin,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'],
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      extension: json['extension'] ?? '',
      url: json['download_url'] ?? '',
      size: json['size'] ?? '',
      date: DateTime.parse(json['date_created']),
      userLogin: json['user_login'] ?? '',
    );
  }

  @override
  String toString() {
    return 'DocumentItem(id: $id, title: $title, type: $type, extension: $extension, size: $size, url: $url, date: $date, userLogin: $userLogin)';
  }
}
