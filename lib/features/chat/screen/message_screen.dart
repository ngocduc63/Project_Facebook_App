import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/features/chat/screen/call_screen.dart';
import 'package:facebook/features/chat/widgets/message/body_message.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:facebook/utils/user_online_observable.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  static const String routeName = '/message-screen';
  final ChatModel chat;

  const MessagesScreen({super.key, required this.chat});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool isOnline = false;
  final userOnlineObservable = UserOnlineObservable();

  @override
  void initState() {
    super.initState();

    if (!widget.chat.isGroup) {
      isOnline =
          userOnlineObservable.listOnline.contains(widget.chat.friend.id);

      userOnlineObservable.userOnlineStream.listen((onlineList) {
        if (mounted) {
          setState(() {
            isOnline = onlineList.contains(widget.chat.friend.id);
          });
        }
      });
    }
  }

  void handleCall(BuildContext context) {
    final String currentUser = UserServicePref.instance.getUserInfo.id;
    final String calleId = widget.chat.friend.id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: currentUser,
          calleeId: calleId,
          offer: null,
          userInfo: widget.chat.friend,
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
        title: GestureDetector(
          onTap: () {
            if (widget.chat.isGroup) return;

            Navigator.pushNamed(context, RouterConstants.personalScreen,
                arguments: widget.chat.friend);
          },
          child: Row(
            children: [
              const BackButton(color: AppColors.whiteColor),
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        '${ApiConfig.linkImage}${widget.chat.isGroup ? widget.chat.image : widget.chat.friend.avatar}'),
                  ),
                  if (!widget.chat.isGroup && isOnline)
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
              const SizedBox(width: 20 * 0.75),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.isGroup
                        ? widget.chat.name!
                        : widget.chat.friend.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!widget.chat.isGroup)
                    Text(
                      isOnline ? 'Đang hoạt động' : 'Không hoạt động',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.whiteColor),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (!widget.chat.isGroup)
            IconButton(
              onPressed: () => {handleCall(context)},
              icon: Icon(
                Icons.call,
                color: AppColors.whiteColor,
              ),
            ),
          if (!widget.chat.isGroup)
            IconButton(
              onPressed: () => {handleCall(context)},
              icon: Icon(Icons.videocam, color: AppColors.whiteColor),
            ),
          if (widget.chat.isGroup)  
            IconButton(
              onPressed: () => {
                Navigator.pushNamed(context, RouterConstants.menuChatScreen, arguments: widget.chat)
              },
              icon: Icon(Icons.menu, color: AppColors.whiteColor),
            ),
          SizedBox(
            width: 20 / 2,
          )
        ],
      ),
      body: Body(
        chat: widget.chat,
      ),
    );
  }
}
