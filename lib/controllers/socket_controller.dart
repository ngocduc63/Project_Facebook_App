import 'package:facebook/constants/app_constants.dart';
import 'package:facebook/models/user_model.dart';
import 'package:facebook/utils/prefs_user.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketController {
  static SocketController? _instance;
  io.Socket? socket;
  UserModel? currentUser;

  SocketController._internal() {
    currentUser = UserServicePref.instance.getUserInfo;

    socket = io.io(ApiConfig.linkBE, <String, dynamic>{
      'transports': ['websocket'],
      'query': {'userId': currentUser?.id, "callerId": currentUser?.id},
    });

    socket?.on('connect', (_) {
      print("Socket đã kết nối thành công.");
    });

    socket?.on('connect_error', (error) {
      print("Lỗi kết nối socket: $error");
    });

    socket?.on('disconnect', (_) {
      print("Socket đã ngắt kết nối.");
    });

    socket?.connect();
  }

  static SocketController get instance {
    _instance ??= SocketController._internal();
    return _instance!;
  }

  // Getter để lấy socket
  io.Socket? getSocket() {
    return socket;
  }
}
