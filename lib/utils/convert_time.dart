import 'package:intl/intl.dart';

String convertToTimeAgo(String isoDateString) {
  DateTime dateTime = DateTime.parse(isoDateString);
  Duration difference = DateTime.now().difference(dateTime);
  String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'vi').format(dateTime);

  if (difference.inDays > 365) {
    return formattedDate;
  } else if (difference.inDays > 30) {
    int months = difference.inDays ~/ 30;
    return '$months tháng trước';
  } else if (difference.inDays > 7) {
    int weeks = difference.inDays ~/ 7;
    return '$weeks tuần trước';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} ngày trước';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} giờ trước';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} phút trước';
  } else if (difference.inSeconds > 0) {
    return '${difference.inSeconds} giây trước';
  } else {
    return 'vừa xong';
  }
}

String convertTimeToDate(String isoDateString) {
  DateTime dateTime = DateTime.parse(isoDateString);
  String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'vi').format(dateTime);

  return formattedDate;
}