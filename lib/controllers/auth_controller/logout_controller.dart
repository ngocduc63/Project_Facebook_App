import 'package:facebook/features/auth/auth_screen.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:get/get.dart';

class LogoutController extends GetxController{
  var isLoadingAuth = false.obs;
  final UserServicePref _userServicePref = UserServicePref();
  
  Future<void> logout() async {
    isLoadingAuth.value = true;

    try {
      isLoadingAuth.value = false;
      await _userServicePref.removeApiKey();
      await _userServicePref.removeToken();
      await _userServicePref.removeUser();

      Get.off(AuthScreen());
    } catch (e) {
      isLoadingAuth.value = false;
    }

  }
}
