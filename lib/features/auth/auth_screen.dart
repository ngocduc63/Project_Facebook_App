// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'package:facebook/constants/app_colors.dart';
import 'package:facebook/constants/global_variables.dart';
import 'package:facebook/constants/router_constants.dart';
import 'package:facebook/controllers/auth_controller/login_controller.dart';
import 'package:facebook/controllers/auth_controller/register_controller.dart';
import 'package:facebook/features/auth/widgets/input_fields.dart';
import 'package:facebook/features/auth/widgets//submit_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthScreen extends StatefulWidget {
  static const String routeName = RouterConstants.routerAuth;
  final String email;
  final String password;

  const AuthScreen({
    this.email = '',
    this.password = '',
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  LoginController loginController = Get.put(LoginController());
  RegisterController registerController = Get.put(RegisterController());
  var isLogin = true.obs; // Observable variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Container(
                  child: Text(
                    'FACEBOOK',
                    style: TextStyle(
                        fontSize: 30,
                        color: GlobalVariables.secondaryColor,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      color: !isLogin.value
                          ? GlobalVariables.secondaryColor
                          : Colors.white,
                      onPressed: () {
                        setState(() {
                          isLogin.value = false;
                        });
                      },
                      child: Text(
                        'Đăng kí',
                        style: TextStyle(
                            color: !isLogin.value
                                ? Colors.white
                                : GlobalVariables.secondaryColor),
                      ),
                    ),
                    MaterialButton(
                      color: isLogin.value
                          ? GlobalVariables.secondaryColor
                          : Colors.white,
                      onPressed: () {
                        setState(() {
                          isLogin.value = true;
                        });
                      },
                      child: Text(
                        'Đăng nhâp',
                        style: TextStyle(
                            color: isLogin.value
                                ? Colors.white
                                : GlobalVariables.secondaryColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80),
                Obx(() => isLogin.value ? loginWidget() : registerWidget())
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget registerWidget() {
    return Column(
      children: [
        InputTextFieldWidget(
            registerController.nameController, 'Tên ngươi dùng'),
        const SizedBox(height: 20),
        InputTextFieldWidget(registerController.emailController, 'Email'),
        const SizedBox(height: 20),
        InputTextFieldWidget(
          registerController.passwordController,
          'Mật khẩu',
          isPassword: true,
        ),
        const SizedBox(height: 20),
        InputTextFieldWidget(
          registerController.confirmPasswordController,
          'Nhập lại mật khẩu',
          isPassword: true,
        ),
        const SizedBox(height: 20),
        Obx(() => Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Nam'),
                    leading: Radio<String>(
                      value: 'NAM',
                      fillColor:
                          WidgetStateProperty.all(AppColors.lightBlueColor),
                      groupValue: registerController.gender.value,
                      onChanged: (value) {
                        registerController.gender.value = value!;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Nữ'),
                    leading: Radio<String>(
                      value: 'NỮ',
                      fillColor:
                          WidgetStateProperty.all(AppColors.lightBlueColor),
                      groupValue: registerController.gender.value,
                      onChanged: (value) {
                        registerController.gender.value = value!;
                      },
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(height: 20),
        // Submit button
        SubmitButton(
          onPressed: () => registerController.registerWithEmail(),
          title: 'Đăng kí',
          isLoading: registerController.isLoadingAuth.value,
        ),
      ],
    );
  }

  Widget loginWidget() {
    return Column(
      children: [
        SizedBox(height: 20),
        InputTextFieldWidget(
          loginController.emailController,
          'email',
          initialValue: widget.email,
        ),
        SizedBox(height: 20),
        InputTextFieldWidget(
          loginController.passwordController,
          'Mật khẩu',
          isPassword: true,
          initialValue: widget.password,
        ),
        SizedBox(height: 20),
        SubmitButton(
          onPressed: () => loginController.loginWithEmail(),
          title: 'Đăng nhập',
          isLoading: loginController.isLoadingAuth.value,
        )
      ],
    );
  }
}
