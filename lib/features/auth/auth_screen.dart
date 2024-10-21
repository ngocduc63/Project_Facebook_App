// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/auth_controller/login_controller.dart';
import 'package:facebook/features/auth/widgets/input_fields.dart';
import 'package:facebook/features/auth/widgets//submit_button.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = RouterConstants.routerAuth;
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  LoginController loginController = Get.put(LoginController());

  var isLogin = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Center(
            child: Obx(
              () => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: Text(
                        'FACEBOOK',
                        style: TextStyle(
                            fontSize: 30,
                            color: GlobalVariables.secondaryColor,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: !isLogin.value ? GlobalVariables.secondaryColor : Colors.white,
                          onPressed: () {
                            isLogin.value = false;
                          },
                          child: Text('Register', style: TextStyle(color:  !isLogin.value ? Colors.white : GlobalVariables.secondaryColor  ),),
                        ),
                        MaterialButton(
                          color: isLogin.value ? GlobalVariables.secondaryColor : Colors.white,
                          onPressed: () {
                            isLogin.value = true;
                          },
                          child: Text('Login', style: TextStyle(color:  isLogin.value ? Colors.white : GlobalVariables.secondaryColor ),),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 80,
                    ),
                    isLogin.value ? loginWidget() : registerWidget()
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget registerWidget() {
    return Column(
      children: [
        // InputTextFieldWidget(loginController.nameController, 'name'),
        // SizedBox(
        //   height: 20,
        // ),
        InputTextFieldWidget(loginController.emailController, 'email'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(loginController.passwordController, 'password'),
        SizedBox(
          height: 20,
        ),
        SubmitButton(
          onPressed: () => loginController.loginWithEmail(),
          title: 'Register',
          isLoading: loginController.isLoadingAuth.value,
        )
      ],
    );
  }

  Widget loginWidget() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(loginController.emailController, 'email'),
        SizedBox(
          height: 20,
        ),
        InputTextFieldWidget(loginController.passwordController, 'password'),
        SizedBox(
          height: 20,
        ),
        SubmitButton(
          onPressed: () => loginController.loginWithEmail(),
          title: 'Login',
          isLoading: loginController.isLoadingAuth.value,
        )
      ],
    );
  }
}
