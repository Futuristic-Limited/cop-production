// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddyboss_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuddyBossThread _$BuddyBossThreadFromJson(Map<String, dynamic> json) =>
    BuddyBossThread(
      id: (json['id'] as num).toInt(),
      messageId: (json['message_id'] as num).toInt(),
      lastSenderId: (json['last_sender_id'] as num).toInt(),
      subject: Subject.fromJson(json['subject'] as Map<String, dynamic>),
      excerpt: Excerpt.fromJson(json['excerpt'] as Map<String, dynamic>),
      message: MessageContent.fromJson(json['message'] as Map<String, dynamic>),
      date: json['date'] as String,
      startDate: json['start_date'] as String,
      unreadCount: (json['unread_count'] as num).toInt(),
      senderIds: Map<String, int>.from(json['sender_ids'] as Map),
      currentUser: (json['current_user'] as num).toInt(),
      canSendMessage: json['can_send_message'] as bool,
      avatar:
          (json['avatar'] as List<dynamic>)
              .map((e) => Avatar.fromJson(e as Map<String, dynamic>))
              .toList(),
      isGroup: json['is_group'] as bool,
      isGroupThread: json['is_group_thread'] as bool,
      groupName: json['group_name'] as String,
      groupLink: json['group_link'] as String,
      recipients: (json['recipients'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Recipient.fromJson(e as Map<String, dynamic>)),
      ),
      messagesCount: (json['messages_count'] as num).toInt(),
      messages:
          (json['messages'] as List<dynamic>)
              .map((e) => ThreadMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$BuddyBossThreadToJson(BuddyBossThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message_id': instance.messageId,
      'last_sender_id': instance.lastSenderId,
      'subject': instance.subject.toJson(),
      'excerpt': instance.excerpt.toJson(),
      'message': instance.message.toJson(),
      'date': instance.date,
      'start_date': instance.startDate,
      'unread_count': instance.unreadCount,
      'sender_ids': instance.senderIds,
      'current_user': instance.currentUser,
      'can_send_message': instance.canSendMessage,
      'avatar': instance.avatar.map((e) => e.toJson()).toList(),
      'is_group': instance.isGroup,
      'is_group_thread': instance.isGroupThread,
      'group_name': instance.groupName,
      'group_link': instance.groupLink,
      'recipients': instance.recipients.map((k, e) => MapEntry(k, e.toJson())),
      'messages_count': instance.messagesCount,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

Subject _$SubjectFromJson(Map<String, dynamic> json) =>
    Subject(rendered: json['rendered'] as String);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'rendered': instance.rendered,
};

Excerpt _$ExcerptFromJson(Map<String, dynamic> json) =>
    Excerpt(rendered: json['rendered'] as String);

Map<String, dynamic> _$ExcerptToJson(Excerpt instance) => <String, dynamic>{
  'rendered': instance.rendered,
};

MessageContent _$MessageContentFromJson(Map<String, dynamic> json) =>
    MessageContent(rendered: json['rendered'] as String);

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{'rendered': instance.rendered};

Avatar _$AvatarFromJson(Map<String, dynamic> json) =>
    Avatar(full: json['full'] as String, thumb: json['thumb'] as String);

Map<String, dynamic> _$AvatarToJson(Avatar instance) => <String, dynamic>{
  'full': instance.full,
  'thumb': instance.thumb,
};

Recipient _$RecipientFromJson(Map<String, dynamic> json) => Recipient(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  userLink: json['user_link'] as String,
  name: json['name'] as String,
  userAvatars: UserAvatars.fromJson(
    json['user_avatars'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RecipientToJson(Recipient instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'user_link': instance.userLink,
  'name': instance.name,
  'user_avatars': instance.userAvatars,
};

UserAvatars _$UserAvatarsFromJson(Map<String, dynamic> json) =>
    UserAvatars(full: json['full'] as String, thumb: json['thumb'] as String);

Map<String, dynamic> _$UserAvatarsToJson(UserAvatars instance) =>
    <String, dynamic>{'full': instance.full, 'thumb': instance.thumb};

ThreadMessage _$ThreadMessageFromJson(Map<String, dynamic> json) =>
    ThreadMessage(
      id: (json['id'] as num).toInt(),
      threadId: (json['thread_id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      subject: Subject.fromJson(json['subject'] as Map<String, dynamic>),
      message: MessageContent.fromJson(json['message'] as Map<String, dynamic>),
      dateSent: json['date_sent'] as String,
      senderData: SenderData.fromJson(
        json['sender_data'] as Map<String, dynamic>,
      ),
      bpMediaIds:
          (json['bp_media_ids'] as List<dynamic>?)
              ?.map((e) => BpMedia.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ThreadMessageToJson(ThreadMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'thread_id': instance.threadId,
      'sender_id': instance.senderId,
      'subject': instance.subject,
      'message': instance.message,
      'date_sent': instance.dateSent,
      'sender_data': instance.senderData,
      'bp_media_ids': instance.bpMediaIds,
    };

SenderData _$SenderDataFromJson(Map<String, dynamic> json) => SenderData(
  senderName: json['sender_name'] as String,
  userAvatars: UserAvatars.fromJson(
    json['user_avatars'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SenderDataToJson(SenderData instance) =>
    <String, dynamic>{
      'sender_name': instance.senderName,
      'user_avatars': instance.userAvatars,
    };

BpMedia _$BpMediaFromJson(Map<String, dynamic> json) => BpMedia(
  id: (json['id'] as num).toInt(),
  attachmentId: (json['attachment_id'] as num).toInt(),
  title: json['title'] as String,
  attachmentData: AttachmentData.fromJson(
    json['attachment_data'] as Map<String, dynamic>,
  ),
  url: json['url'] as String,
  downloadUrl: json['download_url'] as String,
);

Map<String, dynamic> _$BpMediaToJson(BpMedia instance) => <String, dynamic>{
  'id': instance.id,
  'attachment_id': instance.attachmentId,
  'title': instance.title,
  'attachment_data': instance.attachmentData,
  'url': instance.url,
  'download_url': instance.downloadUrl,
};

AttachmentData _$AttachmentDataFromJson(Map<String, dynamic> json) =>
    AttachmentData(
      full: json['full'] as String,
      thumb: json['thumb'] as String,
    );

Map<String, dynamic> _$AttachmentDataToJson(AttachmentData instance) =>
    <String, dynamic>{'full': instance.full, 'thumb': instance.thumb};
