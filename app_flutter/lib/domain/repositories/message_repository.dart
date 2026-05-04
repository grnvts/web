abstract class MessageRepository {
  Stream<Map<String, dynamic>> get messageStream;

  Future<List<dynamic>> loadDialogHistory(int orderId, String dialogUsername);

  Future<void> sendMessage({
    required int orderId,
    required String recipientUsername,
    required String content,
  });

  Future<void> connect();

  void disconnect();
}
