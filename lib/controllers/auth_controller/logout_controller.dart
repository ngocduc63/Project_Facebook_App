import 'package:facebook/features/auth/auth_screen.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:get/get.dart';

class LogoutController extends GetxController{
  var isLoadingAuth = false.obs;
  
  Future<void> logout() async {
    isLoadingAuth.value = true;

    try {
      isLoadingAuth.value = false;
      await UserServicePref.instance.removeApiKey();
      await UserServicePref.instance.removeToken();
      await UserServicePref.instance.removeUser();

      Get.off(AuthScreen());
    } catch (e) {
      isLoadingAuth.value = false;
    }

  }
}
