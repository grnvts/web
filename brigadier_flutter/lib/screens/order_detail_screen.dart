import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import '../services/brigade_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderService = OrderService();
  final _brigadeService = BrigadeService();
  bool _isLoading = true;
  Map<String, dynamic>? _order;
  List<dynamic> _assignedMasters = [];

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
      final masters = await _orderService.getAssignedMasters(widget.orderId);
      setState(() {
        _order = order;
        _assignedMasters = masters;
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

  Future<void> _updateStatus(String status) async {
    try {
      await _orderService.updateOrderStatus(widget.orderId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Статус обновлен'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrder();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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

  String _getClientName(Map<String, dynamic> order) {
    final name = order['clientName'] ?? '';
    final surname = order['clientSurname'] ?? '';
    final patronymic = order['clientPatronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return order['clientUsername'] ?? 'Неизвестно';
  }

  String _formatAddress(dynamic address) {
    if (address == null) return 'N/A';
    if (address is Map) {
      return '${address['city'] ?? ''}, ${address['street'] ?? ''} ${address['buildingNo'] ?? ''}, кв. ${address['apartmentNo'] ?? ''}';
    }
    return address.toString();
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
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(currentStatus).withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Статус заказа',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(currentStatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(currentStatus),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (currentStatus == 'CREATED')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _updateStatus('IN_PROGRESS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Начать работу'),
                          ),
                        ),
                      if (currentStatus == 'IN_PROGRESS')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _updateStatus('COMPLETED'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Завершить заказ'),
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
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Информация о заказе',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('ID заказа', '${_order!['id']}'),
                    _buildInfoRow('Дата начала', _formatDate(_order!['startDate']?.toString())),
                    if (_order!['endDate'] != null)
                      _buildInfoRow('Дата окончания', _formatDate(_order!['endDate']?.toString())),
                    _buildInfoRow('Клиент', _getClientName(_order!)),
                    if (_order!['description'] != null)
                      _buildInfoRow('Описание', _order!['description']),
                    if (_order!['address'] != null)
                      _buildInfoRow('Адрес', _formatAddress(_order!['address'])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Назначенные мастера
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Назначенные мастера',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAssignMastersDialog(),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Назначить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_assignedMasters.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Мастера не назначены'),
                      )
                    else
                      ..._assignedMasters.map((master) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.2),
                            child: Text(
                              _getMasterInitials(master),
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(_getMasterName(master)),
                          subtitle: Text(master['email'] ?? ''),
                        );
                      }).toList(),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  String _getMasterName(dynamic master) {
    final name = master['name'] ?? '';
    final surname = master['surname'] ?? '';
    final patronymic = master['patronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return master['username'] ?? 'Неизвестно';
  }

  String _getMasterInitials(dynamic master) {
    final name = _getMasterName(master);
    if (name.isNotEmpty && name != 'Неизвестно') {
      return name[0].toUpperCase();
    }
    return 'M';
  }

  Future<void> _showAssignMastersDialog() async {
    List<dynamic> brigadeMasters = [];
    List<int> selectedMasterIds = [];
    bool isLoading = true;

    // Загружаем мастеров бригады и уже назначенных мастеров
    try {
      final results = await Future.wait([
        _brigadeService.getMyBrigadeMasters(),
        _orderService.getAssignedMasters(widget.orderId),
      ]);
      
      brigadeMasters = results[0] as List<dynamic>;
      final assignedMasters = results[1] as List<dynamic>;
      selectedMasterIds = assignedMasters.map((m) => m['id'] as int).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.people, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Назначить мастеров')),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (brigadeMasters.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('В вашей бригаде нет мастеров'),
                    )
                  else
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: brigadeMasters.length,
                        itemBuilder: (context, index) {
                          final master = brigadeMasters[index];
                          final masterId = master['id'] as int;
                          final isSelected = selectedMasterIds.contains(masterId);
                          
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedMasterIds.add(masterId);
                                } else {
                                  selectedMasterIds.remove(masterId);
                                }
                              });
                            },
                            title: Text(_getMasterName(master)),
                            subtitle: Text(master['email'] ?? ''),
                            secondary: CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(0.2),
                              child: Text(
                                _getMasterInitials(master),
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            activeColor: Colors.orange,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _orderService.assignMasters(
                      widget.orderId,
                      selectedMasterIds,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Мастера успешно назначены'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadOrder();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ошибка: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Назначить'),
              ),
            ],
          );
        },
      ),
    );
  }
}

