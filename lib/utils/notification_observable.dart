import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationObservable {
  static final NotificationObservable _instance =
      NotificationObservable._internal();

  final _controller = StreamController<int>.broadcast();
  final _messController = StreamController<int>.broadcast();

  int _unreadCount = 0;
  int _unreadCountMess = 0;

  static const _cacheKey = "unread_notification_count";
  static const _cacheKeyMess = "unread_message_count";

  factory NotificationObservable() {
    return _instance;
  }

  NotificationObservable._internal();

  Stream<int> get stream => _controller.stream;
  Stream<int> get messStream => _messController.stream;

  int get unreadCount => _unreadCount;
  int get unreadCountMess => _unreadCountMess;

  Future<void> initialize() async {
    await _loadFromCache();
    await _loadMessFromCache();
  }

  Future<void> updateUnreadCount(int count) async {
    _unreadCount = count;
    _controller.add(_unreadCount);
    await _saveToCache(count);
  }

  Future<void> updateUnreadMessCount(int count) async {
    _unreadCountMess = count;
    _messController.add(_unreadCountMess);
    await _saveMessToCache(count);
  }

  Future<void> incrementUnreadCount() async {
    _unreadCount++;
    _controller.add(_unreadCount);
    await _saveToCache(_unreadCount);
  }

  Future<void> incrementUnreadMessCount() async {
    _unreadCountMess++;
    _messController.add(_unreadCountMess);
    await _saveMessToCache(_unreadCountMess);
  }

  Future<void> clearUnreadCount() async {
    _unreadCount = 0;
    _controller.add(_unreadCount);
    await _saveToCache(_unreadCount);
  }

  Future<void> clearUnreadMessCount() async {
    _unreadCountMess = 0;
    _messController.add(_unreadCountMess);
    await _saveMessToCache(_unreadCountMess);
  }

  Future<void> _saveToCache(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKey, count);
  }

  Future<void> _saveMessToCache(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKeyMess, count);
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    _unreadCount = prefs.getInt(_cacheKey) ?? 0;
    _controller.add(_unreadCount);
  }

  Future<void> _loadMessFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    _unreadCountMess = prefs.getInt(_cacheKeyMess) ?? 0;
    _messController.add(_unreadCountMess);
  }

  void dispose() {
    _controller.close();
    _messController.close();
  }
}
