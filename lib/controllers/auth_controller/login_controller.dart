import 'dart:convert';
import 'package:facebook/features/home/screens/home_screen.dart';
import 'package:facebook/utils/api_endpoints.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UserServicePref userServicePref = UserServicePref();
  var isLoadingAuth = false.obs;

  Future<void> loginWithEmail() async {
    isLoadingAuth.value = true;
    try {
      var headers = {'Content-Type': 'application/json'};
      var url = Uri.parse(
          ApiEndPoints.baseUrl + ApiEndPoints.authEndpoints.loginEmail);

      Map body = {
        'email': emailController.text.trim(),
        'password': passwordController.text
      };

      http.Response response =
          await http.post(url, body: jsonEncode(body), headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final userData = jsonEncode(json['metadata']['user']);
        final tokenData = jsonEncode(json['metadata']['tokens']);

        await userServicePref.saveToken(tokenData);
        await userServicePref
            .saveApiKey(json['metadata']['apikey']['key'].toString());
        await userServicePref
            .saveUser(userData);

        emailController.clear();
        passwordController.clear();

        Get.off(HomeScreen());
        isLoadingAuth.value = false;
      } else {
        throw jsonDecode(response.body) ?? "Login error";
      }
    } catch (e) {
      Get.back();

      // if error code => text error

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
