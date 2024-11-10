import 'package:facebook/controllers/socket_controller.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:facebook/constants/app_colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.chat
  });

  final ChatModel chat;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  TextEditingController _controller = TextEditingController();
  UserServicePref userServicePref = UserServicePref();
  late UserModel? currentUser;
  bool isTyping = false;
  late io.Socket? socket;

  @override
   void initState() {
    super.initState();
    socket = SocketController.instance.socket;
    currentUser = userServicePref.getUserInfo;
  }

  void sendMessage() {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      _controller.clear();


      if(socket != null && currentUser != null) {
        socket!.emit('single_chat_message', {
          "roomId" : widget.chat.id,
          "content": message,
          "sender" : currentUser?.id,
          "type" : "text"
      });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20 / 2),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                blurRadius: 15,
                offset: Offset(0, 4),
                color: AppColors.lightBlueColor.withOpacity(0.3))
          ]),
      child: SafeArea(
          child: Row(
        children: [
          Icon(Icons.mic, color: AppColors.lightBlueColor),
          SizedBox(width: 5),
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
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.64),
                  ),
                  SizedBox(width: 20 / 2),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (text) {
                        setState(() {
                          isTyping = text.isNotEmpty;
                        });
                      },
                      cursorColor: AppColors.lightBlueColor,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nhắn tin',
                        hintStyle: TextStyle(color: AppColors.darkGreyColor)
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 20 / 4),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.64),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.lightBlueColor,),
            onPressed:
                isTyping ? sendMessage : null,
          ),
        ],
      )),
    );
  }
}
