import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import 'order_edit_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _orderService = OrderService();
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
      final results = await Future.wait([
        _orderService.getOrderById(widget.orderId),
        _orderService.getAssignedMasters(widget.orderId).catchError((e) => []),
      ]);
      
      setState(() {
        _order = results[0] as Map<String, dynamic>;
        _assignedMasters = results[1] as List<dynamic>;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали заказа')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали заказа')),
        body: const Center(child: Text('Заказ не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #${_order!['id']}'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAssignBrigadierDialog(),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Назначить бригадира'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderEditScreen(orderId: widget.orderId),
                  ),
                ).then((_) => _loadOrder());
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Редактировать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      _getStatusColor(_order!['status']).withOpacity(0.1),
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
                          Text(
                            'Статус заказа',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(_order!['status']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(_order!['status']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('ID заказа', '${_order!['id']}'),
                      if (_order!['serviceType'] != null)
                        _buildInfoRow('Тип услуги', _translateServiceType(_order!['serviceType'])),
                      if (_order!['createdDate'] != null)
                        _buildInfoRow('Дата создания', _formatDate(_order!['createdDate']?.toString())),
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
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Информация о клиенте',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Клиент', _getClientName(_order!)),
                      if (_order!['clientUsername'] != null)
                        _buildInfoRow('Логин клиента', _order!['clientUsername']),
                      if (_order!['clientEmail'] != null)
                        _buildInfoRow('Email клиента', _order!['clientEmail']),
                      if (_order!['clientPhone'] != null)
                        _buildInfoRow('Телефон клиента', _order!['clientPhone']),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Информация о бригадире',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Бригадир', _getBrigadierName(_order!)),
                      if (_order!['brigadierUsername'] != null)
                        _buildInfoRow('Логин бригадира', _order!['brigadierUsername']),
                      if (_order!['brigadierEmail'] != null)
                        _buildInfoRow('Email бригадира', _order!['brigadierEmail']),
                      if (_order!['brigadierPhone'] != null)
                        _buildInfoRow('Телефон бригадира', _order!['brigadierPhone']),
                      if (_order!['brigadeNumber'] != null)
                        _buildInfoRow('Номер бригады', '${_order!['brigadeNumber']}'),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Дополнительная информация',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_order!['description'] != null || _order!['orderDetails'] != null)
                        _buildInfoRow(
                          'Описание',
                          _order!['description'] ?? _order!['orderDetails'] ?? 'Не указано',
                        ),
                      if (_order!['address'] != null) ...[
                        _buildInfoRow('Город', _order!['address']['city']?.toString() ?? 'Не указан'),
                        _buildInfoRow('Улица', _order!['address']['street']?.toString() ?? 'Не указана'),
                        if (_order!['address']['buildingNo'] != null)
                          _buildInfoRow('Дом', _order!['address']['buildingNo'].toString()),
                        if (_order!['address']['apartmentNo'] != null)
                          _buildInfoRow('Квартира', _order!['address']['apartmentNo'].toString()),
                      ] else
                        _buildInfoRow('Адрес', 'Не указан'),
                    ],
                  ),
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
                    Text(
                      'Назначенные мастера',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(),
                    if (_assignedMasters.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Мастера не назначены',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ..._assignedMasters.map((master) {
                        final masterName = _getMasterName(master);
                        final masterEmail = master['email'] ?? '';
                        final masterPhone = master['phone'] ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    _getMasterInitials(master),
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      masterName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (masterEmail.isNotEmpty)
                                      Text(
                                        masterEmail,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (masterPhone.isNotEmpty)
                                      Text(
                                        masterPhone,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  String _getClientName(Map<String, dynamic> order) {
    final name = order['clientName'] ?? '';
    final surname = order['clientSurname'] ?? '';
    final patronymic = order['clientPatronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return order['clientUsername'] ?? 'Неизвестно';
  }

  String _getBrigadierName(Map<String, dynamic> order) {
    if (order['brigadierId'] == null) return 'Не назначен';
    final name = order['brigadierName'] ?? '';
    final surname = order['brigadierSurname'] ?? '';
    final patronymic = order['brigadierPatronymic'] ?? '';
    if (name.isNotEmpty || surname.isNotEmpty) {
      return '${surname} ${name} ${patronymic}'.trim();
    }
    return order['brigadierUsername'] ?? 'Не назначен';
  }

  String _formatAddress(dynamic address) {
    if (address == null) return 'N/A';
    if (address is Map) {
      return '${address['city'] ?? ''}, ${address['street'] ?? ''} ${address['buildingNo'] ?? ''}, кв. ${address['apartmentNo'] ?? ''}';
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

  Future<void> _showAssignBrigadierDialog() async {
    List<dynamic> brigadiers = [];
    bool isLoading = true;
    String? selectedBrigadier;

    // Загружаем список бригадиров
    try {
      brigadiers = await _orderService.getAllBrigadiers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки бригадиров: ${e.toString()}'),
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
                Icon(Icons.person_add, color: Colors.orange),
                SizedBox(width: 8),
                Text('Назначить бригадира'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (brigadiers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Нет доступных бригадиров'),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: selectedBrigadier,
                      decoration: InputDecoration(
                        labelText: 'Выберите бригадира',
                        prefixIcon: const Icon(Icons.construction),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: brigadiers.map((brigadier) {
                        final name = brigadier['name'] ?? '';
                        final surname = brigadier['surname'] ?? '';
                        final patronymic = brigadier['patronymic'] ?? '';
                        final username = brigadier['username'] ?? '';
                        
                        String displayName;
                        if (name.isNotEmpty || surname.isNotEmpty) {
                          displayName = '${surname} ${name} ${patronymic}'.trim();
                        } else {
                          displayName = username;
                        }
                        
                        return DropdownMenuItem<String>(
                          value: username,
                          child: Text(displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedBrigadier = value;
                        });
                      },
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
                onPressed: selectedBrigadier == null
                    ? null
                    : () async {
                        try {
                          await _orderService.assignBrigadier(
                            widget.orderId,
                            selectedBrigadier!,
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Бригадир успешно назначен'),
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

