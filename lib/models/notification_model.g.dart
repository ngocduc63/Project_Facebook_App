// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotiModel _$NotiModelFromJson(Map<String, dynamic> json) => NotiModel(
      id: json['_id'] as String,
      content: json['noti_content'] as String,
      time: json['createdAt'] as String,
      type: json['noti_type'] as String,
      sender: UserModel.fromJson(json['noti_sender'] as Map<String, dynamic>),
      options: json['noti_options'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotiModelToJson(NotiModel instance) => <String, dynamic>{
      '_id': instance.id,
      'noti_content': instance.content,
      'createdAt': instance.time,
      'noti_type': instance.type,
      'noti_sender': instance.sender,
      'noti_options': instance.options,
    };
