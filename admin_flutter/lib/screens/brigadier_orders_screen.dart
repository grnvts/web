import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class BrigadierOrdersScreen extends StatefulWidget {
  const BrigadierOrdersScreen({super.key});

  @override
  State<BrigadierOrdersScreen> createState() => _BrigadierOrdersScreenState();
}

class _BrigadierOrdersScreenState extends State<BrigadierOrdersScreen> {
  final _orderService = OrderService();
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _orderService.getActiveOrdersForBrigadier();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? status) {
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

  String _getStatusText(String? status) {
    switch (status) {
      case 'CREATED':
        return 'Создан';
      case 'IN_PROGRESS':
        return 'В работе';
      case 'COMPLETED':
        return 'Завершен';
      case 'APPROVED':
        return 'Одобрен';
      case 'REJECTED':
        return 'Отклонен';
      default:
        return status ?? 'UNKNOWN';
    }
  }

  String _getClientName(dynamic order) {
    final name = order['clientName'] ?? '';
    final surname = order['clientSurname'] ?? '';
    final patronymic = order['clientPatronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return order['clientUsername'] ?? 'Неизвестно';
  }

  Map<String, List<dynamic>> _groupOrdersByDate() {
    final grouped = <String, List<dynamic>>{};
    final now = DateTime.now();
    
    for (var order in _orders) {
      String dateKey;
      final startDate = order['startDate']?.toString();
      
      if (startDate != null) {
        try {
          final date = DateTime.parse(startDate);
          dateKey = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          dateKey = DateFormat('yyyy-MM-dd').format(now);
        }
      } else {
        dateKey = DateFormat('yyyy-MM-dd').format(now);
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(order);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedOrders = _groupOrdersByDate();
    final sortedDates = groupedOrders.keys.toList()..sort();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Нет активных заказов',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, dateIndex) {
                      final date = sortedDates[dateIndex];
                      final ordersForDate = groupedOrders[date]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text(
                              _formatDateHeader(date),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          ...ordersForDate.map((order) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailScreen(
                                        orderId: order['id'],
                                      ),
                                    ),
                                  ).then((_) => _loadOrders());
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _getStatusColor(order['status']).withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order['status']).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '#${order['id']}',
                                            style: TextStyle(
                                              color: _getStatusColor(order['status']),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
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
                                                    'Заказ #${order['id']}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(order['status']).withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    _getStatusText(order['status']),
                                                    style: TextStyle(
                                                      color: _getStatusColor(order['status']),
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            _buildInfoRow(Icons.person, _getClientName(order)),
                                            const SizedBox(height: 4),
                                            _buildInfoRow(Icons.calendar_today, _formatDate(order['startDate']?.toString())),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateHeader(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      if (dateOnly == today) {
        return 'Сегодня (${DateFormat('dd.MM.yyyy').format(date)})';
      } else if (dateOnly == today.add(const Duration(days: 1))) {
        return 'Завтра (${DateFormat('dd.MM.yyyy').format(date)})';
      } else {
        return DateFormat('dd.MM.yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }
}

