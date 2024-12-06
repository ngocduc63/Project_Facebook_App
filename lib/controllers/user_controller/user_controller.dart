import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/constants/enum_common.dart';
import 'package:facebook/controllers/api_controller.dart';
import 'package:facebook/models/post_model.dart';

class UserController {
  ApiController _apiController = ApiController();

  Future<PostModel?> getPostSingle(String postId)async {
    try {
      final response = await _apiController.get(ApiConfig.getPostSingle,
          {'postId': postId});
      final dataPost = PostModel.fromJson(response.data['metadata']);
      return dataPost;
    } catch (e) {
      print(e);
      return null;
    }
  }

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
      print('Error like: $e');
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
      print('Error like: $e');
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
      print('Error unlike: $e');
      return false;
    }
  }

  Future<bool> acpFriendController(String friendId, String notificationId) async {
     try {
      final response = await _apiController
            .put(ApiConfig.acpFriend, {'friendId': friendId, 'notificationId' : notificationId});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error acp friend: $e');
      return false;
    }
  }

  Future<bool> declineFriendController(String friendId, String notificationId) async {
     try {
      final response = await _apiController
          .delete(ApiConfig.declineFriend, {'friendId': friendId, 'notificationId': notificationId});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error decline friend: $e');
      return false;
    }
  }

  Future<bool> outGroupController(String roomId, String userId) async {
    try {
      final response = await _apiController
            .put(ApiConfig.leaveGroup, {'roomId': roomId, 'friendId': userId});

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error acp friend: $e');
      return false;
    }

  }
}
