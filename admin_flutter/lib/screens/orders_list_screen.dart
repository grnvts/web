import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final _orderService = OrderService();
  final _searchController = TextEditingController();
  
  List<dynamic> _orders = [];
  List<dynamic> _filteredOrders = [];
  bool _isLoading = true;
  String _selectedStatus = '';
  String _sortKey = 'startDate';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _orderService.getAllOrders();
      setState(() {
        _orders = orders;
        _filterOrders();
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

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = _orders.where((order) {
        final matchesStatus = _selectedStatus.isEmpty ||
            (order['status']?.toString() == _selectedStatus);
        final matchesSearch = query.isEmpty ||
            (order['id']?.toString().contains(query) ?? false) ||
            (order['clientName']?.toString().toLowerCase().contains(query) ?? false) ||
            (order['clientSurname']?.toString().toLowerCase().contains(query) ?? false);
        return matchesStatus && matchesSearch;
      }).toList();

      // Сортировка
      _filteredOrders.sort((a, b) {
        final aValue = a[_sortKey];
        final bValue = b[_sortKey];
        if (aValue == null) return 1;
        if (bValue == null) return -1;
        
        int comparison;
        if (aValue is String && bValue is String) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is DateTime || bValue is DateTime) {
          final aDate = aValue is String ? DateTime.parse(aValue) : aValue as DateTime;
          final bDate = bValue is String ? DateTime.parse(bValue) : bValue as DateTime;
          comparison = aDate.compareTo(bDate);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }
        
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  void _sortBy(String key) {
    setState(() {
      if (_sortKey == key) {
        _sortAscending = !_sortAscending;
      } else {
        _sortKey = key;
        _sortAscending = true;
      }
      _filterOrders();
    });
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateString;
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

  String _getBrigadierName(dynamic order) {
    if (order['brigadierId'] == null) return 'Не назначен';
    final name = order['brigadierName'] ?? '';
    final surname = order['brigadierSurname'] ?? '';
    final patronymic = order['brigadierPatronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return order['brigadierUsername'] ?? 'Не назначен';
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

  Widget _buildGridInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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

  String _formatAddress(dynamic address) {
    if (address == null) return 'Не указан';
    if (address is Map) {
      final city = address['city'] ?? '';
      final street = address['street'] ?? '';
      final buildingNo = address['buildingNo'] ?? '';
      final apartmentNo = address['apartmentNo'] ?? '';
      
      final parts = <String>[];
      if (city.isNotEmpty) parts.add(city);
      if (street.isNotEmpty) {
        if (buildingNo.isNotEmpty) {
          parts.add('$street, д. $buildingNo');
        } else {
          parts.add(street);
        }
      }
      if (apartmentNo.isNotEmpty) {
        parts.add('кв. $apartmentNo');
      }
      
      return parts.isEmpty ? 'Не указан' : parts.join(', ');
    }
    return address.toString();
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
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 14),
            const Text(
              'Все заказы',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Фильтры
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Поиск',
                    hintText: 'Поиск по ID, имени клиента...',
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus.isEmpty ? null : _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Статус',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Все статусы')),
                    DropdownMenuItem(value: 'CREATED', child: Text('Создан')),
                    DropdownMenuItem(value: 'IN_PROGRESS', child: Text('В работе')),
                    DropdownMenuItem(value: 'COMPLETED', child: Text('Завершен')),
                    DropdownMenuItem(value: 'APPROVED', child: Text('Одобрен')),
                    DropdownMenuItem(value: 'REJECTED', child: Text('Отклонен')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? '';
                      _filterOrders();
                    });
                  },
                ),
              ],
            ),
          ),
          // Список заказов
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Заказы не найдены',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getStatusColor(order['status']).withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getStatusColor(order['status']).withOpacity(0.2),
                                                    _getStatusColor(order['status']).withOpacity(0.1),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: _getStatusColor(order['status']).withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '#${order['id']}',
                                                  style: TextStyle(
                                                    color: _getStatusColor(order['status']),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(order['status']).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: _getStatusColor(order['status']).withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                _getStatusText(order['status']),
                                                style: TextStyle(
                                                  color: _getStatusColor(order['status']),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Заказ #${order['id']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildGridInfoRow(Icons.person_outline, 'Клиент', _getClientName(order)),
                                              const SizedBox(height: 8),
                                              _buildGridInfoRow(Icons.construction, 'Бригадир', _getBrigadierName(order)),
                                              const SizedBox(height: 8),
                                              _buildGridInfoRow(
                                                Icons.calendar_today_outlined,
                                                'Дата',
                                                order['status'] == 'IN_PROGRESS'
                                                    ? 'В работе'
                                                    : _formatDate(order['startDate']?.toString()),
                                              ),
                                              if (order['address'] != null) ...[
                                                const SizedBox(height: 8),
                                                _buildGridInfoRow(Icons.location_on_outlined, 'Адрес', _formatAddress(order['address'])),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6366F1).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Подробнее',
                                                style: TextStyle(
                                                  color: Color(0xFF6366F1),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 14,
                                                color: Color(0xFF6366F1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

