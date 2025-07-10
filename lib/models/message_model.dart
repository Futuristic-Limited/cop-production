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
      threadId: json['thread_id']?.toString() ?? '',
      latestMessage: json['latest_message']?.toString() ?? '',
      latestSubject: json['latest_subject']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      participantId: json['participant_id']?.toString() ?? '',
      participantName: json['participant_name']?.toString() ?? '',
      participantAvatar: json['participant_avatar']?.toString(),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      latestDateSent: DateTime.tryParse(json['latest_date_sent']?.toString() ?? '') ?? DateTime.now(),
      isYou: json['is_you'] == true || json['is_you']?.toString() == 'true',
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
      id: json['id']?.toString() ?? '',
      threadId: json['thread_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      dateSent: json['date_sent']?.toString() ?? '',
      isDeleted: json['is_deleted']?.toString() ?? '0',
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
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      previewUrl: json['preview_url']?.toString() ?? '',
      downloadUrl: json['download_url']?.toString() ?? '',
      mimeType: json['mime_type']?.toString() ?? '',
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
      id: json['ID']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      senderAvatar: json['sender_avatar']?.toString() ?? '',
    );
  }
}

class UsersResponse {
  final String status;
  final List<User> users;

  UsersResponse({required this.status, required this.users});

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    var usersJson = json['users'] as List<dynamic>? ?? [];
    List<User> userList = usersJson.map((u) => User.fromJson(u)).toList();

    return UsersResponse(
      status: json['status']?.toString() ?? 'error',
      users: userList,
    );
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
      id: json['id']?.toString() ?? '',
      email: json['invitee_email']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      dateModified: json['date_modified']?.toString() ?? '',
      accepted: json['accepted'] == '1' || json['accepted'] == 1 || json['accepted'] == true,
    );
  }
}

class UploadedAttachment {
  final int attachmentId;
  final int messageMetaId;

  UploadedAttachment({
    required this.attachmentId,
    required this.messageMetaId,
  });

  // Optional: Add .fromJson if needed
  factory UploadedAttachment.fromJson(Map<String, dynamic> json) {
    return UploadedAttachment(
      attachmentId: int.tryParse(json['attachment_id']?.toString() ?? '0') ?? 0,
      messageMetaId: int.tryParse(json['message_meta_id']?.toString() ?? '0') ?? 0,
    );
  }
}
