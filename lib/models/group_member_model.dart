class GroupMember {
  final int id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final int followersCount;
  String followStatus; // 'follow' or 'unfollow'

  GroupMember({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.followersCount,
    required this.followStatus,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    String status = (json['is_following'] == true) ? 'unfollow' : 'follow';

    return GroupMember(
      id: int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['user_login'] ?? '',
      displayName: json['display_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      followersCount: json['followers_count'] ?? 0,
      followStatus: status,
    );
  }
}
