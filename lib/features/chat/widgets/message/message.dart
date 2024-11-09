import 'dart:ui';

import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/features/chat/widgets/message/audio_message.dart';
import 'package:facebook/features/chat/widgets/message/text_message.dart';
import 'package:facebook/features/chat/widgets/message/video_message.dart';
import 'package:facebook/models/message_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  const Message({
    Key? key,
    required this.message,
  }) : super(key: key);

  final MessageModel message;
  @override
  Widget build(BuildContext context) {
    UserServicePref userServicePref = UserServicePref();
    bool isSender = userServicePref.getUserInfo!.id == message.sender?.id;

    Widget messageContaint(MessageModel message) {
      switch (message.data!['type']) {
        case MessageType.text:
          return TextMessage(message: message);
        case MessageType.audio:
          return AudioMessage(message: message);
        case MessageType.video:
          return VideoMessage(message: message);
        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender) ...[
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/images/user_2.png'),
            ),
            const SizedBox(
              width: 20 / 2,
            )
          ],
          messageContaint(message),
          // if (isSender) MessageStatusDot(status: message.messageStatus)
        ],
      ),
    );
  }
}

// class MessageStatusDot extends StatelessWidget {
//   final MessageStatus? status;

//   const MessageStatusDot({Key? key, this.status}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     Color dotColor(MessageStatus status) {
//       switch (status) {
//         case MessageStatus.not_sent:
//           return Colors.yellow;
//         case MessageStatus.not_view:
//           return Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.1);
//         case MessageStatus.viewed:
//           return AppColors.lightBlueColor;
//         default:
//           return Colors.transparent;
//       }
//     }

//     return Container(
//       margin: EdgeInsets.only(left: 20 / 2),
//       height: 15,
//       width: 12,
//       decoration: BoxDecoration(
//         color: dotColor(status!),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(
//         status == MessageStatus.not_sent ? Icons.close : Icons.done,
//         size: 11,
//         color: Theme.of(context).scaffoldBackgroundColor,
//       ),
//     );
//   }
// }
