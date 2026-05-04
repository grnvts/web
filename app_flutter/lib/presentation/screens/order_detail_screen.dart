import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/di/app_container.dart';
import '../../core/utils/order_pdf.dart';
import '../utils/order_view_utils.dart';
import 'chat_screen.dart';
import 'order_edit_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _authUseCases = AppContainer.authUseCases;
  final _orderUseCases = AppContainer.orderUseCases;
  final _brigadeUseCases = AppContainer.brigadeUseCases;

  bool _isLoading = true;
  bool _isAdmin = false;
  bool _isBrigadier = false;
  Map<String, dynamic>? _order;
  List<dynamic> _assignedMasters = <dynamic>[];

  static const List<String> _statusOptions = <String>[
    'CREATED',
    'IN_PROGRESS',
    'COMPLETED',
    'APPROVED',
    'REJECTED',
  ];

  String? get _currentStatus => _order?['status']?.toString();

  bool get _hasBrigadeAssigned => _order?['brigadeId'] != null;

  bool get _canAssignMasters => _isAdmin || (_isBrigadier && _hasBrigadeAssigned);

  bool get _canAddExpense =>
      _isAdmin || (_isBrigadier && _hasBrigadeAssigned);

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

  List<String> _availableStatusOptions() {
    final currentStatus = _currentStatus;
    if (_isAdmin) {
      return _statusOptions
          .where((status) => status != currentStatus)
          .toList(growable: false);
    }

    if (_isBrigadier) {
      switch (currentStatus) {
        case 'CREATED':
          return const <String>['IN_PROGRESS'];
        case 'IN_PROGRESS':
          return const <String>['COMPLETED'];
        default:
          return const <String>[];
      }
    }

    return const <String>[];
  }

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _orderUseCases.getOrderById(widget.orderId),
        _orderUseCases
            .getAssignedMasters(widget.orderId)
            .catchError((_) => <dynamic>[]),
        _authUseCases.isAdmin(),
        _authUseCases.isBrigadier(),
      ]);

      if (!mounted) return;
      setState(() {
        _order = results[0] as Map<String, dynamic>;
        _assignedMasters = results[1] as List<dynamic>;
        _isAdmin = results[2] as bool;
        _isBrigadier = results[3] as bool;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load order: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _showAssignBrigadierDialog() async {
    final order = _order;
    if (order == null) return;

    List<dynamic> brigadiers;
    try {
      brigadiers = await _orderUseCases.getAllBrigadiers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load brigadiers: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    String? selectedBrigadier = order['brigadierUsername']?.toString();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Assign brigadier'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedBrigadier,
                decoration: const InputDecoration(
                  labelText: 'Brigadier',
                  border: OutlineInputBorder(),
                ),
                items: brigadiers
                    .map(
                      (brigadier) => DropdownMenuItem<String>(
                        value: brigadier['username']?.toString(),
                        child: Text(_personLabel(brigadier)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => selectedBrigadier = value),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: selectedBrigadier == null ||
                          selectedBrigadier == order['brigadierUsername']
                      ? null
                      : () async {
                          try {
                            await _orderUseCases.assignBrigadier(
                              widget.orderId,
                              selectedBrigadier!,
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            if (!mounted) return;
                            _showInfo('Brigadier assigned');
                            await _loadScreen();
                          } catch (e) {
                            if (!mounted) return;
                            _showError('Failed to assign brigadier: $e');
                          }
                        },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showStatusDialog() async {
    final order = _order;
    if (order == null) return;
    final availableStatuses = _availableStatusOptions();
    if (availableStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available status changes')),
      );
      return;
    }

    final messageController = TextEditingController();
    String selectedStatus = availableStatuses.first;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Change status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'New status',
                      border: OutlineInputBorder(),
                    ),
                    items: availableStatuses
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(orderStatusLabel(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() => selectedStatus = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await _orderUseCases.updateOrderStatus(
                        widget.orderId,
                        selectedStatus,
                        message: messageController.text.trim().isEmpty
                            ? null
                            : messageController.text.trim(),
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                      if (!mounted) return;
                      _showInfo('Status updated');
                      await _loadScreen();
                    } catch (e) {
                      if (!mounted) return;
                      _showError('Failed to update status: $e');
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    messageController.dispose();
  }

  Future<void> _showAssignMastersDialog() async {
    final order = _order;
    if (order == null) return;

    final brigadeId = order['brigadeId'];
    if (brigadeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assign brigadier and brigade first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<dynamic> masters;
    try {
      masters = await _brigadeUseCases.getBrigadeMasters(
        (brigadeId as num).toInt(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load masters: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    final selectedIds = _assignedMasters
        .map<int?>((master) => (master['id'] as num?)?.toInt())
        .whereType<int>()
        .toSet();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Assign masters'),
              content: SizedBox(
                width: 420,
                child: masters.isEmpty
                    ? const Text('No available masters in this brigade')
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: masters.map((master) {
                            final masterId = (master['id'] as num?)?.toInt();
                            final checked = masterId != null &&
                                selectedIds.contains(masterId);
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: checked,
                              title: Text(_personLabel(master)),
                              subtitle:
                                  (master['username']?.toString().isNotEmpty ??
                                          false)
                                      ? Text(master['username'].toString())
                                      : null,
                              onChanged: masterId == null
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        if (value == true) {
                                          selectedIds.add(masterId);
                                        } else {
                                          selectedIds.remove(masterId);
                                        }
                                      });
                                    },
                            );
                          }).toList(),
                        ),
                      ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      await _orderUseCases.assignMasters(
                        widget.orderId,
                        selectedIds.toList()..sort(),
                      );
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                      if (!mounted) return;
                      _showInfo('Masters updated');
                      await _loadScreen();
                    } catch (e) {
                      if (!mounted) return;
                      _showError('Failed to assign masters: $e');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showExpenseDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add expense'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              suffixText: 'BYN',
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
                final value = controller.text.trim().replaceAll(',', '.');
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _orderUseCases.addExpense(widget.orderId, amount);
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (!mounted) return;
                  _showInfo('Expense added');
                  await _loadScreen();
                } catch (e) {
                  if (!mounted) return;
                  _showError('Failed to add expense: $e');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _openEditScreen() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => OrderEditScreen(orderId: widget.orderId),
      ),
    );
    if (mounted) {
      await _loadScreen();
    }
  }

  Future<void> _openChatWithClient() async {
    final username = _order?['clientUsername']?.toString();
    if (username == null || username.isEmpty) return;

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          orderId: widget.orderId,
          recipientUsername: username,
          title: 'Chat with client',
          isAdminDialog: _isAdmin,
        ),
      ),
    );
  }

  Future<void> _changeStatusQuickly(String status, {String? message}) async {
    try {
      await _orderUseCases.updateOrderStatus(
        widget.orderId,
        status,
        message: message,
      );
      if (!mounted) return;
      _showInfo('Status changed: ${orderStatusLabel(status)}');
      await _loadScreen();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to update status: $e');
    }
  }

  Future<void> _exportPdf() async {
    final order = _order;
    if (order == null) return;
    try {
      final username = await _authUseCases.getUsername();
      final bytes = await OrderPdfBuilder.build(
        order: order,
        masters: _assignedMasters,
        generatedBy: username,
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
  String _personLabel(dynamic person) {
    final surname = person['surname']?.toString() ?? '';
    final name = person['name']?.toString() ?? '';
    final patronymic = person['patronymic']?.toString() ?? '';
    final username = person['username']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    return fullName.isEmpty
        ? (username.isEmpty ? 'Not set' : username)
        : fullName;
  }

  String _clientLabel(Map<String, dynamic> order) {
    final fullName =
        '${order['clientSurname'] ?? ''} ${order['clientName'] ?? ''} ${order['clientPatronymic'] ?? ''}'
            .trim();
    if (fullName.isNotEmpty) return fullName;
    return order['clientUsername']?.toString() ?? 'Not set';
  }

  String _brigadierLabel(Map<String, dynamic> order) {
    if (order['brigadierId'] == null) return 'Not assigned';
    final fullName =
        '${order['brigadierSurname'] ?? ''} ${order['brigadierName'] ?? ''} ${order['brigadierPatronymic'] ?? ''}'
            .trim();
    if (fullName.isNotEmpty) return fullName;
    return order['brigadierUsername']?.toString() ?? 'Not assigned';
  }

  String _masterLabel(dynamic master) {
    return _personLabel(master);
  }

  Widget _buildInfoTile({
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

  List<Widget> _buildActionButtons() {
    final order = _order;
    if (order == null) return <Widget>[];

    final status = _currentStatus;
    final actions = <Widget>[];

    if (_isAdmin || _isBrigadier) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _openChatWithClient,
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('Chat with client'),
        ),
      );
    }

    if (_isAdmin) {
      actions.add(
        FilledButton.icon(
          onPressed: _showAssignBrigadierDialog,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Assign brigadier'),
        ),
      );
      actions.add(
        OutlinedButton.icon(
          onPressed: _openEditScreen,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit order'),
        ),
      );
    }

    if (_canAssignMasters) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _showAssignMastersDialog,
          icon: const Icon(Icons.groups_2_outlined),
          label: const Text('Assign masters'),
        ),
      );
    }

    if (_isAdmin && _availableStatusOptions().isNotEmpty) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _showStatusDialog,
          icon: const Icon(Icons.sync_alt_rounded),
          label: const Text('Change status'),
        ),
      );
    }

    if (_isBrigadier && status == 'CREATED') {
      actions.add(
        FilledButton.icon(
          onPressed: () =>
              _changeStatusQuickly('IN_PROGRESS', message: 'Work started'),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start work'),
        ),
      );
    }

    if (_isBrigadier && status == 'IN_PROGRESS') {
      actions.add(
        FilledButton.icon(
          onPressed: () =>
              _changeStatusQuickly('COMPLETED', message: 'Work completed'),
          icon: const Icon(Icons.done_all_rounded),
          label: const Text('Complete work'),
        ),
      );
    }

    if (_canAddExpense) {
      actions.add(
        OutlinedButton.icon(
          onPressed: _showExpenseDialog,
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('Add expense'),
        ),
      );
    }

    actions.add(
      OutlinedButton.icon(
        onPressed: _exportPdf,
        icon: const Icon(Icons.picture_as_pdf_outlined),
        label: const Text('Export PDF'),
      ),
    );

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final order = _order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order details')),
        body: const Center(child: Text('Order not found')),
      );
    }

    final status = order['status']?.toString();
    final actionButtons = _buildActionButtons();
    final address = order['address'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order['id']}')),
      body: RefreshIndicator(
        onRefresh: _loadScreen,
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
                        Chip(
                          avatar: const Icon(Icons.payments_outlined, size: 18),
                          label: Text(
                            'Price: ${order['price']?.toString() ?? '0'} BYN',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (actionButtons.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Actions',
                icon: Icons.bolt_outlined,
                children: <Widget>[
                  Wrap(spacing: 10, runSpacing: 10, children: actionButtons),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _buildSection(
              title: 'Main info',
              icon: Icons.info_outline,
              children: <Widget>[
                _buildInfoTile(
                  label: 'Order id',
                  value: order['id']?.toString() ?? '-',
                ),
                _buildInfoTile(
                  label: 'Work details',
                  value: (order['orderDetails'] ??
                          order['description'] ??
                          'Not set')
                      .toString(),
                ),
                _buildInfoTile(
                  label: 'Address',
                  value: formatOrderAddress(
                    address,
                    emptyLabel: 'Not specified',
                  ),
                  icon: Icons.location_on_outlined,
                ),
                _buildInfoTile(
                  label: 'Start date',
                  value: formatOrderDate(order['startDate']?.toString()),
                ),
                _buildInfoTile(
                  label: 'End date',
                  value: formatOrderDate(order['endDate']?.toString()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Client and brigade',
              icon: Icons.groups_outlined,
              children: <Widget>[
                _buildInfoTile(
                  label: 'Client',
                  value: _clientLabel(order),
                  icon: Icons.person_outline,
                ),
                _buildInfoTile(
                  label: 'Client username',
                  value: order['clientUsername']?.toString() ?? 'Not set',
                ),
                _buildInfoTile(
                  label: 'Client phone',
                  value: order['clientPhone']?.toString() ?? 'Not set',
                ),
                _buildInfoTile(
                  label: 'Brigadier',
                  value: _brigadierLabel(order),
                  icon: Icons.engineering_outlined,
                ),
                _buildInfoTile(
                  label: 'Brigadier username',
                  value:
                      order['brigadierUsername']?.toString() ?? 'Not assigned',
                ),
                _buildInfoTile(
                  label: 'Brigade number',
                  value: order['brigadeNumber']?.toString() ?? 'Not assigned',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Assigned masters',
              icon: Icons.handyman_outlined,
              children: _assignedMasters.isEmpty
                  ? <Widget>[
                      Text(
                        'No masters assigned yet.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]
                  : _assignedMasters
                      .map(
                        (master) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: const Color(
                              0xFF0F766E,
                            ).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFF0F766E),
                            child: Text(
                              _masterLabel(
                                master,
                              ).substring(0, 1).toUpperCase(),
                            ),
                          ),
                          title: Text(_masterLabel(master)),
                          subtitle:
                              (master['username']?.toString().isNotEmpty ??
                                      false)
                                  ? Text(master['username'].toString())
                                  : null,
                          trailing:
                              (master['phone']?.toString().isNotEmpty ?? false)
                                  ? Text(master['phone'].toString())
                                  : null,
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
