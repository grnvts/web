import '../repositories/message_repository.dart';

class MessageUseCases {
  final MessageRepository _repository;

  const MessageUseCases(this._repository);

  Stream<Map<String, dynamic>> get messageStream => _repository.messageStream;

  Future<List<dynamic>> loadDialogHistory(int orderId, String dialogUsername) =>
      _repository.loadDialogHistory(orderId, dialogUsername);

  Future<void> sendMessage({
    required int orderId,
    required String recipientUsername,
    required String content,
  }) =>
      _repository.sendMessage(
        orderId: orderId,
        recipientUsername: recipientUsername,
        content: content,
      );

  Future<void> connect() => _repository.connect();

  void disconnect() => _repository.disconnect();
}
