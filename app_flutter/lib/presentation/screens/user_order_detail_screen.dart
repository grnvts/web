import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/di/app_container.dart';
import '../../core/utils/order_pdf.dart';
import '../utils/order_view_utils.dart';
import 'chat_screen.dart';

class UserOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const UserOrderDetailScreen({super.key, required this.orderId});

  @override
  State<UserOrderDetailScreen> createState() => _UserOrderDetailScreenState();
}

class _UserOrderDetailScreenState extends State<UserOrderDetailScreen> {
  final _orderUseCases = AppContainer.orderUseCases;
  final _reviewUseCases = AppContainer.reviewUseCases;
  final _userUseCases = AppContainer.userUseCases;

  bool _isLoading = true;
  Map<String, dynamic>? _order;
  List<dynamic> _assignedMasters = <dynamic>[];
  List<dynamic> _reviews = <dynamic>[];
  List<dynamic> _ratingCategories = <dynamic>[];
  List<dynamic> _admins = <dynamic>[];

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _orderUseCases.getOrderById(widget.orderId),
        _orderUseCases
            .getAssignedMasters(widget.orderId)
            .catchError((_) => <dynamic>[]),
        _reviewUseCases.getOrderReviews(widget.orderId).catchError((_) => <dynamic>[]),
        _reviewUseCases.getRatingCategories().catchError((_) => <dynamic>[]),
        _userUseCases.getAdmins().catchError((_) => <dynamic>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _order = results[0] as Map<String, dynamic>;
        _assignedMasters = results[1] as List<dynamic>;
        _reviews = results[2] as List<dynamic>;
        _ratingCategories = results[3] as List<dynamic>;
        _admins = results[4] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load order: $e');
      Navigator.pop(context);
    }
  }

  String _brigadierName(Map<String, dynamic> order) {
    final fullName =
        '${order['brigadierSurname'] ?? ''} ${order['brigadierName'] ?? ''} ${order['brigadierPatronymic'] ?? ''}'
            .trim();
    if (fullName.isNotEmpty) return fullName;
    return order['brigadierUsername']?.toString() ?? 'Not assigned';
  }

  String _masterName(dynamic master) {
    final fullName =
        '${master['surname'] ?? ''} ${master['name'] ?? ''} ${master['patronymic'] ?? ''}'
            .trim();
    if (fullName.isNotEmpty) return fullName;
    return master['username']?.toString() ?? 'Master';
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String? _adminUsername() {
    for (final admin in _admins) {
      if (admin is Map<String, dynamic>) {
        final username = admin['username']?.toString();
        if (username != null && username.isNotEmpty) {
          return username;
        }
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _reviewTargets() {
    final order = _order;
    if (order == null) return <Map<String, dynamic>>[];

    final targets = <Map<String, dynamic>>[];
    final brigadierId = _asInt(order['brigadierId']);
    final brigadierUsername = order['brigadierUsername']?.toString();
    if (brigadierId != null &&
        brigadierUsername != null &&
        brigadierUsername.isNotEmpty) {
      targets.add(<String, dynamic>{
        'id': brigadierId,
        'label': 'Brigadier - ${_brigadierName(order)}',
      });
    }

    for (final master in _assignedMasters) {
      final masterId = master is Map<String, dynamic> ? _asInt(master['id']) : null;
      if (master is Map<String, dynamic> && masterId != null) {
        targets.add(<String, dynamic>{
          'id': masterId,
          'label': 'Master - ${_masterName(master)}',
        });
      }
    }
    return targets;
  }

  bool _canCreateReview() {
    final status = _order?['status']?.toString();
    return status == 'COMPLETED' || status == 'APPROVED';
  }

  bool _canConfirmCompletion() {
    return _order?['status']?.toString() == 'COMPLETED';
  }

  bool _hasReviewForTarget(int targetUserId) {
    return _reviews.any(
      (dynamic review) =>
          review is Map<String, dynamic> && review['targetUserId'] == targetUserId,
    );
  }

  Future<void> _exportPdf() async {
    final order = _order;
    if (order == null) return;
    try {
      final bytes = await OrderPdfBuilder.build(
        order: order,
        masters: _assignedMasters,
        generatedBy: order['clientUsername']?.toString(),
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCreateReviewDialog() async {
    final targets = _reviewTargets()
        .where((target) => !_hasReviewForTarget(target['id'] as int))
        .toList();
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available employees for a new review')),
      );
      return;
    }
    if (_ratingCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review categories are unavailable')),
      );
      return;
    }

    final titleController = TextEditingController();
    final commentController = TextEditingController();
    int? selectedTargetId = targets.first['id'] as int;
    final scores = <String, int>{
      for (final category in _ratingCategories)
        (category['categoryCode'] ?? '').toString(): 5,
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) => AlertDialog(
            title: const Text('Leave a review'),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<int>(
                      initialValue: selectedTargetId,
                      decoration: const InputDecoration(
                        labelText: 'Employee',
                        border: OutlineInputBorder(),
                      ),
                      items: targets
                          .map(
                            (target) => DropdownMenuItem<int>(
                              value: target['id'] as int,
                              child: Text(target['label'].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedTargetId = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._ratingCategories.map((dynamic category) {
                      final code = (category['categoryCode'] ?? '').toString();
                      final name = (category['categoryName'] ?? code).toString();
                      final currentScore = scores[code] ?? 5;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: Text(name)),
                            DropdownButton<int>(
                              value: currentScore,
                              items: List<int>.generate(5, (i) => i + 1)
                                  .map(
                                    (score) => DropdownMenuItem<int>(
                                      value: score,
                                      child: Text(score.toString()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setDialogState(() => scores[code] = value);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selectedTargetId == null
                    ? null
                    : () async {
                        try {
                          await _reviewUseCases.createReview(widget.orderId, {
                            'targetUserId': selectedTargetId,
                            'title': titleController.text.trim().isEmpty
                                ? null
                                : titleController.text.trim(),
                            'comment': commentController.text.trim(),
                            'ratings': _ratingCategories.map((dynamic category) {
                              final code =
                                  (category['categoryCode'] ?? '').toString();
                              return {
                                'categoryCode': code,
                                'score': scores[code] ?? 5,
                              };
                            }).toList(),
                          });
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (!mounted) return;
                          _showInfo('Review created');
                          await _loadOrder();
                        } catch (e) {
                          if (!mounted) return;
                          _showError('Failed to create review: $e');
                        }
                      },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    titleController.dispose();
    commentController.dispose();
  }

  Future<void> _changeOrderStatus(String status, {String? message}) async {
    try {
      await _orderUseCases.updateOrderStatus(
        widget.orderId,
        status,
        message: message,
      );
      if (!mounted) return;
      _showInfo('Order status changed to ${orderStatusLabel(status)}');
      await _loadOrder();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to update order status: $e');
    }
  }

  Future<void> _approveOrder() async {
    await _changeOrderStatus(
      'APPROVED',
      message: 'Client approved completed work',
    );
  }

  Future<void> _showRejectDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject completed work'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Reason',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final reason = controller.text.trim();
                if (reason.isEmpty) {
                  _showError('Enter rejection reason');
                  return;
                }
                Navigator.pop(dialogContext);
                await _changeOrderStatus('REJECTED', message: reason);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF0F766E)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final order = _order;
    if (order == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }

    final status = order['status']?.toString();
    final adminUsername = _adminUsername();

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order['id']}')),
      body: RefreshIndicator(
        onRefresh: _loadOrder,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: orderStatusColor(status).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.assignment_turned_in_outlined,
                            color: orderStatusColor(status),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Order status',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Created: ${formatOrderDate(order['createdDate']?.toString())}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: orderStatusColor(status),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            orderStatusLabel(status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        Chip(
                          avatar: const Icon(Icons.build_outlined, size: 18),
                          label: Text(
                            orderServiceTypeLabel(order['serviceType']?.toString()),
                          ),
                        ),
                        Chip(
                          avatar: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          label: Text(
                            'Start: ${formatOrderDate(order['startDate']?.toString())}',
                          ),
                        ),
                        if (order['price'] != null)
                          Chip(
                            avatar: const Icon(
                              Icons.payments_outlined,
                              size: 18,
                            ),
                            label: Text('Price: ${order['price']} BYN'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Actions',
              icon: Icons.bolt_outlined,
              children: <Widget>[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Export PDF'),
                    ),
                    if (_canConfirmCompletion())
                      FilledButton.icon(
                        onPressed: _approveOrder,
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        label: const Text('Approve work'),
                      ),
                    if (_canConfirmCompletion())
                      OutlinedButton.icon(
                        onPressed: _showRejectDialog,
                        icon: const Icon(Icons.thumb_down_alt_outlined),
                        label: const Text('Reject work'),
                      ),
                    if (_canCreateReview())
                      FilledButton.icon(
                        onPressed: _showCreateReviewDialog,
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Leave review'),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Order communication',
              icon: Icons.chat_bubble_outline_rounded,
              children: <Widget>[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: adminUsername == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    orderId: widget.orderId,
                                    recipientUsername: adminUsername,
                                    title: 'Chat with admin',
                                    isAdminDialog: true,
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('Admin'),
                    ),
                    if ((order['brigadierUsername']?.toString().isNotEmpty ??
                        false))
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                orderId: widget.orderId,
                                recipientUsername:
                                    order['brigadierUsername'].toString(),
                                title: 'Chat with brigadier',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.engineering_outlined),
                        label: const Text('Brigadier'),
                      ),
                  ],
                ),
                if (adminUsername == null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    'Admin contact is unavailable for this account.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Order details',
              icon: Icons.receipt_long_outlined,
              children: <Widget>[
                _infoTile(
                  label: 'Order id',
                  value: order['id']?.toString() ?? '-',
                ),
                _infoTile(
                  label: 'Service type',
                  value: orderServiceTypeLabel(order['serviceType']?.toString()),
                  icon: Icons.build_outlined,
                ),
                _infoTile(
                  label: 'Address',
                  value: formatOrderAddress(order['address']),
                  icon: Icons.location_on_outlined,
                ),
                _infoTile(
                  label: 'Start date',
                  value: formatOrderDate(order['startDate']?.toString()),
                ),
                _infoTile(
                  label: 'End date',
                  value: formatOrderDate(order['endDate']?.toString()),
                ),
                if ((order['orderDetails']?.toString().isNotEmpty ?? false))
                  _infoTile(
                    label: 'Work details',
                    value: order['orderDetails'].toString(),
                    icon: Icons.notes_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Brigadier and masters',
              icon: Icons.groups_outlined,
              children: <Widget>[
                _infoTile(
                  label: 'Brigadier',
                  value: _brigadierName(order),
                  icon: Icons.engineering_outlined,
                ),
                if ((order['brigadierPhone']?.toString().isNotEmpty ?? false))
                  _infoTile(
                    label: 'Brigadier phone',
                    value: order['brigadierPhone'].toString(),
                  ),
                if ((order['brigadierEmail']?.toString().isNotEmpty ?? false))
                  _infoTile(
                    label: 'Brigadier email',
                    value: order['brigadierEmail'].toString(),
                  ),
                const SizedBox(height: 8),
                if (_assignedMasters.isEmpty)
                  Text(
                    'No masters assigned yet.',
                    style: TextStyle(color: Colors.grey.shade700),
                  )
                else
                  ..._assignedMasters.map(
                    (master) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFF0F766E,
                        ).withValues(alpha: 0.12),
                        foregroundColor: const Color(0xFF0F766E),
                        child: Text(
                          _masterName(master).substring(0, 1).toUpperCase(),
                        ),
                      ),
                      title: Text(_masterName(master)),
                      subtitle:
                          (master['username']?.toString().isNotEmpty ?? false)
                              ? Text(master['username'].toString())
                              : null,
                      trailing:
                          (master['phone']?.toString().isNotEmpty ?? false)
                              ? Text(master['phone'].toString())
                              : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Reviews',
              icon: Icons.star_outline_rounded,
              children: <Widget>[
                if (_reviews.isEmpty)
                  Text(
                    'No reviews for this order yet.',
                    style: TextStyle(color: Colors.grey.shade700),
                  )
                else
                  ..._reviews.map((dynamic review) {
                    final item = review as Map<String, dynamic>;
                    final average = (item['averageScore'] ?? 0).toString();
                    final target =
                        (item['targetUsername'] ?? 'Assigned employee').toString();
                    final title = (item['title'] ?? '').toString();
                    final comment = (item['comment'] ?? '').toString();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  target,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                'Rating: $average',
                                style: const TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (title.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (comment.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 6),
                            Text(comment),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ((item['ratings'] as List<dynamic>? ) ?? <dynamic>[])
                                .map((dynamic rating) {
                                  final map = rating as Map<String, dynamic>;
                                  return Chip(
                                    label: Text(
                                      '${map['categoryName']}: ${map['score']}',
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                if (_canCreateReview()) ...<Widget>[
                  const SizedBox(height: 8),
                  ..._reviewTargets()
                      .where((target) => !_hasReviewForTarget(target['id'] as int))
                      .map(
                        (target) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Available for review: ${target['label']}',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
