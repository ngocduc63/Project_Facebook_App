import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/utils/notification_service.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkTokenAndNavigate();
  }

  Future<void> checkTokenAndNavigate() async {
    await UserServicePref.instance.loadAuthApp();
    await Future.delayed(const Duration(milliseconds: 500));

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
            const CircularProgressIndicator(color: GlobalVariables.secondaryColor, strokeWidth: 3,),
            // Padding(
            //   padding: const EdgeInsets.only(
            //     left: 30.0,
            //     right: 30.0,
            //     top: 20,
            //     bottom: 10,
            //   ),
            //   child: SizedBox(
            //     width: MediaQuery.of(context).size.width,
            //     height: 50,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         shadowColor: Theme.of(context).shadowColor,
            //         backgroundColor: Theme.of(context).primaryColor,
            //       ),
            //       onPressed: () async {
            //         await NotificationService.showNotification(
            //           title: "Bạn có tin nhắn mới từ Nguyễn Ngọc Đức",
            //           body: " Đi chơi không",
            //           largeIcon: '${ApiConfig.linkImage}${UserServicePref.instance.getUserInfo!.avatar}',
            //           notificationLayout: NotificationLayout.Messaging,
            //         );
            //       },
            //       child: Text("text", style: TextStyle(color: Colors.blue),),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
