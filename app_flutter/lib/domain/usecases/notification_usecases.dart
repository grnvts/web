import '../repositories/notification_repository.dart';

class NotificationUseCases {
  final NotificationRepository _repository;

  const NotificationUseCases(this._repository);

  Stream<Map<String, dynamic>> get notificationStream =>
      _repository.notificationStream;

  Future<List<dynamic>> getNotifications() => _repository.getNotifications();

  Future<int> getUnreadCount() => _repository.getUnreadCount();

  Future<void> markAsRead(int notificationId) =>
      _repository.markAsRead(notificationId);

  Future<void> connect() => _repository.connect();

  void disconnect() => _repository.disconnect();
}
