import 'package:facebook/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  @JsonKey(name: '_id')
  final String? id;
  final UserModel user;
  final String? postId;
  final String content;
  final String? image;
  @JsonKey(name: 'createdAt')
  final String time;
  @JsonKey(name: 'countChildComment')
  int countChild;

  CommentModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    required this.time,
    this.image,
    this.countChild = 0,
  });

  // Phương thức fromJson để chuyển từ JSON sang CommentModel
  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  // Phương thức toJson để chuyển từ CommentModel sang JSON
  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  // Phương thức để tăng countChild
  void incrementChildCount() {
    countChild += 1;
  }
}
