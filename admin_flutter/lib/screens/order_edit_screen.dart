import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';

class OrderEditScreen extends StatefulWidget {
  final int orderId;

  const OrderEditScreen({super.key, required this.orderId});

  @override
  State<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends State<OrderEditScreen> {
  final _orderService = OrderService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _order;
  
  final _descriptionController = TextEditingController();
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedBrigadier;
  List<dynamic> _brigadiers = [];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _orderService.getOrderById(widget.orderId),
        _orderService.getAllBrigadiers(),
      ]);
      
      final order = results[0] as Map<String, dynamic>;
      final brigadiers = results[1] as List<dynamic>;
      
      setState(() {
        _order = order;
        _selectedStatus = order['status'];
        _descriptionController.text = order['description'] ?? '';
        _selectedBrigadier = order['brigadierUsername'];
        _brigadiers = brigadiers;
        
        if (order['startDate'] != null) {
          try {
            _startDate = DateTime.parse(order['startDate']);
          } catch (e) {
            // Игнорируем ошибку парсинга
          }
        }
        
        if (order['endDate'] != null) {
          try {
            _endDate = DateTime.parse(order['endDate']);
          } catch (e) {
            // Игнорируем ошибку парсинга
          }
        }
        
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

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final data = {
        'description': _descriptionController.text.trim(),
        'status': _selectedStatus,
      };

      if (_startDate != null) {
        data['startDate'] = DateFormat('yyyy-MM-dd').format(_startDate!);
      }

      if (_endDate != null) {
        data['endDate'] = DateFormat('yyyy-MM-dd').format(_endDate!);
      }

      // Если изменился бригадир, назначаем его отдельным запросом
      if (_selectedBrigadier != _order!['brigadierUsername']) {
        if (_selectedBrigadier != null && _selectedBrigadier!.isNotEmpty) {
          await _orderService.assignBrigadier(widget.orderId, _selectedBrigadier!);
        }
      }

      await _orderService.updateOrder(widget.orderId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ обновлен')),
        );
        Navigator.pop(context, true);
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
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Редактирование заказа')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование заказа'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Статус',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'CREATED', child: Text('Создан')),
                  DropdownMenuItem(value: 'IN_PROGRESS', child: Text('В работе')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('Завершен')),
                  DropdownMenuItem(value: 'APPROVED', child: Text('Одобрен')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('Отклонен')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Выберите статус';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBrigadier,
                decoration: InputDecoration(
                  labelText: 'Бригадир',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.construction,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Не назначен'),
                  ),
                  ..._brigadiers.map((brigadier) {
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
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBrigadier = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Дата начала',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _startDate != null
                        ? DateFormat('yyyy-MM-dd').format(_startDate!)
                        : 'Выберите дату',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Дата окончания',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _endDate != null
                        ? DateFormat('yyyy-MM-dd').format(_endDate!)
                        : 'Выберите дату',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

