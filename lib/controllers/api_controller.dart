import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:image_picker/image_picker.dart';

class ApiController {
  final Dio _dio = Dio();
  late UserModel userInfo;
  String? apiKey = '';
  Map<String, dynamic>? tokens;

  ApiController() {
    userInfo = UserServicePref.instance.getUserInfo;
    apiKey = UserServicePref.instance.apiKey;
    tokens = UserServicePref.instance.tokenAsJson;

    // Set default configuration
    _dio.options.baseUrl = ApiConfig.api;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'authorization': tokens?['accessToken'],
      'x-client-id': userInfo.id,
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
            final newToken = UserServicePref.instance.tokenAsJson;
            final newApiKey = UserServicePref.instance.apiKey;

            options.headers['authorization'] = newToken?['accessToken'];
            options.headers['x-api-key'] = newApiKey;
            options.headers['x-client-id'] = userInfo.id;

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

  Future<Response> postForm(
      String endpoint, List<File> listImage, List<File> listVideo, text, PostStatus postStatus) async {
    try {
      FormData formData = FormData();

      for (var image in listImage) {
        formData.files.add(MapEntry(
          'post',
          await MultipartFile.fromFile(image.path,
              filename: image.path.split('/').last,
              contentType: DioMediaType('image', 'png')),
        ));
      }

      for (var video in listVideo) {
        formData.files.add(MapEntry(
          'post',
          await MultipartFile.fromFile(video.path,
              filename: video.path.split('/').last,
              contentType: DioMediaType('video', 'mp4')),
        ));
      }

      String dataJson = jsonEncode({"post_title": text, 'post_status' : postStatus.value});
      formData.fields.add(MapEntry('data', dataJson));

      return await _dio.post(endpoint, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> storyForm(
      String endpoint, XFile media, String text, bool isVideo, PostStatus postStatus) async {
    try {
      FormData formData = FormData();
      if (isVideo) {
        formData.files.add(MapEntry(
          'post',
          await MultipartFile.fromFile(media.path,
              filename: media.path.split('/').last,
              contentType: DioMediaType('video', 'mp4')),
        ));
      } else {
        formData.files.add(MapEntry(
          'post',
          await MultipartFile.fromFile(media.path,
              filename: media.path.split('/').last,
              contentType: DioMediaType('image', 'png')),
        ));
      }

      String dataJson = jsonEncode({"story_title": text, 'story_status': postStatus.value});
      formData.fields.add(MapEntry('data', dataJson));

      return await _dio.post(endpoint, data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> imageForm(
      String endpoint, XFile media, bool isCover) async {
    try {
      FormData formData = FormData();
      if (!isCover) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(media.path,
              filename: media.path.split('/').last,
              contentType: DioMediaType('image', 'png')),
        ));
      } else {
        formData.files.add(MapEntry(
          'cover',
          await MultipartFile.fromFile(media.path,
              filename: media.path.split('/').last,
              contentType: DioMediaType('image', 'png')),
        ));
      }

      return await _dio.put(endpoint, data: formData);
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

      // Save the new token using UserServicePref.instance
      await UserServicePref.instance.saveToken(newTokens);
    } catch (e) {
      throw Exception('Failed to refresh token');
    }
  }
}
