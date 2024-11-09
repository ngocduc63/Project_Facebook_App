// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['_id'] as String?,
      roomId: json['room_id'] as String?,
      senderId: json['created_by_user'] as String,
      sender: json['sender'] == null
          ? null
          : UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      data: json['data'] as Map<String, dynamic>?,
      time: json['createdAt'] as String,
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'room_id': instance.roomId,
      'created_by_user': instance.sender,
      'data': instance.data,
      'createdAt': instance.time,
    };
