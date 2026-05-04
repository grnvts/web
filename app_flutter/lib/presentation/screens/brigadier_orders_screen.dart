import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';
import '../utils/order_view_utils.dart';
import 'order_detail_screen.dart';

class BrigadierOrdersScreen extends StatefulWidget {
  const BrigadierOrdersScreen({super.key});

  @override
  State<BrigadierOrdersScreen> createState() => _BrigadierOrdersScreenState();
}

class _BrigadierOrdersScreenState extends State<BrigadierOrdersScreen> {
  final _orderUseCases = AppContainer.orderUseCases;

  bool _isLoading = true;
  List<dynamic> _orders = <dynamic>[];

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
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderUseCases.getActiveOrdersForBrigadier();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to load brigadier orders: $e');
    }
  }

  Map<String, List<dynamic>> _groupOrdersByDate() {
    final grouped = <String, List<dynamic>>{};
    final fallbackDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    for (final order in _orders) {
      final rawDate = order['startDate']?.toString();
      String key = fallbackDate;

      if (rawDate != null && rawDate.isNotEmpty) {
        try {
          key = DateFormat('yyyy-MM-dd').format(DateTime.parse(rawDate));
        } catch (_) {
          key = fallbackDate;
        }
      }

      grouped.putIfAbsent(key, () => <dynamic>[]).add(order);
    }

    return grouped;
  }

  String _clientName(dynamic order) {
    final surname = order['clientSurname']?.toString() ?? '';
    final name = order['clientName']?.toString() ?? '';
    final patronymic = order['clientPatronymic']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    if (fullName.isNotEmpty) return fullName;
    return order['clientUsername']?.toString() ?? 'Unknown client';
  }

  String _formatDateHeader(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (normalizedDate == normalizedToday) {
        return 'Today - ${DateFormat('dd.MM.yyyy').format(date)}';
      }
      if (normalizedDate == normalizedToday.add(const Duration(days: 1))) {
        return 'Tomorrow - ${DateFormat('dd.MM.yyyy').format(date)}';
      }
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return rawDate;
    }
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
    final groupedOrders = _groupOrdersByDate();
    final sortedDates = groupedOrders.keys.toList()..sort();

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_orders.isEmpty) {
      return Scaffold(
        body: Center(
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
                'No active orders',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedDates.length,
          itemBuilder: (context, groupIndex) {
            final dateKey = sortedDates[groupIndex];
            final orders = groupedOrders[dateKey] ?? <dynamic>[];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: Text(
                    _formatDateHeader(dateKey),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                ...orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: InkWell(
                        onTap: () => _openOrder(order),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: orderStatusColor(
                                    order['status'],
                                  ).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '#${order['id']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: orderStatusColor(order['status']),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Order #${order['id']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        _StatusChip(
                                          label: orderStatusLabel(
                                            order['status']?.toString(),
                                          ),
                                          color: orderStatusColor(
                                            order['status']?.toString(),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _InfoRow(
                                      icon: Icons.person_outline_rounded,
                                      text: _clientName(order),
                                    ),
                                    const SizedBox(height: 6),
                                    _InfoRow(
                                      icon: Icons.calendar_month_rounded,
                                      text: formatOrderDate(
                                        order['startDate']?.toString(),
                                        emptyLabel: 'Date not set',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
