import 'package:facebook/constants/enum_common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'story_detail_model.g.dart';

@JsonSerializable()
class StoryDetailModel {
  @JsonKey(name: '_id')
  final String id;
   @JsonKey(name: 'story_title')
  final String title;
  @JsonKey(name: 'story_image')
  final String? image;
  @JsonKey(name: 'story_video')
  final String? video;
  @JsonKey(name: 'createdAt')
  final String time;
  @JsonKey(name: 'story_status')
  final PostStatus shareWith;
  StoryDetailModel({
    required this.id,
    required this.title,
    this.image,
    this.video,
    required this.time,
    required this.shareWith,
  });

  factory StoryDetailModel.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryDetailModelToJson(this);

}
