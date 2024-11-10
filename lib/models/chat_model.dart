import 'package:facebook/models/message_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  @JsonKey(name: '_id')
  final String? id;
  final UserModel friend;
  @JsonKey(name: 'room_name')
  final String? name;
  @JsonKey(name: 'last_message_data')
  final MessageModel? lastMessage;
  @JsonKey(name: 'sender_by_user')
  final String? userSendLastMessage;
  final bool watched;
  @JsonKey(name: 'createdAt')
  final String time;
  @JsonKey(name: 'updatedAt')
  final String timeUpdate;

  ChatModel({
    required this.id,
    required this.friend,
    required this.name,
    this.lastMessage,
    this.userSendLastMessage,
    required this.watched,
    required this.time,
    required this.timeUpdate,
    
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
