import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../core/config/app_config.dart';
import '../../domain/repositories/auth_repository.dart';

class MessageService {
  final AuthRepository _authRepository;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final Map<String, Completer<List<dynamic>>> _historyRequests =
      <String, Completer<List<dynamic>>>{};
  StompClient? _stompClient;
  Future<void>? _connectFuture;

  MessageService(AuthRepository authRepository)
      : _authRepository = authRepository;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  Future<List<dynamic>> loadDialogHistory(
    int orderId,
    String dialogUsername,
  ) async {
    await connect();
    final client = _stompClient;
    if (client == null || !client.connected) {
      throw Exception('Chat connection is unavailable');
    }

    final requestKey = _historyRequestKey(orderId, dialogUsername);
    final completer = Completer<List<dynamic>>();
    _historyRequests[requestKey] = completer;

    client.send(
      destination: '/app/chat.dialog',
      body: jsonEncode({
        'orderId': orderId,
        'dialogUsername': dialogUsername,
      }),
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 10));
    } finally {
      _historyRequests.remove(requestKey);
    }
  }

  Future<void> sendMessage({
    required int orderId,
    required String recipientUsername,
    required String content,
  }) async {
    await connect();
    final client = _stompClient;
    if (client == null || !client.connected) {
      throw Exception('Chat connection is unavailable');
    }
    client.send(
      destination: '/app/chat.send',
      body: jsonEncode({
        'orderId': orderId,
        'recipientUsername': recipientUsername,
        'content': content,
      }),
    );
  }

  Future<void> connect() {
    if (_stompClient?.connected == true) {
      return Future<void>.value();
    }
    return _connectFuture ??= _openConnection();
  }

  void disconnect() {
    for (final completer in _historyRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Chat connection closed'));
      }
    }
    _historyRequests.clear();
    _stompClient?.deactivate();
    _stompClient = null;
    _connectFuture = null;
  }

  Future<void> _openConnection() async {
    final token = await _authRepository.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    final completer = Completer<void>();
    late final StompClient client;
    client = StompClient(
      config: StompConfig(
        url: _webSocketUrl(),
        stompConnectHeaders: <String, String>{
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: <String, dynamic>{
          'Authorization': 'Bearer $token',
        },
        onConnect: (frame) {
          client.subscribe(
            destination: '/user/queue/messages',
            callback: (messageFrame) {
              final body = messageFrame.body;
              if (body == null || body.isEmpty) return;
              final decoded = jsonDecode(body);
              if (decoded is Map<String, dynamic>) {
                _messageController.add(decoded);
              }
            },
          );
          client.subscribe(
            destination: '/user/queue/messages.history',
            callback: (messageFrame) {
              final body = messageFrame.body;
              if (body == null || body.isEmpty) return;
              final decoded = jsonDecode(body);
              if (decoded is! Map<String, dynamic>) return;

              final orderId = decoded['orderId'];
              final dialogUsername = decoded['dialogUsername']?.toString();
              if (orderId is! int || dialogUsername == null) return;

              final requestKey = _historyRequestKey(orderId, dialogUsername);
              final completer = _historyRequests[requestKey];
              if (completer == null || completer.isCompleted) return;

              final messages = decoded['messages'];
              completer.complete(messages is List ? messages : <dynamic>[]);
            },
          );
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onStompError: (frame) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(frame.body ?? 'WebSocket connection failed'),
            );
          }
        },
        onWebSocketError: (dynamic error) {
          if (!completer.isCompleted) {
            completer.completeError(Exception(error.toString()));
          }
        },
        onDisconnect: (_) {
          _connectFuture = null;
        },
      ),
    );

    _stompClient = client;
    client.activate();

    try {
      await completer.future.timeout(const Duration(seconds: 10));
    } finally {
      _connectFuture = null;
    }
  }

  String _webSocketUrl() {
    final apiUri = Uri.parse(AppConfig.apiBaseUrl);
    final wsScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
    var path = apiUri.path;
    if (path.endsWith('/api')) {
      path = path.substring(0, path.length - 4);
    }
    if (path.isEmpty) {
      path = '/ws';
    } else {
      path = '$path/ws';
    }

    return Uri(
      scheme: wsScheme,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
      path: path,
    ).toString();
  }

  String _historyRequestKey(int orderId, String dialogUsername) =>
      '$orderId:${dialogUsername.toLowerCase()}';
}
