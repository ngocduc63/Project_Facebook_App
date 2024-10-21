import 'package:facebook/constants/app_constants.dart';

class ApiEndPoints {
    static const String baseUrl = '${ApiConfig.api}/api/';
    static _AuthEndPOints authEndpoints = _AuthEndPOints();
}

class _AuthEndPOints {
    final String loginEmail = 'access/login';
}