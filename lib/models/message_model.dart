import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'room_id')
  final String? roomId;
  @JsonKey(name: 'created_by_user')
  final String senderId;
  final UserModel? sender;

  @JsonKey(name: 'data', fromJson: ContentMess.fromJson, toJson: ContentMess.toJson)
  final ContentMess? data;

  @JsonKey(name: 'createdAt')
  final String time;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.sender,
    this.data,
    required this.time,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  bool isSender() {
    UserServicePref userServicePref = UserServicePref();
    UserModel? currentUser = userServicePref.getUserInfo;

    return senderId == currentUser!.id;
  }
}

class ContentMess {
  final String? content;
  final MessageType? type;

  ContentMess({
    required this.content,
    required this.type,
  });

  // Static fromJson and toJson methods for serialization
  static ContentMess? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ContentMess(
      content: json['content'] as String?,
      type: json['type'] != null ? MessageType.values.byName(json['type']) : null,
    );
  }

  static Map<String, dynamic>? toJson(ContentMess? instance) {
    if (instance == null) return null;
    return {
      'content': instance.content,
      'type': instance.type?.name,
    };
  }
}
