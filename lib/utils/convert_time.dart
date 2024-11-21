import 'package:intl/intl.dart';

String convertToTimeAgo(String isoDateString) {
  DateTime dateTime = DateTime.parse(isoDateString);
  Duration difference = DateTime.now().difference(dateTime);
  String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'vi').format(dateTime);

  if (difference.inDays > 13) {
    return formattedDate;
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
