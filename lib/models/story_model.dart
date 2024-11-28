import 'package:facebook/models/story_detail_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'story_model.g.dart';

@JsonSerializable()
class StoryModel {
  @JsonKey(name: '_id')
  final String id;
  final UserModel user;
  final List<StoryDetailModel> listStory;
  final StoryDetailModel lastStory;
  StoryModel({
    required this.user,
    required this.id, 
    required this.listStory, 
    required this.lastStory, 
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryModelToJson(this);

  int get numImages {
    return listStory.where((story) => story.image!.isNotEmpty).length;
  }

  int get numVideos {
    return listStory.where((story) => story.video!.isNotEmpty).length;
  }
}
