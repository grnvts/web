import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';

class UserOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const UserOrderDetailScreen({super.key, required this.orderId});

  @override
  State<UserOrderDetailScreen> createState() => _UserOrderDetailScreenState();
}

class _UserOrderDetailScreenState extends State<UserOrderDetailScreen> {
  final _orderService = OrderService();
  bool _isLoading = true;
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _orderService.getOrderById(widget.orderId);
      setState(() {
        _order = order;
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
        Navigator.pop(context);
      }
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

  String _getBrigadierName(Map<String, dynamic> order) {
    final name = order['brigadierName'] ?? '';
    final surname = order['brigadierSurname'] ?? '';
    final patronymic = order['brigadierPatronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return order['brigadierUsername'] ?? 'Не назначен';
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Детали заказа'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Детали заказа'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Заказ не найден')),
      );
    }

    final currentStatus = _order!['status'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #${_order!['id']}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус заказа
            Card(
              elevation: 8,
              shadowColor: _getStatusColor(currentStatus).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(currentStatus).withOpacity(0.15),
                      Colors.white,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(currentStatus).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: _getStatusColor(currentStatus),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Статус заказа',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(currentStatus),
                              _getStatusColor(currentStatus).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor(currentStatus).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _getStatusText(currentStatus),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Информация о заказе
            Card(
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Информация о заказе',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    _buildInfoRow('ID заказа', '${_order!['id']}'),
                    _buildInfoRow('Тип услуги', _translateServiceType(_order!['serviceType']?.toString())),
                    _buildInfoRow(
                      'Дата начала',
                      _order!['status'] == 'IN_PROGRESS'
                          ? 'В работе'
                          : _formatDate(_order!['startDate']?.toString()),
                    ),
                    if (_order!['endDate'] != null)
                      _buildInfoRow('Дата окончания', _formatDate(_order!['endDate']?.toString())),
                    if (_order!['price'] != null)
                      _buildInfoRow('Цена', '${_order!['price']} BYN'),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.construction, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Информация о бригадире',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Бригадир', _getBrigadierName(_order!)),
                    if (_order!['brigadierEmail'] != null)
                      _buildInfoRow('Email бригадира', _order!['brigadierEmail']),
                    if (_order!['brigadierPhone'] != null)
                      _buildInfoRow('Телефон бригадира', _order!['brigadierPhone']),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Адрес',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_order!['address'] != null) ...[
                      _buildInfoRow('Город', _order!['address']['city']?.toString() ?? 'Не указан'),
                      _buildInfoRow('Улица', _order!['address']['street']?.toString() ?? 'Не указана'),
                      if (_order!['address']['buildingNo'] != null)
                        _buildInfoRow('Дом', _order!['address']['buildingNo'].toString()),
                      if (_order!['address']['apartmentNo'] != null)
                        _buildInfoRow('Квартира', _order!['address']['apartmentNo'].toString()),
                    ] else
                      _buildInfoRow('Адрес', 'Не указан'),
                    if (_order!['description'] != null || _order!['orderDetails'] != null) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.description, color: Colors.orange, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Описание',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _order!['description'] ?? _order!['orderDetails'] ?? 'Не указано',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Назначенные мастера (только просмотр)
            Card(
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.people, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Назначенные мастера',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    FutureBuilder<List<dynamic>>(
                      future: _orderService.getAssignedMasters(widget.orderId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Мастера не назначены',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: snapshot.data!.map((master) {
                            final name = master['name'] ?? '';
                            final surname = master['surname'] ?? '';
                            final patronymic = master['patronymic'] ?? '';
                            String masterName;
                            if (name.isNotEmpty || surname.isNotEmpty) {
                              masterName = '${surname} ${name} ${patronymic}'.trim();
                            } else {
                              masterName = master['username'] ?? 'Неизвестно';
                            }
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withOpacity(0.2),
                                child: Text(
                                  masterName.isNotEmpty ? masterName[0].toUpperCase() : 'M',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(masterName),
                              subtitle: Text(master['email'] ?? ''),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

