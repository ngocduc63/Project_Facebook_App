import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/socket_controller.dart';
import 'package:facebook/models/chat_model.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/notification_observable.dart';
import 'package:facebook/utils/notification_service.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late io.Socket? socket;
  final NotificationObservable observable = NotificationObservable();
  @override
  void initState() {
    super.initState();
    checkTokenAndNavigate();
  }

  void initSocket() {
    socket = SocketController.instance.getSocket();
    if (socket != null && UserServicePref.instance.getUserInfo.id != 'error') {
      socket!.emit('join_noti_for_user',
          {"userId": UserServicePref.instance.getUserInfo.id});

      socket!.on('receive_noti', (data) async {
        String type = data['noti_type'];

        if (type == "message") {
          final roomData = ChatModel.fromJson(data['data']);
          if (UserServicePref.instance.currentRoom != roomData.id) {
            observable.incrementUnreadMessCount();
            String content = roomData.lastMessage?.data?.content ?? "";
            String displayContent = content.length > 256
                ? "${content.substring(0, 256)}..."
                : content;
            await NotificationService.showNotification(
              title:
                  "Bạn có tin nhắn mới từ ${roomData.lastMessage!.sender!.name}",
              body: displayContent,
              // largeIcon:
              //     '${ApiConfig.linkImage}${roomData.lastMessage!.sender!.avatar}',
              notificationLayout: NotificationLayout.Messaging,
            );
          }
        } else if (type == "POST-002") {
          // like post
          observable.incrementUnreadCount();
        } else if (type == "POST-003") {
          // comment
          observable.incrementUnreadCount();
        } else if (type == "POST-004") {
          // share
          observable.incrementUnreadCount();
        } else if (type == "FRIEND-001") {
          // add friend
          observable.incrementUnreadCount();
        } else if (type == "FRIEND-002") {
          // acp friend
          observable.incrementUnreadCount();
        }
      });

      socket!.on("newCall", (data) async {
        final UserModel callerInfo = UserModel.fromJson(data['callerInfo']);
        await NotificationService.showNotification(
          title: "Cuộc gọi đến từ ${callerInfo.name}",
          body: "Bấm để trả lời hoặc từ chối",
          // largeIcon:
          //     '${ApiConfig.linkImage}${callerInfo.avatar}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Call,
          actionButtons: [
            NotificationActionButton(
              key: 'ANSWER',
              label: 'Trả lời',
            ),
            NotificationActionButton(
              key: 'DECLINE',
              label: 'Từ chối',
              actionType: ActionType.KeepOnTop,
            ),
          ],
          offer: data['sdpOffer'],
          payload: {"data": jsonEncode(data)},
        );
      });
    }
  }

  Future<void> checkTokenAndNavigate() async {
    await UserServicePref.instance.loadAuthApp();
    await observable.initialize();

    initSocket();

    await Future.delayed(const Duration(milliseconds: 600));

    if (UserServicePref.instance.hasToken) {
      Get.offNamed(RouterConstants.routerHome);
    } else {
      Get.offNamed(RouterConstants.routerAuth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: GlobalVariables.secondaryColor,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
