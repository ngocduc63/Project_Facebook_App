// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryDetailModel _$StoryDetailModelFromJson(Map<String, dynamic> json) =>
    StoryDetailModel(
      id: json['_id'] as String,
      title: json['story_title'] as String,
      image: json['story_image'] as String?,
      video: json['story_video'] as String?,
      time: json['createdAt'] as String,
      shareWith: $enumDecode(_$PostStatusEnumMap, json['story_status']),
    );

Map<String, dynamic> _$StoryDetailModelToJson(StoryDetailModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'story_title': instance.title,
      'story_image': instance.image,
      'story_video': instance.video,
      'createdAt': instance.time,
      'story_status': _$PostStatusEnumMap[instance.shareWith]!,
    };

const _$PostStatusEnumMap = {
  PostStatus.friend: 'FRIEND',
  PostStatus.public: 'PUBLIC',
  PostStatus.private: 'PRIVATE',
};
