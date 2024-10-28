import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/controllers/api_controller.dart';

class UserController {
  ApiController _apiController = ApiController();

  Future<bool> likePostController(String postId, Emotion likeCategory) async {
    try {
      final response = await _apiController.post(ApiConfig.likePost,
          {'postId': postId, 'likeCategory': likeCategory.value});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return false;
    }
  }

  Future<bool> updateLikePostController(String postId, Emotion likeCategory) async {
    try {
      final response = await _apiController.put(ApiConfig.updateLikePost,
          {'postId': postId, 'likeCategory': likeCategory.value});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return false;
    }
  }

  Future<bool> unLikePostController(String postId) async {
    try {
      final response = await _apiController.delete(ApiConfig.unLikePost,
          {'postId': postId});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return false;
    }
  }
}
