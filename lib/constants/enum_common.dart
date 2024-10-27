// emotion.dart
enum Emotion {
  like('LIKE'),
  haha('HAHA'),
  sad('SAD'),
  love('LOVE'),
  lovelove('LOVELOVE'),
  angry('ANGRY'),
  wow('WOW');

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
