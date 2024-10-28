class AppConstants {
  static const String tokenKey = 'token';
  static const String apiKey = 'apiKey';
  static const String userInfoKey = 'user';
}

class ApiConfig {
  static const String api = 'http://192.168.0.101:3055/api';

  //api get
  static const String linkImage = '$api/user/image/';
  static const String getPostsForUser = '$api/post/posts-for-user';
  static const String getComments = '$api/post/list-comments-by-parent-id';

  //api post
  static const String likePost = '$api/post/create-like';

  // api put 
  static const String updateLikePost = '$api/post/update-like';

  // api delete
  static const String unLikePost = '$api/post/delete-like';
}
