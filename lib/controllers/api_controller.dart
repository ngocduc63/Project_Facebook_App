import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';


class ApiController {
  final Dio _dio = Dio();
  final UserServicePref _userServicePref = UserServicePref();
  UserModel? userInfo;
  String? apiKey = '';
  Map<String, dynamic>? tokens;

  ApiController() {
    userInfo = _userServicePref.getUserInfo;
    apiKey = _userServicePref.apiKey;
    tokens = _userServicePref.tokenAsJson;

    // Set default configuration
    _dio.options.baseUrl = ApiConfig.api;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'authorization': tokens?['accessToken'],
      'x-client-id': userInfo?.id,
    };

    // Add interceptor to handle JWT expiration
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        return handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 407) {
          // If JWT is expired, try refreshing the token
          try {
            await _refreshToken();
            // Retry the original request with the new token
            final options = error.requestOptions;
            final newToken = _userServicePref.tokenAsJson;
            UserModel? userInfo = _userServicePref.getUserInfo;
            final apiKey = _userServicePref.apiKey;

            options.headers['authorization'] = newToken?['accessToken'];
            options.headers['x-api-key'] = apiKey;
            options.headers['x-client-id'] = userInfo?.id;

            final response = await _dio.request(
              options.path,
              options: Options(
                method: options.method,
                headers: options.headers,
              ),
              data: options.data,
              queryParameters: options.queryParameters,
            );
            return handler.resolve(response);
          } catch (e) {
            // If refreshing the token fails, reject the request
            return handler.reject(error);
          }
        }
        return handler.reject(error);
      },
    ));
  }

  Future<Response> get(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.get(endpoint, data: body);
    } catch (e) {
      rethrow;
    }
  }

  // Function to handle custom POST request
  Future<Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.post(endpoint, data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.put(endpoint, data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _dio.delete(endpoint, data: body);
    } catch (e) {
      rethrow;
    }
  }

  // Function to refresh the token
  Future<void> _refreshToken() async {
    try {
      final response = await _dio.put('/access/refresh-token', data: {
        'refreshToken': tokens?['refreshToken'],
      });
      
      // Update the token if refresh is successful
      String newTokens = jsonEncode(response.data['metadata']['tokens']);

    //  errorcode == 403 => logout

      // Save the new token using UserServicePref
      await _userServicePref.saveToken(newTokens);
    } catch (e) {
      throw Exception('Failed to refresh token');
    }
  }
}