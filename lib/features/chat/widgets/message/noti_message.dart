import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/models/message_model.dart';
import 'package:flutter/material.dart';

class NotiMessage extends StatelessWidget {
  const NotiMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenWidth),
      child: Text(
        "${message.sender!.name} ${message.data?.content ?? ""}",
        style: TextStyle(color: AppColors.darkGreyColor),
      ),
    );
  }
}
