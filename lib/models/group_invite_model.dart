class GroupInvite {
  final int invitationId;
  final DateTime dateModified;
  final bool inviteSent;
  final bool accepted;
  final String content;
  final int groupId;
  final String groupName;
  final String groupSlug;
  final String groupDescription;
  final int inviterId;
  final String inviterName;
  final String inviterEmail;
  final String groupImage;

  GroupInvite({
    required this.invitationId,
    required this.dateModified,
    required this.inviteSent,
    required this.accepted,
    required this.content,
    required this.groupId,
    required this.groupName,
    required this.groupSlug,
    required this.groupDescription,
    required this.inviterId,
    required this.inviterName,
    required this.inviterEmail,
    required this.groupImage,
  });

  factory GroupInvite.fromJson(Map<String, dynamic> json) {
    return GroupInvite(
      invitationId: int.tryParse(json['invitation_id'].toString()) ?? 0,
      dateModified: DateTime.tryParse(json['date_modified'] ?? '') ?? DateTime.now(),
      inviteSent: json['invite_sent'].toString() == "1",
      accepted: json['accepted'].toString() == "1",
      content: json['content'] ?? '',
      groupId: int.tryParse(json['group_id'].toString()) ?? 0,
      groupName: json['group_name'] ?? '',
      groupSlug: json['group_slug'] ?? '',
      groupDescription: json['group_description'] ?? '',
      inviterId: int.tryParse(json['inviter_id'].toString()) ?? 0,
      inviterName: json['inviter_name'] ?? '',
      inviterEmail: json['inviter_email'] ?? '',
      groupImage: json['group_image'] ?? '',
    );
  }
}