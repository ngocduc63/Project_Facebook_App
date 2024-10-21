// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      // id: json['_id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      verified: json['verified'] as bool?,
      cover: json['cover'] as String?,
      friends: (json['friends'] as num?)?.toInt(),
      likes: (json['likes'] as num?)?.toInt(),
      followers: (json['followers'] as num?)?.toInt(),
      hometown: json['hometown'] as String?,
      bio: json['bio'] as String?,
      type: json['type'] as String?,
      guard: json['guard'] as bool?,
      pageType: json['pageType'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      // '_id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
      'verified': instance.verified,
      'cover': instance.cover,
      'friends': instance.friends,
      'likes': instance.likes,
      'followers': instance.followers,
      'hometown': instance.hometown,
      'bio': instance.bio,
      'type': instance.type,
      'guard': instance.guard,
      'pageType': instance.pageType,
      'address': instance.address,
    };
