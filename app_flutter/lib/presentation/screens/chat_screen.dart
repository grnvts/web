import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';

class ChatScreen extends StatefulWidget {
  final int orderId;
  final String recipientUsername;
  final String? dialogUsername;
  final String title;
  final bool isAdminDialog;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.recipientUsername,
    this.dialogUsername,
    required this.title,
    this.isAdminDialog = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageUseCases = AppContainer.messageUseCases;
  final _authUseCases = AppContainer.authUseCases;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  String? _currentUsername;
  bool _loading = true;
  bool _sending = false;
  List<dynamic> _messages = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _currentUsername = await _authUseCases.getUsername();
    await _messageUseCases.connect();
    _messageSubscription = _messageUseCases.messageStream.listen(
      _handleRealtimeMessage,
    );
    await _loadMessages();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    try {
      final data = await _messageUseCases.loadDialogHistory(
        widget.orderId,
        _dialogUsername,
      );
      if (!mounted) return;
      setState(() {
        _messages = data;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _messageUseCases.sendMessage(
        orderId: widget.orderId,
        recipientUsername: widget.recipientUsername,
        content: text,
      );
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageUseCases.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleRealtimeMessage(Map<String, dynamic> message) {
    if (_currentUsername == null) return;
    if (message['orderId'] != widget.orderId) return;

    final sender = message['senderUsername']?.toString();
    final recipient = message['recipientUsername']?.toString();
    final matchesDialog =
        (sender == _currentUsername && recipient == _dialogUsername) ||
        (sender == _dialogUsername && recipient == _currentUsername);

    if (!matchesDialog) return;

    final alreadyExists = _messages.any(
      (dynamic item) =>
          item is Map<String, dynamic> && item['id'] == message['id'],
    );
    if (alreadyExists) return;

    if (!mounted) return;
    setState(() {
      _messages = <dynamic>[..._messages, message];
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _dialogUsername => widget.dialogUsername ?? widget.recipientUsername;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index] as Map<String, dynamic>;
                      final isMine =
                          message['senderUsername'] == _currentUsername;
                      final timestamp = message['timestamp']?.toString();
                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(maxWidth: 360),
                          decoration: BoxDecoration(
                            color: isMine
                                ? const Color(0xFF0F766E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isMine
                                ? null
                                : Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (message['senderUsername'] ?? '').toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isMine
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                (message['content'] ?? '').toString(),
                                style: TextStyle(
                                  color: isMine
                                      ? Colors.white
                                      : const Color(0xFF334155),
                                ),
                              ),
                              if (timestamp != null &&
                                  timestamp.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _formatTimestamp(timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMine
                                        ? Colors.white70
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: _sending ? null : _sendMessage,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      return DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(timestamp));
    } catch (_) {
      return timestamp;
    }
  }
}
