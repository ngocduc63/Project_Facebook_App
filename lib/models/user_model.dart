import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';
// flutter pub run build_runner build

@JsonSerializable()
class UserModel {
  // @JsonKey(name: '_id')
  // final String id;
  final String name;
  final String avatar;
  bool? verified;
  final String? cover;
  final int? friends;
  final int? likes;
  final int? followers;
  final String? hometown;
  final String? bio;
  final String? type;
  final bool? guard;
  final String? pageType;
  final String? address;
  UserModel({
    // required this.id,
    required this.name,
    required this.avatar,
    this.verified,
    this.cover,
    this.friends,
    this.likes,
    this.followers,
    this.hometown,
    this.bio,
    this.type,
    this.guard,
    this.pageType,
    this.address,
  });

  // Phương thức fromJson để chuyển từ JSON sang UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // Phương thức toJson để chuyển từ UserModel sang JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    // String? id,
    String? name,
    String? avatar,
    bool? verified,
    String? cover,
    int? friends,
    int? likes,
    int? followers,
    String? hometown,
    String? bio,
    String? type,
    bool? guard,
    String? pageType,
    String? address,
  }) {
    return UserModel(
      // id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      verified: verified ?? this.verified,
      cover: cover ?? this.cover,
      friends: friends ?? this.friends,
      likes: likes ?? this.likes,
      followers: followers ?? this.followers,
      bio: bio ?? this.bio,
      type: type ?? this.type,
      guard: guard ?? this.guard,
      pageType: pageType ?? this.pageType,
      address: address ?? this.address,
    );
  }
}
