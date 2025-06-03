class DiscussionsResponse {
  final List<Discussions>? items;
  final String? error;

  DiscussionsResponse({this.items, this.error});

  factory DiscussionsResponse.fromJson(dynamic json) {
    if (json is List) {
      return DiscussionsResponse(
        items: json.map((e) => Discussions.fromJson(e)).toList(),
      );
    } else if (json is Map && json.containsKey('error')) {
      return DiscussionsResponse(error: json['error']);
    } else {
      return DiscussionsResponse(items: []);
    }
  }
}

class Discussions {
  final String? ID;
  final String? post_author;
  final String? post_date;
  final String? post_content;
  final String? post_title;
  final String? guid;
  final String? display_name;
  final String? error;
  final String? message;
  final String? reply_count;
  final String? last_reply_date;
  final List<Discussions> children;
  final String post_parent;

  Discussions({
    this.ID,
    this.post_author,
    this.post_date,
    this.post_content,
    this.post_title,
    this.guid,
    this.display_name,
    this.error,
    this.message,
    this.reply_count,
    this.last_reply_date,
    required this.children,
    required this.post_parent,
  });

  factory Discussions.fromJson(Map<String, dynamic> json) {
    return Discussions(
      ID: json['ID'],
      post_author: json['post_author'],
      post_date: json['post_date'],
      post_content: json['post_content'],
      post_title: json['post_title'],
      guid: json['guid'],
      display_name: json['display_name'],
      error: json['error'],
      message: json['message'],
      reply_count: json['reply_count'],
      last_reply_date: json['last_reply_date'],
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => Discussions.fromJson(child))
          .toList() ??
          [],
        post_parent:json['post_parent'],
    );
  }
}
