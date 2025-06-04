class Group {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? avatarUrl;
  final String? lastActive;
  final int? memberCount;
  final String? status; // public/private
  final bool? isMember;
  final String? dateCreated; // OPTIONAL

  Group({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.avatarUrl,
    this.lastActive,
    this.memberCount,
    this.status,
    this.isMember,
    this.dateCreated,
  });

  factory Group.fromJoinedJson(Map<String, dynamic> json) {
    return Group(
      id: int.tryParse(json['group_id'].toString()) ?? 0,
      name: json['group_name'] ?? '',
      slug: json['group_slug'] ?? '',
      description: json['group_description'], // Not available in this response
      avatarUrl: json['group_image'],
      dateCreated: json['date_created'],
      lastActive: null,
      memberCount: 0, // Not provided
      status: null,
      isMember: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'avatarUrl': avatarUrl,
      'lastActive': lastActive,
      'memberCount': memberCount,
      'status': status,
      'isMember': isMember,
      'dateCreated': dateCreated,
    };
  }
}
