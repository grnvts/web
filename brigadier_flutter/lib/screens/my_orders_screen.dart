import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import 'user_order_detail_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
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
      final orders = await _orderService.getMyOrders();
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

  void refreshOrders() {
    _loadOrders();
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

  String _formatAddress(dynamic address) {
    if (address == null) return 'Не указан';
    if (address is Map) {
      final city = address['city'] ?? 'Не указан';
      final street = address['street'] ?? 'Не указана';
      final buildingNo = address['buildingNo'] ?? '';
      final apartmentNo = address['apartmentNo'] ?? '';
      
      String formatted = '$city, ул. $street';
      if (buildingNo.isNotEmpty) formatted += ', д. $buildingNo';
      if (apartmentNo.isNotEmpty) formatted += ', кв. $apartmentNo';
      return formatted;
    }
    return address.toString();
  }

  String _translateServiceType(String? serviceType) {
    if (serviceType == null) return 'Не указано';
    
    switch (serviceType.toLowerCase()) {
      case 'electrician':
        return 'Электрик';
      case 'plumbing':
        return 'Сантехника';
      case 'painting':
        return 'Малярка';
      default:
        return serviceType;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'У вас пока нет заказов',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Создайте первый заказ',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 6,
                        shadowColor: _getStatusColor(order['status']).withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserOrderDetailScreen(
                                  orderId: order['id'],
                                ),
                              ),
                            ).then((_) => _loadOrders());
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  _getStatusColor(order['status']).withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: _getStatusColor(order['status']).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getStatusColor(order['status']).withOpacity(0.3),
                                            _getStatusColor(order['status']).withOpacity(0.15),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _getStatusColor(order['status']).withOpacity(0.4),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getStatusColor(order['status']).withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '#${order['id']}',
                                          style: TextStyle(
                                            color: _getStatusColor(order['status']),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
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
                                                    fontSize: 18,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      _getStatusColor(order['status']).withOpacity(0.2),
                                                      _getStatusColor(order['status']).withOpacity(0.15),
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: _getStatusColor(order['status']).withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  _getStatusText(order['status']),
                                                  style: TextStyle(
                                                    color: _getStatusColor(order['status']),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(Icons.build, _translateServiceType(order['serviceType'])),
                                          const SizedBox(height: 4),
                                          _buildInfoRow(Icons.location_on, _formatAddress(order['address'])),
                                          const SizedBox(height: 4),
                                          _buildInfoRow(
                                            Icons.calendar_today,
                                            order['status'] == 'IN_PROGRESS'
                                                ? 'В работе'
                                                : _formatDate(order['startDate']?.toString()),
                                          ),
                                        ],
                                      ),
                                    ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                      ),
                                  ],
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
}

