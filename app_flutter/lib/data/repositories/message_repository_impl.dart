import '../../domain/repositories/message_repository.dart';
import '../datasources/message_service.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageService _dataSource;

  const MessageRepositoryImpl(this._dataSource);

  @override
  Stream<Map<String, dynamic>> get messageStream => _dataSource.messageStream;

  @override
  Future<List<dynamic>> loadDialogHistory(int orderId, String dialogUsername) =>
      _dataSource.loadDialogHistory(orderId, dialogUsername);

  @override
  Future<void> sendMessage({
    required int orderId,
    required String recipientUsername,
    required String content,
  }) =>
      _dataSource.sendMessage(
        orderId: orderId,
        recipientUsername: recipientUsername,
        content: content,
      );

  @override
  Future<void> connect() => _dataSource.connect();

  @override
  void disconnect() => _dataSource.disconnect();
}
