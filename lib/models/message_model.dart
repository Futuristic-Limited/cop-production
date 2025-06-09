class MessageThread {
  final String threadId;
  final String latestMessage;
  final String latestSubject;
  final String senderId;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final int unreadCount;
  final DateTime latestDateSent;
  final bool isYou;

  MessageThread({
    required this.threadId,
    required this.latestMessage,
    required this.latestSubject,
    required this.senderId,
    required this.participantId,
    required this.participantName,
    required this.participantAvatar,
    required this.unreadCount,
    required this.latestDateSent,
    required this.isYou,
  });

  factory MessageThread.fromJson(Map<String, dynamic> json) {
    return MessageThread(
      threadId: json['thread_id'],
      latestMessage: json['latest_message'],
      latestSubject: json['latest_subject'],
      senderId: json['sender_id'],
      participantId: json['participant_id'],
      participantName: json['participant_name'],
      participantAvatar: json['participant_avatar'],
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      latestDateSent: DateTime.parse(json['latest_date_sent']),
      isYou: json['is_you'] == true || json['is_you'] == 'true',
    );
  }
}

class Message {
  final String id;
  final String threadId;
  final String senderId;
  final String subject;
  final String message;
  final String dateSent;
  final String isDeleted;
  final List<Attachment> attachments;

  Message({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.subject,
    required this.message,
    required this.dateSent,
    required this.isDeleted,
    required this.attachments,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    var attachmentsJson = json['attachments'] as List<dynamic>? ?? [];
    List<Attachment> attachmentsList =
        attachmentsJson.map((e) => Attachment.fromJson(e)).toList();

    return Message(
      id: json['id'],
      threadId: json['thread_id'],
      senderId: json['sender_id'],
      subject: json['subject'],
      message: json['message'],
      dateSent: json['date_sent'],
      isDeleted: json['is_deleted'],
      attachments: attachmentsList,
    );
  }
}

class Attachment {
  final String id;
  final String type;
  final String title;
  final String previewUrl;
  final String downloadUrl;
  final String mimeType;

  Attachment({
    required this.id,
    required this.type,
    required this.title,
    required this.previewUrl,
    required this.downloadUrl,
    required this.mimeType,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      previewUrl: json['preview_url'],
      downloadUrl: json['download_url'],
      mimeType: json['mime_type'],
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String userEmail;
  final String senderAvatar;

  User({
    required this.id,
    required this.fullName,
    required this.userEmail,
    required this.senderAvatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['ID'].toString(), // Ensure it's treated as a string
      fullName: json['full_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      senderAvatar: json['sender_avatar'] ?? '',
    );
  }
}

class UsersResponse {
  final String status;
  final List<User> users;

  UsersResponse({required this.status, required this.users});

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    var usersJson = json['users'] as List;
    List<User> userList = usersJson.map((u) => User.fromJson(u)).toList();

    return UsersResponse(status: json['status'], users: userList);
  }
}

class Invite {
  final String id;
  final String email;
  final String content;
  final String dateModified;
  final bool accepted;

  Invite({
    required this.id,
    required this.email,
    required this.content,
    required this.dateModified,
    required this.accepted,
  });

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'],
      email: json['invitee_email'],
      content: json['content'],
      dateModified: json['date_modified'],
      accepted: json['accepted'] == '1',
    );
  }
}

class UploadedAttachment {
  final int attachmentId;
  final int messageMetaId;

  UploadedAttachment({required this.attachmentId, required this.messageMetaId});
}
