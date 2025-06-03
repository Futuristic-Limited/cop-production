class FollowerData {
  final int followers;
  final int following;
  final int posts;

  FollowerData({
    required this.followers,
    required this.following,
    required this.posts,
  });

  factory FollowerData.fromJson(Map<String, dynamic> json) {
    return FollowerData(
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      posts: json['posts'] ?? 0,
    );
  }
}
