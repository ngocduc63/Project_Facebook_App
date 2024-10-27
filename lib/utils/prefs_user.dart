import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserServicePref {
  static final UserServicePref _instance = UserServicePref._internal();

  String? _token;
  String? _apiKey;
  String? _user;

  bool _isInitialized = false; // Track initialization

  // Private constructor to create the singleton instance
  UserServicePref._internal();

  // Factory constructor to return the unique instance
  factory UserServicePref() {
    return _instance;
  }

  // Initialize and load authentication details
  Future<void> loadAuthApp() async {
    if (_isInitialized) return; // Avoid re-initialization
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
    _apiKey = prefs.getString(AppConstants.apiKey);
    _user = prefs.getString(AppConstants.userInfoKey);
    _isInitialized = true;
  }

  // Save the token to SharedPreferences
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    _token = token;
  }

  // Save the API key to SharedPreferences
  Future<void> saveApiKey(String apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.apiKey, apiKey);
    _apiKey = apiKey;
  }

  // Save the user information to SharedPreferences
  Future<void> saveUser(String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userInfoKey, user);
    _user = user;
  }

  // Remove the token from SharedPreferences
  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    _token = null;
  }

  // Remove the API key from SharedPreferences
  Future<void> removeApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.apiKey);
    _apiKey = null;
  }

  // Remove the user information from SharedPreferences
  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userInfoKey);
    _user = null;
  }

  // Parse the token into a JSON object if it's valid
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

  // Get user information as a UserModel if it's valid
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

  // Accessors for token, API key, and user
  String? get token => _token;
  String? get apiKey => _apiKey;
  String? get user => _user;

  // Check if the token exists and is not empty
  bool get hasToken => _token != null && _token!.isNotEmpty;
}
