// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['_id'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      time: json['createdAt'] as String,
      image: (json['post_image'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      video: (json['post_video'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      content: json['post_title'] as String?,
      checkin: json['checkin'] as String?,
      reaction: $enumDecodeNullable(_$EmotionEnumMap, json['likeCategory']),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      layout: json['layout'] as String?,
      type: json['post_type'] as String?,
      hasLiked: json['hasLiked'] as bool?,
      isFriend: json['isFriend'] as bool?,
      numComment: (json['post_num_comment'] as num?)?.toInt(),
      numLike: (json['post_num_like'] as num?)?.toInt(),
      numShare: (json['post_num_share'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'createdAt': instance.time,
      'post_image': instance.image,
      'post_video': instance.video,
      'post_title': instance.content,
      'checkin': instance.checkin,
      'likeCategory': _$EmotionEnumMap[instance.reaction],
      'reactions': instance.reactions,
      'layout': instance.layout,
      'post_type': instance.type,
      'hasLiked': instance.hasLiked,
      'isFriend': instance.isFriend,
      'post_num_like': instance.numLike,
      'post_num_comment': instance.numComment,
      'post_num_share': instance.numShare,
    };

const _$EmotionEnumMap = {
  Emotion.like: 'LIKE',
  Emotion.haha: 'HAHA',
  Emotion.sad: 'SAD',
  Emotion.love: 'LOVE',
  Emotion.lovelove: 'LOVELOVE',
  Emotion.angry: 'ANGRY',
  Emotion.wow: 'WOW',
  Emotion.none: 'none',
};
