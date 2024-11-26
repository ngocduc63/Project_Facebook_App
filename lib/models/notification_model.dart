import 'package:facebook/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotiModel {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'noti_content')
  final String content;
  @JsonKey(name: 'createdAt')
  final String time;
  @JsonKey(name: 'noti_type')
  final String type;
  @JsonKey(name: 'noti_sender')
  final UserModel sender;
  @JsonKey(name: 'noti_options')
  final Map<String, dynamic>? options;
  NotiModel({
    required this.id,
    required this.content,
    required this.time,
    required this.type,
    required this.sender,
    this.options
  });

  factory NotiModel.fromJson(Map<String, dynamic> json) =>
      _$NotiModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotiModelToJson(this);
}


/* NOTIFICATIONS TYPES:

1. page
2. group
3. comment
4. friend
5. security
6. date
7. badge
8-14: reactions: like, haha, love, lovelove, sad, wow, angry
15: memory
 */
