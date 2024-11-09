import 'package:facebook/constants/app_colors.dart';
import 'package:flutter/material.dart';



class ChatInputField extends StatelessWidget {
  const ChatInputField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20 / 2),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(blurRadius: 32, offset: Offset(0, 4), color: Color(0xff087949).withOpacity(0.3))]),
      child: SafeArea(
          child: Row(
        children: [
          Icon(Icons.mic, color: AppColors.lightBlueColor),
          SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20 * 0.75),
              decoration: BoxDecoration(
                color: AppColors.lightBlueColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.64),
                  ),
                  SizedBox(width: 20 / 2),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(border: InputBorder.none, hintText: 'Type Message'),
                    ),
                  ),
                  Icon(
                    Icons.attach_file,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.64),
                  ),
                  SizedBox(width: 20 / 4),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.64),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
