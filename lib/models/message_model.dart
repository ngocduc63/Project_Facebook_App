
import 'package:facebook/models/user_model.dart';
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
  final Map<String, dynamic>? data;
  @JsonKey(name: 'createdAt')
  final String time;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.sender,
    required this.data,
    required this.time,
  });

   factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
