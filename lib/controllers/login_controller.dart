import 'dart:convert';
import 'package:facebook/features/auth/auth_screen.dart';
import 'package:facebook/features/home/screens/home_screen.dart';
import 'package:facebook/utils/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
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
        final SharedPreferences? prefs = await _prefs;

        await prefs?.setString('token', json['metadata']['token'].toString());
        await prefs?.setString('api_key', json['metadata']['apikey']['key'].toString());

        emailController.clear();
        passwordController.clear();

        Get.off(HomeScreen());
      } else {
        throw jsonDecode(response.body) ?? "Login error";
      }
      isLoadingAuth.value = false;
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
