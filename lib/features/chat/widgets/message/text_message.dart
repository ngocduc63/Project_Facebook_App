import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/models/message_model.dart';
import 'package:flutter/material.dart';


class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final MessageModel message;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20 * 0.75, vertical: 20 / 2),
      decoration: BoxDecoration(
          color: AppColors.lightBlueColor.withOpacity(message.isSender() ? 1 : 0.08), borderRadius: BorderRadius.circular(30)),
      child: Text(
        message.data?.content ?? "",
        style: TextStyle(color: message.isSender() ? Colors.white : Theme.of(context).textTheme.bodySmall?.color),
      ),
    );
  }
}
