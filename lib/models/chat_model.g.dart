// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
      id: json['_id'] as String?,
      friend: UserModel.fromJson(json['friend'] as Map<String, dynamic>),
      name: json['room_name'] as String?,
      lastMessage: json['last_message_data'] == null
          ? null
          : MessageModel.fromJson(
              json['last_message_data'] as Map<String, dynamic>),
      userSendLastMessage: json['sender_by_user'] as String?,
      watched: json['watched'] as bool,
      time: json['createdAt'] as String,
      timeUpdate: json['updatedAt'] as String,
    );

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      '_id': instance.id,
      'friend': instance.friend,
      'room_name': instance.name,
      'last_message_data': instance.lastMessage,
      'sender_by_user': instance.userSendLastMessage,
      'watched': instance.watched,
      'createdAt': instance.time,
      'updatedAt': instance.timeUpdate,
    };
