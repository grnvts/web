import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../core/config/app_config.dart';
import '../../domain/repositories/auth_repository.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _client;
  final AuthRepository _authRepository;
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  StompClient? _stompClient;
  Future<void>? _connectFuture;

  NotificationService(AuthRepository authRepository)
      : _client = ApiClient(authRepository),
        _authRepository = authRepository;

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  Future<List<dynamic>> getNotifications() async {
    final response = await _client.get('/notifications');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : <dynamic>[];
    }
    throw Exception(_extractError(response, 'Failed to load notifications'));
  }

  Future<int> getUnreadCount() async {
    final response = await _client.get('/notifications/unread-count');
    if (response.statusCode == 200) {
      return int.tryParse(response.body) ?? 0;
    }
    throw Exception(_extractError(response, 'Failed to load unread count'));
  }

  Future<void> markAsRead(int notificationId) async {
    final response = await _client.put('/notifications/$notificationId/read');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(_extractError(response, 'Failed to mark as read'));
    }
  }

  Future<void> connect() {
    if (_stompClient?.connected == true) {
      return Future<void>.value();
    }
    return _connectFuture ??= _openConnection();
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _connectFuture = null;
  }

  String _extractError(dynamic response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) return decoded['message'].toString();
        if (decoded['error'] != null) return decoded['error'].toString();
      }
    } catch (_) {
      // ignore
    }
    return fallback;
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
            destination: '/user/queue/notifications',
            callback: (messageFrame) {
              final body = messageFrame.body;
              if (body == null || body.isEmpty) return;
              final decoded = jsonDecode(body);
              if (decoded is Map<String, dynamic>) {
                _notificationController.add(decoded);
              }
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
}
