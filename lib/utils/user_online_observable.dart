import 'dart:async';

class UserOnlineObservable {
  static final UserOnlineObservable _instance = UserOnlineObservable._internal();
  factory UserOnlineObservable() => _instance;
  UserOnlineObservable._internal();

  final _userOnlineController = StreamController<List<String>>.broadcast();

  Stream<List<String>> get userOnlineStream => _userOnlineController.stream;
  List<String> _listOnline = [];

  List<String> get listOnline => _listOnline;


  void updateUserOnlineList(List<String> data) {
    _listOnline = data;
    _userOnlineController.add(data);
  }

  Future<List<String>> getUserOnlineList() async {
    return await userOnlineStream.last;
  }

  void dispose() {
    _userOnlineController.close();
  }
}
