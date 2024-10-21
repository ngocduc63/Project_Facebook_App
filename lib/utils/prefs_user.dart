import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserServicePref {
  static final UserServicePref _instance = UserServicePref._internal();

  String? _token;
  String? _apiKey;
  String? _user;

  // Phương thức private để khởi tạo instance
  UserServicePref._internal();

  // Factory constructor trả về instance duy nhất
  factory UserServicePref() {
    return _instance;
  }

  Future<void> loadAuthApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    _apiKey = prefs.getString(AppConstants.apiKey);
    _user = prefs.getString(AppConstants.userInfoKey);
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    _token = token;
  }

  Future<void> saveApiKey(String apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.apiKey, apiKey);
    _apiKey = apiKey;
  }

  Future<void> saveUser(String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userInfoKey, user);
    _user = user;
  }

  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    _token = null;
  }

  Future<void> removeApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.apiKey);
    _apiKey = null;
  }

  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userInfoKey);
    _user = null;
  }

  Map<String, dynamic>? get tokenAsJson {
    if (_token != null) {
      try {
        return jsonDecode(_token!);
      } catch (e) {
        print("Error parsing JSON: $e");
        return null;
      }
    }
    return null;
  }

  UserModel? get getUserInfo {
    if (_user != null) {
      try {
        final userBody = jsonDecode(_user!);

        if (userBody != null) { 
          return UserModel.fromJson(userBody);
        }
      } catch (e) {
        print("Error parsing JSON: $e");
        return null;
      }
    }
    return null;
  }

  String? get token => _token;
  String? get apiKey => _apiKey;
  String? get user => _user;
  bool get hasToken => _token != null && _token!.isNotEmpty;
}
