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
