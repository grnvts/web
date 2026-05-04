import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/app_container.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderUseCases = AppContainer.orderUseCases;

  bool _isLoading = false;
  String? _selectedServiceType;
  DateTime? _selectedDate;

  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingNoController = TextEditingController();
  final _apartmentNoController = TextEditingController();
  final _orderDetailsController = TextEditingController();

  final List<String> _serviceTypes = ['electrician', 'plumbing', 'painting'];

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _buildingNoController.dispose();
    _apartmentNoController.dispose();
    _orderDetailsController.dispose();
    super.dispose();
  }

  String _serviceLabel(String type) {
    switch (type.toLowerCase()) {
      case 'electrician':
        return 'Electrician';
      case 'plumbing':
        return 'Plumbing';
      case 'painting':
        return 'Painting';
      default:
        return type;
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 1, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : const Color(0xFF0F766E),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedServiceType == null) {
      _showMessage('Select a service type', isError: true);
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Select start date', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderData = <String, dynamic>{
        'serviceType': _selectedServiceType,
        'address': {
          'city': _cityController.text.trim(),
          'street': _streetController.text.trim(),
          'buildingNo': _buildingNoController.text.trim(),
          'apartmentNo': _apartmentNoController.text.trim(),
        },
        'orderDetails': _orderDetailsController.text.trim(),
        'startDate': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      };

      await _orderUseCases.createOrder(orderData);
      if (!mounted) return;
      _showMessage('Order created');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to create order: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create order')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFEFF6FF), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeaderCard(
                  title: 'New service request',
                  subtitle:
                      'Fill in address and details. The admin will assign a brigadier.',
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  icon: Icons.build_outlined,
                  title: 'Service type',
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedServiceType,
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      prefixIcon: Icon(Icons.handyman_outlined),
                    ),
                    items: _serviceTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(_serviceLabel(type)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedServiceType = value),
                    validator: (value) =>
                        value == null ? 'Select service type' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Address',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter city'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Street',
                          prefixIcon: Icon(Icons.signpost_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
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
                                prefixIcon: Icon(Icons.home_outlined),
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
                                prefixIcon: Icon(Icons.apartment_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.notes_outlined,
                  title: 'Details',
                  child: TextFormField(
                    controller: _orderDetailsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Describe the issue',
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Schedule',
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Preferred start date',
                        prefixIcon: Icon(Icons.event_available_outlined),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Select date'
                            : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _submitOrder,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_isLoading ? 'Submitting...' : 'Create order'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF0F766E)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
