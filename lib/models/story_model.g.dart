// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryModel _$StoryModelFromJson(Map<String, dynamic> json) => StoryModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      id: json['_id'] as String,
      listStory: (json['listStory'] as List<dynamic>)
          .map((e) => StoryDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastStory:
          StoryDetailModel.fromJson(json['lastStory'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoryModelToJson(StoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'listStory': instance.listStory,
      'lastStory': instance.lastStory,
    };
