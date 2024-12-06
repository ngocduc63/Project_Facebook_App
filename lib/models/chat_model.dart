import 'package:facebook/models/message_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  @JsonKey(name: '_id')
  final String? id;
  final List<UserModel> membersInfo;
  @JsonKey(name: 'room_name')
  final String? name;
  @JsonKey(name: 'last_message_data')
  final MessageModel? lastMessage;
  @JsonKey(name: 'sender_by_user')
  final String? userSendLastMessage;
  @JsonKey(name: 'image_room')
  final String? image;
  final bool watched;
  @JsonKey(name: 'createdAt')
  final String time;
  @JsonKey(name: 'updatedAt')
  final String timeUpdate;

  ChatModel({
    required this.id,
    required this.membersInfo,
    required this.name,
    this.lastMessage,
    this.image,
    this.userSendLastMessage,
    required this.watched,
    required this.time,
    required this.timeUpdate,
    
  });

  UserModel get friend {
    UserModel? currentUser = UserServicePref.instance.getUserInfo;
    
    return membersInfo[0].id == currentUser.id ? membersInfo[1] : membersInfo[0];
  }

  get isGroup {
    return name != null && name!.isNotEmpty;
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
