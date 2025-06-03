import 'groups_model.dart';

class User {
  final String? email;
  final String? name;
  final String? avatar;
  final String? joined;
  final String? active;
  final String? userNicename;
  final int? followers;
  final int? following;
  final String? error;
  final String? accessToken;
  final List<Group>? joinedGroups; // 👈 NEW FIELD

  User({
    this.email,
    this.name,
    this.avatar,
    this.joined,
    this.active,
    this.userNicename,
    this.followers,
    this.following,
    this.error,
    this.accessToken,
    this.joinedGroups,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      joined: json['joined'],
      active: json['active'],
      userNicename: json['user_nicename'],
      followers: json['followers'],
      following: json['following'],
      error: json['error'],
      accessToken: json['access_token'],
      joinedGroups: json['joined_groups'] != null
          ? (json['joined_groups'] as List)
          .map((groupJson) => Group.fromJoinedJson(groupJson))
          .toList()
          : null,
    );
  }
}