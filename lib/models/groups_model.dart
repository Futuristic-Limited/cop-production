class Group {
  final int id;
  final String name;
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
      description: '', // Not available in this response
      avatarUrl: json['group_image'],
      dateCreated: json['date_created'],
      lastActive: null,
      memberCount: 0, // Not provided
      status: null,
      isMember: true,
    );
  }
}