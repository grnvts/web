import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _dataSource;

  const NotificationRepositoryImpl(this._dataSource);

  @override
  Stream<Map<String, dynamic>> get notificationStream =>
      _dataSource.notificationStream;

  @override
  Future<List<dynamic>> getNotifications() => _dataSource.getNotifications();

  @override
  Future<int> getUnreadCount() => _dataSource.getUnreadCount();

  @override
  Future<void> markAsRead(int notificationId) =>
      _dataSource.markAsRead(notificationId);

  @override
  Future<void> connect() => _dataSource.connect();

  @override
  void disconnect() => _dataSource.disconnect();
}
