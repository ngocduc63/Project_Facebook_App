import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/constants/router_constants.dart';
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
    final UserServicePref userServicePref = UserServicePref();
    await userServicePref.loadAuthApp();
    await Future.delayed(const Duration(microseconds: 1500));
    // Điều hướng đến màn hình tương ứng
    if (userServicePref.hasToken) {
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
            Image.asset('assets/logo.png', height: 100), // Thay thế bằng đường dẫn logo của bạn
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: GlobalVariables.secondaryColor, strokeWidth: 3,), // Hiển thị loading
          ],
        ),
      ),
    );
  }
}
