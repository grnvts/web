import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final _orderUseCases = AppContainer.orderUseCases;
  final _searchController = TextEditingController();

  List<dynamic> _orders = <dynamic>[];
  List<dynamic> _filteredOrders = <dynamic>[];
  bool _isLoading = true;
  String _selectedStatus = '';
  String _sortKey = 'startDate';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOrders);
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderUseCases.getAllOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
      _filterOrders();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load orders: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterOrders() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _orders.where((order) {
      final statusMatches =
          _selectedStatus.isEmpty ||
          order['status']?.toString() == _selectedStatus;
      final searchable = <String>[
        order['id']?.toString() ?? '',
        _clientName(order),
        _brigadierName(order),
        _address(order['address']),
      ].join(' ').toLowerCase();
      final searchMatches = query.isEmpty || searchable.contains(query);
      return statusMatches && searchMatches;
    }).toList();

    filtered.sort((a, b) {
      final aValue = a[_sortKey];
      final bValue = b[_sortKey];

      int comparison;
      if (_sortKey == 'id') {
        comparison = (a['id'] as num? ?? 0).compareTo(b['id'] as num? ?? 0);
      } else {
        comparison = (aValue?.toString() ?? '').compareTo(
          bValue?.toString() ?? '',
        );
      }
      return _sortAscending ? comparison : -comparison;
    });

    setState(() => _filteredOrders = filtered);
  }

  void _changeSort(String key) {
    setState(() {
      if (_sortKey == key) {
        _sortAscending = !_sortAscending;
      } else {
        _sortKey = key;
        _sortAscending = true;
      }
    });
    _filterOrders();
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'CREATED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'APPROVED':
        return Colors.teal;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'CREATED':
        return 'Created';
      case 'IN_PROGRESS':
        return 'In progress';
      case 'COMPLETED':
        return 'Completed';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Date not set';
    try {
      return DateFormat('dd.MM.yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  String _clientName(dynamic order) {
    final surname = order['clientSurname']?.toString() ?? '';
    final name = order['clientName']?.toString() ?? '';
    final patronymic = order['clientPatronymic']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    if (fullName.isNotEmpty) return fullName;
    return order['clientUsername']?.toString() ?? 'Unknown client';
  }

  String _brigadierName(dynamic order) {
    if (order['brigadierId'] == null) return 'Not assigned';
    final surname = order['brigadierSurname']?.toString() ?? '';
    final name = order['brigadierName']?.toString() ?? '';
    final patronymic = order['brigadierPatronymic']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    if (fullName.isNotEmpty) return fullName;
    return order['brigadierUsername']?.toString() ?? 'Not assigned';
  }

  String _address(dynamic address) {
    if (address is! Map) return 'Not specified';
    final parts = <String>[];
    final city = address['city']?.toString() ?? '';
    final street = address['street']?.toString() ?? '';
    final buildingNo = address['buildingNo']?.toString() ?? '';
    final apartmentNo = address['apartmentNo']?.toString() ?? '';

    if (city.isNotEmpty) parts.add(city);
    if (street.isNotEmpty && buildingNo.isNotEmpty) {
      parts.add('$street, bld. $buildingNo');
    } else if (street.isNotEmpty) {
      parts.add(street);
    }
    if (apartmentNo.isNotEmpty) {
      parts.add('apt. $apartmentNo');
    }
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }

  int _crossAxisCount(double width) {
    if (width >= 1320) return 3;
    if (width >= 900) return 2;
    return 1;
  }

  Future<void> _openOrder(dynamic order) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(orderId: order['id']),
      ),
    );
    if (!mounted) return;
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.assignment_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            const Text('Orders', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    hintText: 'Order id, client, brigadier or address',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus.isEmpty ? null : _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text('All statuses'),
                          ),
                          DropdownMenuItem(
                            value: 'CREATED',
                            child: Text('Created'),
                          ),
                          DropdownMenuItem(
                            value: 'IN_PROGRESS',
                            child: Text('In progress'),
                          ),
                          DropdownMenuItem(
                            value: 'COMPLETED',
                            child: Text('Completed'),
                          ),
                          DropdownMenuItem(
                            value: 'APPROVED',
                            child: Text('Approved'),
                          ),
                          DropdownMenuItem(
                            value: 'REJECTED',
                            child: Text('Rejected'),
                          ),
                        ],
                        onChanged: (value) {
                          _selectedStatus = value ?? '';
                          _filterOrders();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortKey,
                        decoration: const InputDecoration(labelText: 'Sort by'),
                        items: const [
                          DropdownMenuItem(
                            value: 'startDate',
                            child: Text('Start date'),
                          ),
                          DropdownMenuItem(
                            value: 'status',
                            child: Text('Status'),
                          ),
                          DropdownMenuItem(
                            value: 'id',
                            child: Text('Order id'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _changeSort(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      tooltip: _sortAscending ? 'Ascending' : 'Descending',
                      onPressed: () => _changeSort(_sortKey),
                      icon: Icon(
                        _sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = _crossAxisCount(constraints.maxWidth);
                        return GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: columns == 1 ? 1.55 : 1.02,
                              ),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return _OrderCard(
                              order: order,
                              statusColor: _statusColor(
                                order['status']?.toString(),
                              ),
                              statusLabel: _statusLabel(
                                order['status']?.toString(),
                              ),
                              clientName: _clientName(order),
                              brigadierName: _brigadierName(order),
                              dateText: order['status'] == 'IN_PROGRESS'
                                  ? 'In progress'
                                  : _formatDate(order['startDate']?.toString()),
                              addressText: _address(order['address']),
                              onTap: () => _openOrder(order),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final dynamic order;
  final Color statusColor;
  final String statusLabel;
  final String clientName;
  final String brigadierName;
  final String dateText;
  final String addressText;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.statusLabel,
    required this.clientName,
    required this.brigadierName,
    required this.dateText,
    required this.addressText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#${order['id']}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Order #${order['id']}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _CardInfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Client',
                value: clientName,
              ),
              const SizedBox(height: 8),
              _CardInfoRow(
                icon: Icons.engineering_rounded,
                label: 'Brigadier',
                value: brigadierName,
              ),
              const SizedBox(height: 8),
              _CardInfoRow(
                icon: Icons.calendar_month_rounded,
                label: 'Start',
                value: dateText,
              ),
              const SizedBox(height: 8),
              _CardInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: addressText,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Open order details',
                  style: TextStyle(
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CardInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
