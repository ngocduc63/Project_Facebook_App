import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/features/chat/screen/call_screen.dart';
import 'package:facebook/features/chat/widgets/message/body_message.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  static const String routeName = '/message-screen';
  final ChatModel chat;
  const MessagesScreen({super.key, required this.chat});

  void handleCall(BuildContext context) {
    final String currentUser = UserServicePref.instance.getUserInfo.id;
    final String calleId = chat.friend.id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: currentUser,
          calleeId: calleId,
          offer: null,
          userInfo: chat.friend,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.lightBlueColor,
        title: Row(
          children: [
            const BackButton(color: AppColors.whiteColor),
            CircleAvatar(
              backgroundImage:
                  NetworkImage('${ApiConfig.linkImage}${chat.isGroup ? chat.image : chat.friend.avatar}'),
            ),
            const SizedBox(width: 20 * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.isGroup ? chat.name! : chat.friend.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w600,
                    )),
                Text('Active 3m ago',
                    style: TextStyle(fontSize: 12, color: AppColors.whiteColor))
              ],
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () => {handleCall(context)},
              icon: Icon(
                Icons.call,
                color: AppColors.whiteColor,
              )),
          IconButton(
              onPressed: () => {handleCall(context)},
              icon: Icon(Icons.videocam, color: AppColors.whiteColor)),
          SizedBox(
            width: 20 / 2,
          )
        ],
      ),
      body: Body(
        chat: chat,
      ),
    );
  }
}
