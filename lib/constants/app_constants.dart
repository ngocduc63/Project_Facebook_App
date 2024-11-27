class AppConstants {
  static const String tokenKey = 'token';
  static const String apiKey = 'apiKey';
  static const String userInfoKey = 'user';
}

class ApiConfig {
  static const String prod = 'https://project-social-network.onrender.com';
  static const String local = 'http://192.168.0.106:3055';
  static const String linkBE = prod;
  static const String api = '$linkBE/api';

  //api get
  static const String linkImage = '$api/user/image/';
  static const String linkVideo = '$api/user/video/';
  static const String getuserInfo = '$api/user/get-user-info';
  static const String getPostsOfUser = '$api/user/get-post-of-user';
  static const String getPostSingle = '$api/post/post-single';
  static const String getPostsForUser = '$api/post/posts-for-user';
  static const String getStory= '$api/story/get-story';
  static const String getComments = '$api/post/list-comments-by-parent-id';
  static const String getRoomChat = '$api/chat/list-room';
  static const String getMessages = '$api/chat/list-mess';
  static const String getListFriend = '$api/friend/list-friend';
  static const String getRoomInfo = '$api/chat/get-room';
  static const String getNotifications = '$api/notification/get-notifications';

  //api post
  static const String createPost = '$api/post/create-post';
  static const String createStory = '$api/story/create-story';
  static const String likePost = '$api/post/create-like';
  static const String commentPost = '$api/post/create-comment';
  static const String addFriend = '$api/friend/add-friend';

  // api put 
  static const String updateLikePost = '$api/post/update-like';
  static const String acpFriend = '$api/friend/accept-friend';
  static const String unfriend = '$api/friend/unfriend';

  // api delete
  static const String unLikePost = '$api/post/delete-like';
  static const String declineFriend = '$api/friend/decline-friend';

}
