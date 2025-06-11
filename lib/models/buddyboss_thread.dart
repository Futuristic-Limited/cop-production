import 'package:json_annotation/json_annotation.dart';

part 'buddyboss_thread.g.dart';

@JsonSerializable(explicitToJson: true)
class BuddyBossThread {
  final int id;
  @JsonKey(name: 'message_id')
  final int messageId;
  @JsonKey(name: 'last_sender_id')
  final int lastSenderId;
  final Subject subject;
  final Excerpt excerpt;
  final MessageContent message;
  final String date;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  @JsonKey(name: 'sender_ids')
  final Map<String, int> senderIds;
  @JsonKey(name: 'current_user')
  final int currentUser;
  @JsonKey(name: 'can_send_message')
  final bool canSendMessage;
  final List<Avatar> avatar;
  @JsonKey(name: 'is_group')
  final bool isGroup;
  @JsonKey(name: 'is_group_thread')
  final bool isGroupThread;
  @JsonKey(name: 'group_name')
  final String groupName;
  @JsonKey(name: 'group_link')
  final String groupLink;
  final Map<String, Recipient> recipients;
  @JsonKey(name: 'messages_count')
  final int messagesCount;
  final List<ThreadMessage> messages;

  BuddyBossThread({
    required this.id,
    required this.messageId,
    required this.lastSenderId,
    required this.subject,
    required this.excerpt,
    required this.message,
    required this.date,
    required this.startDate,
    required this.unreadCount,
    required this.senderIds,
    required this.currentUser,
    required this.canSendMessage,
    required this.avatar,
    required this.isGroup,
    required this.isGroupThread,
    required this.groupName,
    required this.groupLink,
    required this.recipients,
    required this.messagesCount,
    required this.messages,
  });

  factory BuddyBossThread.fromJson(Map<String, dynamic> json) =>
      _$BuddyBossThreadFromJson(json);

  Map<String, dynamic> toJson() => _$BuddyBossThreadToJson(this);
}

@JsonSerializable()
class Subject {
  final String rendered;

  Subject({required this.rendered});

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

@JsonSerializable()
class Excerpt {
  final String rendered;

  Excerpt({required this.rendered});

  factory Excerpt.fromJson(Map<String, dynamic> json) =>
      _$ExcerptFromJson(json);

  Map<String, dynamic> toJson() => _$ExcerptToJson(this);
}

@JsonSerializable()
class MessageContent {
  final String rendered;

  MessageContent({required this.rendered});

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentToJson(this);
}

@JsonSerializable()
class Avatar {
  final String full;
  final String thumb;

  Avatar({required this.full, required this.thumb});

  factory Avatar.fromJson(Map<String, dynamic> json) => _$AvatarFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarToJson(this);
}

@JsonSerializable()
class Recipient {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'user_link')
  final String userLink;
  final String name;
  @JsonKey(name: 'user_avatars')
  final UserAvatars userAvatars;

  Recipient({
    required this.id,
    required this.userId,
    required this.userLink,
    required this.name,
    required this.userAvatars,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) =>
      _$RecipientFromJson(json);

  Map<String, dynamic> toJson() => _$RecipientToJson(this);
}

@JsonSerializable()
class UserAvatars {
  final String full;
  final String thumb;

  UserAvatars({required this.full, required this.thumb});

  factory UserAvatars.fromJson(Map<String, dynamic> json) =>
      _$UserAvatarsFromJson(json);

  Map<String, dynamic> toJson() => _$UserAvatarsToJson(this);
}

@JsonSerializable()
class ThreadMessage {
  final int id;

  @JsonKey(name: 'thread_id')
  final int threadId;

  @JsonKey(name: 'sender_id')
  final int senderId;

  final Subject subject;
  final MessageContent message;

  @JsonKey(name: 'date_sent')
  final String dateSent;

  @JsonKey(name: 'sender_data')
  final SenderData senderData;

  @JsonKey(name: 'bp_media_ids')
  final List<BpMedia>? bpMediaIds;

  @JsonKey(name: 'media_gif')
  final String? mediaGif;

  @JsonKey(name: 'bp_videos')
  final List<BpMedia>? bpVideos;

  @JsonKey(name: 'bp_documents')
  final List<BpMedia>? bpDocuments;

  ThreadMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.subject,
    required this.message,
    required this.dateSent,
    required this.senderData,
    this.bpMediaIds,
    this.mediaGif,
    this.bpVideos,
    this.bpDocuments,
  });

  factory ThreadMessage.fromJson(Map<String, dynamic> json) =>
      _$ThreadMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadMessageToJson(this);
}

@JsonSerializable()
class SenderData {
  @JsonKey(name: 'sender_name')
  final String senderName;
  @JsonKey(name: 'user_avatars')
  final UserAvatars userAvatars;

  SenderData({required this.senderName, required this.userAvatars});

  factory SenderData.fromJson(Map<String, dynamic> json) =>
      _$SenderDataFromJson(json);

  Map<String, dynamic> toJson() => _$SenderDataToJson(this);
}

@JsonSerializable()
class BpMedia {
  final int id;
  @JsonKey(name: 'attachment_id')
  final int attachmentId;
  final String title;
  @JsonKey(name: 'attachment_data')
  final AttachmentData attachmentData;
  final String? url; // For viewing the image
  @JsonKey(name: 'download_url')
  final String? downloadUrl; // For downloading the image

  BpMedia({
    required this.id,
    required this.attachmentId,
    required this.title,
    required this.attachmentData,
    this.url,
    this.downloadUrl,
  });

  factory BpMedia.fromJson(Map<String, dynamic> json) =>
      _$BpMediaFromJson(json);
  Map<String, dynamic> toJson() => _$BpMediaToJson(this);
}

@JsonSerializable()
class AttachmentData {
  final String full;
  final String thumb;

  AttachmentData({required this.full, required this.thumb});

  factory AttachmentData.fromJson(Map<String, dynamic> json) =>
      _$AttachmentDataFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentDataToJson(this);
}
