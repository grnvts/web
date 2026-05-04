import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationUseCases = AppContainer.notificationUseCases;
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  bool _isLoading = true;
  List<dynamic> _notifications = <dynamic>[];

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _notificationSubscription = _notificationUseCases.notificationStream.listen(
      _handleRealtimeNotification,
    );
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await _notificationUseCases.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to load notifications: $e');
    }
  }

  Future<void> _openNotification(Map<String, dynamic> notification) async {
    if (notification['read'] != true && notification['id'] is int) {
      try {
        await _notificationUseCases.markAsRead(notification['id'] as int);
        notification['read'] = true;
        if (mounted) setState(() {});
      } catch (_) {
        // Keep UI responsive even if mark-as-read failed.
      }
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text((notification['title'] ?? 'Notification').toString()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text((notification['message'] ?? '-').toString()),
            const SizedBox(height: 12),
            Text(
              'Type: ${(notification['typeName'] ?? notification['typeCode'] ?? '-').toString()}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (notification['orderId'] != null)
              Text(
                'Order #${notification['orderId']}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            if (notification['createdAt'] != null)
              Text(
                _formatDate(notification['createdAt']?.toString()),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleRealtimeNotification(Map<String, dynamic> notification) {
    final notificationId = notification['id'];
    if (!mounted || notificationId == null) return;

    final existingIndex = _notifications.indexWhere(
      (dynamic item) =>
          item is Map<String, dynamic> && item['id'] == notificationId,
    );

    setState(() {
      if (existingIndex >= 0) {
        _notifications[existingIndex] = notification;
      } else {
        _notifications = <dynamic>[notification, ..._notifications];
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Color _accentFor(Map<String, dynamic> notification) {
    final code = (notification['typeCode'] ?? '').toString();
    switch (code) {
      case 'CHAT_MESSAGE':
        return Colors.blue;
      case 'ORDER_REMINDER':
        return Colors.orange;
      case 'SYSTEM':
        return Colors.purple;
      default:
        return const Color(0xFF0F766E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
            ? ListView(
                children: const <Widget>[
                  SizedBox(height: 120),
                  Center(child: Text('No notifications yet')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _notifications[index] as Map<String, dynamic>;
                  final accent = _accentFor(item);
                  final isRead = item['read'] == true;
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openNotification(item),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                isRead
                                    ? Icons.notifications_none_rounded
                                    : Icons.notifications_active_rounded,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          (item['title'] ?? 'Notification')
                                              .toString(),
                                          style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.w600
                                                : FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    (item['message'] ?? '-').toString(),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatMeta(item),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatMeta(Map<String, dynamic> item) {
    final parts = <String>[];
    final typeName = item['typeName']?.toString();
    final orderId = item['orderId']?.toString();
    if (typeName != null && typeName.isNotEmpty) parts.add(typeName);
    if (orderId != null && orderId.isNotEmpty) parts.add('Order #$orderId');
    final createdAt = item['createdAt']?.toString();
    if (createdAt != null && createdAt.isNotEmpty) {
      parts.add(_formatDate(createdAt));
    }
    return parts.join(' • ');
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }
}
