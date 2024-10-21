import 'package:facebook/features/SplashCcreen/screens/splash_screen.dart';
import 'package:facebook/features/auth/auth_screen.dart';
import 'package:facebook/features/home/screens/home_screen.dart';
import 'package:facebook/providers/user_provider.dart';
import 'package:facebook/router.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'constants/global_variables.dart';

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkToken() async {
    final UserServicePref userServicePref = UserServicePref();
    await userServicePref.loadAuthApp();
    return userServicePref.hasToken; // Trả về true nếu có token, false nếu không
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Facebook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
        colorScheme:
            const ColorScheme.light(primary: GlobalVariables.backgroundColor),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          iconTheme: IconThemeData(color: GlobalVariables.iconColor),
        ),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: const SplashScreen(),
    );
  }
}
