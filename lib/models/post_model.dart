import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  @JsonKey(name: '_id')
  final String id;
  final UserModel user;
  @JsonKey(name: 'createdAt')
  final String time;
  @JsonKey(name: 'post_image')
  final List<String>? image;
  @JsonKey(name: 'post_video')
  final List<String>? video;
  @JsonKey(name: 'post_title')
  final String? content;
  // final List<String>? text;
  final String? checkin;
  @JsonKey(name: 'likeCategory')
  final Emotion? reaction;
  final List<Map<String, dynamic>>? reactions;
  final String? layout; // classic, column, quote, frame
  @JsonKey(name: 'post_type')
  final String? type; 
  final bool? hasLiked;
  final bool? isFriend;
  @JsonKey(name: 'post_num_like')
  final int? numLike;
  @JsonKey(name: 'post_num_comment')
  final int? numComment;
  @JsonKey(name: 'post_num_share')
  final int? numShare;
  @JsonKey(name: 'post_status')
  final PostStatus? shareWith;

  PostModel({
    required this.id,
    required this.user,
    required this.time,
    this.image,
    this.video,
    this.content,
    // this.text,
    this.checkin,
    this.reaction,
    this.reactions,
    this.layout,
    this.type,
    this.hasLiked,
    this.isFriend,
    this.numComment,
    this.numLike,
    this.numShare,
    this.shareWith
  });

  // Phương thức fromJson để chuyển từ JSON sang PostModel
  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  // Phương thức toJson để chuyển từ PostModel sang JSON
  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostModel copyWith({
    String? id,
    UserModel? user,
    String? time,
    List<String>? image,
    List<String>? video,
    String? content,
    List<String>? text,
    String? checkin,
    Emotion? reaction,
    String? layout,
    String? type,
    bool? hasLiked,
    bool? isFriend,
    int? numComment,
    int? numLike,
    int? numShare,
    PostStatus? shareWith,

  }) {
    return PostModel(
      id: id ?? this.id,
      user: user ?? this.user,
      time: time ?? this.time,
      image: image ?? this.image,
      video: video ?? this.video,
      content: content ?? this.content,
      // text: text ?? this.text,
      checkin: checkin ?? this.checkin,
      reaction: reaction ?? this.reaction,
      layout: layout ?? this.layout,
      type: type ?? this.type,
      hasLiked: hasLiked ?? this.hasLiked,
      isFriend: isFriend ?? this.isFriend,
      numLike: numLike ?? this.numLike,
      numComment: numComment ?? this.numComment,
      numShare: numShare ?? this.numShare,
      shareWith: shareWith ?? this.shareWith,
    );
  }
}
