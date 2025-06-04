class GroupMember {
  final int id;
  final String username;
  final String displayName;
  final String avatarUrl;
  bool isFollowing;

  GroupMember({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.isFollowing,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      isFollowing: json['isFollowing'] as bool,
    );
  }
}
