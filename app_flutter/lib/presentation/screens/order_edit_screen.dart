import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';

class OrderEditScreen extends StatefulWidget {
  final int orderId;

  const OrderEditScreen({super.key, required this.orderId});

  @override
  State<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends State<OrderEditScreen> {
  final _orderUseCases = AppContainer.orderUseCases;
  final _formKey = GlobalKey<FormState>();
  final _orderDetailsController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingNoController = TextEditingController();
  final _apartmentNoController = TextEditingController();

  static const List<String> _statuses = <String>[
    'CREATED',
    'IN_PROGRESS',
    'COMPLETED',
    'APPROVED',
    'REJECTED',
  ];

  static const List<String> _serviceTypes = <String>[
    'electrician',
    'plumbing',
    'painting',
  ];

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _order;
  String? _selectedStatus;
  String? _selectedServiceType;
  String? _selectedBrigadier;
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _brigadiers = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _orderDetailsController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingNoController.dispose();
    _apartmentNoController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _orderUseCases.getOrderById(widget.orderId),
        _orderUseCases.getAllBrigadiers(),
      ]);

      final order = results[0] as Map<String, dynamic>;
      final brigadiers = results[1] as List<dynamic>;
      final address = order['address'] as Map<String, dynamic>?;

      setState(() {
        _order = order;
        _brigadiers = brigadiers;
        _selectedStatus = order['status']?.toString();
        _selectedServiceType = order['serviceType']?.toString();
        _selectedBrigadier = order['brigadierUsername']?.toString();
        _orderDetailsController.text =
            (order['orderDetails'] ?? order['description'] ?? '').toString();
        _priceController.text = order['price']?.toString() ?? '';
        _cityController.text = address?['city']?.toString() ?? '';
        _streetController.text = address?['street']?.toString() ?? '';
        _buildingNoController.text = address?['buildingNo']?.toString() ?? '';
        _apartmentNoController.text = address?['apartmentNo']?.toString() ?? '';
        _startDate = _parseDate(order['startDate']?.toString());
        _endDate = _parseDate(order['endDate']?.toString());
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

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Select date';
    }
    return DateFormat('yyyy-MM-dd').format(value);
  }

  String _statusLabel(String status) {
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
        return status;
    }
  }

  String _serviceTypeLabel(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'electrician':
        return 'Electrician';
      case 'plumbing':
        return 'Plumbing';
      case 'painting':
        return 'Finishing';
      default:
        return serviceType;
    }
  }

  String _brigadierLabel(dynamic brigadier) {
    final name = brigadier['name']?.toString() ?? '';
    final surname = brigadier['surname']?.toString() ?? '';
    final patronymic = brigadier['patronymic']?.toString() ?? '';
    final username = brigadier['username']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    return fullName.isEmpty ? username : '$fullName ($username)';
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isStartDate) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStatus == null || _selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status and service type are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final priceValue = _priceController.text.trim().replaceAll(',', '.');
      final parsedPrice = priceValue.isEmpty
          ? null
          : double.tryParse(priceValue);
      if (priceValue.isNotEmpty && parsedPrice == null) {
        throw Exception('Price must be a number');
      }

      final payload = <String, dynamic>{
        'serviceType': _selectedServiceType,
        'orderDetails': _orderDetailsController.text.trim(),
        'status': _selectedStatus,
        'address': <String, dynamic>{
          'city': _cityController.text.trim(),
          'street': _streetController.text.trim(),
          'buildingNo': _buildingNoController.text.trim(),
          'apartmentNo': _apartmentNoController.text.trim(),
        },
      };
      if (parsedPrice != null) {
        payload['price'] = parsedPrice;
      }
      if (_startDate != null) {
        payload['startDate'] = DateFormat('yyyy-MM-dd').format(_startDate!);
      }
      if (_endDate != null) {
        payload['endDate'] = DateFormat('yyyy-MM-dd').format(_endDate!);
      }

      if (_selectedBrigadier != null &&
          _selectedBrigadier != _order?['brigadierUsername']) {
        await _orderUseCases.assignBrigadier(
          widget.orderId,
          _selectedBrigadier!,
        );
      }

      await _orderUseCases.updateOrder(widget.orderId, payload);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Changes saved')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSection(
                title: 'Core fields',
                icon: Icons.assignment_outlined,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statuses
                        .map(
                          (status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(_statusLabel(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value),
                    validator: (value) =>
                        value == null ? 'Select status' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedServiceType,
                    decoration: const InputDecoration(
                      labelText: 'Service type',
                    ),
                    items: _serviceTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(_serviceTypeLabel(type)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedServiceType = value),
                    validator: (value) =>
                        value == null ? 'Select service type' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBrigadier,
                    decoration: const InputDecoration(labelText: 'Brigadier'),
                    items: _brigadiers
                        .map(
                          (brigadier) => DropdownMenuItem<String>(
                            value: brigadier['username']?.toString(),
                            child: Text(_brigadierLabel(brigadier)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedBrigadier = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price (BYN)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Schedule',
                icon: Icons.calendar_today_outlined,
                children: <Widget>[
                  InkWell(
                    onTap: () => _pickDate(isStartDate: true),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start date',
                      ),
                      child: Text(_formatDate(_startDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickDate(isStartDate: false),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End date'),
                      child: Text(_formatDate(_endDate)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Address',
                icon: Icons.location_on_outlined,
                children: <Widget>[
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter city'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(labelText: 'Street'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter street'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _buildingNoController,
                          decoration: const InputDecoration(
                            labelText: 'Building',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter building'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _apartmentNoController,
                          decoration: const InputDecoration(
                            labelText: 'Apartment',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Work details',
                icon: Icons.notes_outlined,
                children: <Widget>[
                  TextFormField(
                    controller: _orderDetailsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveOrder,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
