import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/features/chat/widgets/message/audio_message.dart';
import 'package:facebook/features/chat/widgets/message/text_message.dart';
import 'package:facebook/features/chat/widgets/message/video_message.dart';
import 'package:facebook/models/message_model.dart';
import 'package:facebook/utils/convert_time.dart';
import 'package:facebook/utils/user_online_observable.dart';
import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  const Message({
    Key? key,
    required this.message,
    required this.isLastMessage,
  }) : super(key: key);

  final MessageModel message;
  final bool isLastMessage;

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  bool showTime = false;
  bool isOnline = false;
  final userOnlineObservable = UserOnlineObservable();

  @override
  void initState() {
    super.initState();

    if (widget.isLastMessage) {
      isOnline =
          userOnlineObservable.listOnline.contains(widget.message.senderId);

      userOnlineObservable.userOnlineStream.listen((onlineList) {
        if (mounted) {
          setState(() {
            isOnline = onlineList.contains(widget.message.senderId);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSender = widget.message.isSender();

    Widget messageContent(MessageModel message) {
      switch (message.data!.type) {
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

    return GestureDetector(
      onTap: () {
        setState(() {
          showTime = !showTime;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20,),
        child: Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isSender) ...[
              if (widget.isLastMessage)
                Stack(
                  children: [
                    PopupMenuButton<String>(
                      padding: const EdgeInsets.all(0),
                      onSelected: (value) {
                        if (value == 'personal') {
                          Navigator.pushNamed(context, RouterConstants.personalScreen, arguments: widget.message.sender);
                        }
                      },
                      icon: CircleAvatar(
                        backgroundImage: NetworkImage(
                            '${ApiConfig.linkImage}${widget.message.sender!.avatar}'),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'name',
                          child: Row(
                            children: [
                              Icon(Icons.person_sharp, size: 18),
                              SizedBox(width: 10),
                              Text(widget.message.sender!.name),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'personal',
                          child: Row(
                            children: [
                              Icon(Icons.view_agenda, size: 18),
                              SizedBox(width: 10),
                              Text("Xem trang cá nhân"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            color: Color(0xFF00BF6D),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              SizedBox(
                width: widget.isLastMessage ? 5 : 52,
              ),
            ],
            Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  messageContent(widget.message),
                  if (showTime)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                      child: Text(
                        'Đã gửi ${convertToTimeAgo(widget.message.time)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: isSender
                                ? AppColors.lightBlueColor
                                : AppColors.blackColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ])
          ],
        ),
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
