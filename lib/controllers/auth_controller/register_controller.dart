import 'dart:convert';
import 'package:facebook/features/auth/auth_screen.dart';
import 'package:facebook/utils/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final gender = 'NAM'.obs;
  var isLoadingAuth = false.obs;

  Future<void> registerWithEmail() async {
    isLoadingAuth.value = true;
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      showDialog(
          context: Get.context!,
          builder: (builder) {
            return SimpleDialog(
              title: Text('Lỗi'),
              contentPadding: EdgeInsets.all(20),
              children: [Text('Mật khẩu chưa trùng nhau')],
            );
          });
      isLoadingAuth.value = false;
      return;
    }
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      var headers = {'Content-Type': 'application/json'};
      var url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.registerEmail);

      Map body = {
        'name': nameController.text.trim(),
        'email': email,
        'password': password,
        'gender': gender.value,
      };

      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 201) {
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        isLoadingAuth.value = false;
        showDialog(
          context: Get.context!,
          builder: (builder) {
            return SimpleDialog(
              title: Text('Thông báo'),
              contentPadding: EdgeInsets.all(20),
              children: [
                Text('Đăng kí thành công'),
                SizedBox(height: 20),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(Get.context!);
                    Get.off(AuthScreen(email: email, password: password));
                  },
                  child: Center(
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        throw jsonDecode(response.body) ?? "Login error";
      }
    } catch (e) {
      Get.back();
      isLoadingAuth.value = false;
      showDialog(
          context: Get.context!,
          builder: (builder) {
            return SimpleDialog(
              title: Text('Lỗi'),
              contentPadding: EdgeInsets.all(20),
              children: [Text(e.toString())],
            );
          });
    }
  }
}
