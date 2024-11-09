// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      id: json['_id'] as String?,
      postId: json['postId'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String,
      time: json['createdAt'] as String,
      image: json['image'] as String?,
      countChild: (json['countChildComment'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'postId': instance.postId,
      'content': instance.content,
      'image': instance.image,
      'createdAt': instance.time,
      'countChildComment': instance.countChild,
    };
