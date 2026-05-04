abstract class NotificationRepository {
  Stream<Map<String, dynamic>> get notificationStream;

  Future<List<dynamic>> getNotifications();

  Future<int> getUnreadCount();

  Future<void> markAsRead(int notificationId);

  Future<void> connect();

  void disconnect();
}
