// emotion.dart
enum Emotion {
  like('LIKE'),
  haha('HAHA'),
  sad('SAD'),
  love('LOVE'),
  lovelove('LOVELOVE'),
  angry('ANGRY'),
  wow('WOW'),
  none('none');

  final String value;

  const Emotion(this.value);

  static Emotion? fromString(String? value) {
    if (value == null) return null;
    return Emotion.values.firstWhere(
      (emotion) => emotion.value == value,
      orElse: () => Emotion.like,
    );
  }
}

enum PostStatus {
  friend('FRIEND'),
  public('PUBLIC'),
  private('PRIVATE');

  final String value;

  const PostStatus(this.value);

  static PostStatus? fromString(String? value) {
    if (value == null) return null;
    return PostStatus.values.firstWhere(
      (postStatus) => postStatus.value == value,
      orElse: () => PostStatus.public,
    );
  }
}

enum MessageType {
  text('text'),
  audio('audio'),
  image('image'),
  video('video'),
  noti('noti');

  final String value;

  const MessageType(this.value);

  static MessageType? fromString(String? value) {
    if (value == null) return null;
    return MessageType.values.firstWhere(
      (messageType) => messageType.value == value,
      orElse: () => MessageType.text,
    );
  }
}

enum FriendStatus {
  friend('FRIEND'),
  follow('FOLLOW'),
  unfriend('UNFRIEND'),
  waitAcp('WAIT_ACCEPT');
  final String value;

  const FriendStatus(this.value);

  static FriendStatus? fromString(String? value) {
    if (value == null) return null;
    return FriendStatus.values.firstWhere(
      (emotion) => emotion.value == value,
      orElse: () => FriendStatus.unfriend,
    );
  }
}

enum NotificationType {
  createPost('POST-001'),
  likePost('POST-002'),
  commentPost('POST-003'),
  sharePost('POST-004'),
  addFriend('FRIEND-001'),
  acpFriend('FRIEND-002');
  final String value;

  const NotificationType(this.value);
}